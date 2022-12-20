// --------------------
// Load Modules
// --------------------

fe.load_module("helpers");

// --------------------
// Plugin User Options
// --------------------

class UserConfig </ help="A plugin that selects a random game after a period of inactivity." /> {
	</ label="Delay Time",
		help="The amount of inactivity (seconds) before selecting a random game.",
		order=1 />
	delayTime="30";
}

// --------------------
// Sequencer
// --------------------

class Sequencer {
	config = null;

	currentTime = null;
	delayTime = null;
	signalTime = null;
	status = null;

	constructor() {
		config = fe.get_config();
			try {
				config["delayTime"] = config["delayTime"].tointeger();
				assert(config["delayTime"] >= 1);
			}
			catch (e) {
				print("ERROR in Sequencer Plugin: user options - improper delay time\n");
				config["delayTime"] = 30;
			}

		status = 1;
		currentTime = 0;
		delayTime = config["delayTime"]*1000;
		signalTime = 0;

		fe.add_ticks_callback(this, "ticks");
		fe.add_transition_callback(this, "transitions");
	}

	// ----- Ticks Callbacks -----

	function ticks(ttime) {
		currentTime = ttime;

		if (status == 2) {
			signalTime = currentTime;
			status = 1;
			}

		if (status == 1 && (currentTime >= signalTime + delayTime)) {
			local targetIndex = randInt(fe.list.size - 1);
			local direction = randInt(1);

			direction == 0 ? fe.list.index = (targetIndex - 1) : fe.list.index = (targetIndex + 1);
			direction == 0 ? fe.signal("prev_game") : fe.signal("next_game");
		}
	}

	// ----- Transition Callbacks -----

	function transitions(ttype, var, ttime) {
		signalTime = currentTime;

		switch (ttype) {
			case Transition.ToGame:
				status = 0;
				break;
			case Transition.FromGame:
				status = 2;
				break;
		}

		return false;
	}
}
fe.plugin["Sequencer"] <- Sequencer();
