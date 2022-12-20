///////////////////////////////////////////////////
//
// Attract-Mode Frontend - DisplayMusic plugin
//
// This is based on the AudioMode plugin, but
// cannot be used simultaneously with it.
//
///////////////////////////////////////////////////
//
// Define the user-configurable options:
//
class UserConfig </ help="Each display fetches music from unique folder" /> {

	</ label="Source Directory",
		help="The full path to the parent directory containing the category-music subfolders",
		order=1 />
	dir="";
	
	</ label="Start Delay",
		help="Number of seconds to wait before playing a new playlist or changing playlists",
		order=2 />
	startDelay=2;

}

fe.load_module( "file" );
	
class DisplayMusic
{
	m_list = [];
	m_display_index = 0;
	m_display_name = "";
	m_index = 0;
	m_input_block = false;
	m_config = {};
	m_dir = null;
	m_start_delay = 2; // Default to 2 seconds
	m_mute = false;
	m_ignore_next_transitions = 0;
	
	constructor()
	{
		fe.add_ticks_callback(this, "on_tick");
		fe.add_transition_callback(this, "on_transition");
		fe.ambient_sound.loop = false;
		m_config = fe.get_config();
		m_display_index = fe.list.display_index;
		m_display_name = fe.list.name;
		m_dir = fe.path_expand(m_config["dir"]);
		m_start_delay = m_config["startDelay"].tointeger();
		if (m_start_delay < 0) m_start_delay = 0;
		load_playlist(m_dir + "/" + m_display_name);
	}

	function load_playlist(path)
	{
		local dir = DirectoryListing(path);

		// Shuffle the playlist
		m_list = [];
		while (dir.results.len() > 0)
		{
			local idx = rand() % dir.results.len();
			m_list.append(strip(dir.results[ idx ]));
			dir.results.remove(idx);
		}
		
		// If there is anything to play, prepend a 2 second long pause
		// so the robot voice can finish before music starts
		if (m_list.len() > 0)
		{
			for (local i=0; i < m_start_delay; i++)
			{
				m_list.insert (1, m_dir + "/1SecSilence.mp3");
			}
		}
	}

	function change_track(offset)
	{
		if (m_list.len() <= 0) return;

		m_index += (offset % m_list.len());

		if (m_index < 0)
			m_index += m_list.len();
		if (m_index >= m_list.len())
			m_index -= m_list.len();

		// play the next track
		fe.ambient_sound.file_name = fe.path_expand(m_list[m_index]);
		
		if (fe.ambient_sound.file_name.len() < 1)
		{
			m_list.remove(m_index);
			return change_track(offset);
		}

		if (m_mute == false) fe.ambient_sound.playing = true;
	}

	function on_tick(ttime)
	{
		if (fe.ambient_sound.playing == false) change_track(1);
	}
	
	function on_transition(ttype, var, ttime)
	{		
		m_display_index = fe.list.display_index;
		m_display_name = fe.list.name;
		
		// If we are ignoring upcoming transitions, decrement the number to ignore
		if (m_ignore_next_transitions > 0)
		{
			m_ignore_next_transitions--;
			return false;
		}
		
		// Keep playing when transitioning from intro to display
		if (ttype == Transition.StartLayout && var == FromTo.Frontend)
		{
			m_ignore_next_transitions = 1; // Ignore next ONE transition
			return false;
		}
		
		// Keep playing when transitioning to or from screensaver
		if (var == FromTo.ScreenSaver && (ttype == Transition.StartLayout || ttype == Transition.EndLayout))
		{
			m_ignore_next_transitions = 1; // Ignore next ONE transition
			return false;
		}
		
		// Resume playing when returning from a game
		if (ttype == Transition.FromGame)
		{
			m_mute = false;
			change_track(1);
		}
		
		// Change playlist when transitioning to new display (but not by filtering)
		if (ttype == Transition.ToNewList && var == 0)
		{
			m_mute = false;
			fe.ambient_sound.playing = false;
			m_display_index = fe.list.display_index;
			load_playlist(m_dir + "/" + m_display_name);
			m_index = 0;
			change_track(1);
		}
		return false;
	}
}

// create an entry in the fe.plugin table in case anyone else wants to
// find this plugin
//
fe.plugin["DisplayMusic"] <- DisplayMusic();