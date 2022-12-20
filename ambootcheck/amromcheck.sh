#/bin/bash

################################################
#
# Attract Mode Display Autoconfiguration Utility
#
################################################

IFS=";"
clear

rm /tmp/showdisplay.txt > /dev/null 2>&1
rm /tmp/hidedisplay.txt > /dev/null 2>&1

function show_display_nested() {
systemname=$1
if [[ "${systemname}" == "MAME (Advance)" ]]; then
systemname="MAME \(Advance\)"
fi
if [[ "${systemname}" == "MAME (Libretro)" ]]; then
systemname="MAME \(Libretro\)"
fi
if [[ "${systemname}" == "MAME (Mame4all)" ]]; then
systemname="MAME \(Mame4all\)"
fi
perl -pi -w -e "s/#${systemname};/${systemname};/g;" /home/pi/.attract/romlists/Arcades.txt
perl -pi -w -e "s/#${systemname};/${systemname};/g;" /home/pi/.attract/romlists/Computers.txt
perl -pi -w -e "s/#${systemname};/${systemname};/g;" /home/pi/.attract/romlists/Consoles.txt
perl -pi -w -e "s/#${systemname};/${systemname};/g;" /home/pi/.attract/romlists/Handhelds.txt
}

function hide_display_nested() {
systemname=$1
if [[ "${systemname}" == "MAME (Advance)" ]]; then
systemname="MAME \(Advance\)"
fi
if [[ "${systemname}" == "MAME (Libretro)" ]]; then
systemname="MAME \(Libretro\)"
fi
if [[ "${systemname}" == "MAME (Mame4all)" ]]; then
systemname="MAME \(Mame4all\)"
fi
perl -pi -w -e "s/^${systemname};/#${systemname};/g;" /home/pi/.attract/romlists/Arcades.txt
perl -pi -w -e "s/^${systemname};/#${systemname};/g;" /home/pi/.attract/romlists/Computers.txt
perl -pi -w -e "s/^${systemname};/#${systemname};/g;" /home/pi/.attract/romlists/Consoles.txt
perl -pi -w -e "s/^${systemname};/#${systemname};/g;" /home/pi/.attract/romlists/Handhelds.txt
}

function show_display_traditional() {
currentdisplay="${1}"
ischoice="false"
while read line
do
if [[ $line == "display"*"${currentdisplay}" ]]; then
  echo $line >> /tmp/temp.cfg
  ischoice="true"
elif [[ $line == "display"* && $line != "displays_menu_exit"* ]]; then
  echo $line >> /tmp/temp.cfg
  ischoice="false"
elif [[ $line == *"in_cycle"* && $ischoice = "true" ]]; then
  echo -e "\tin_cycle             yes" >> /tmp/temp.cfg
elif [[ $line == *"in_menu"* && $ischoice = "true" ]]; then
  echo -e "\tin_menu              yes" >> /tmp/temp.cfg
  ischoice="false"
elif [[ $line == "rule"* ]]; then
  echo -e "${line}" >> /tmp/temp.cfg
elif [[ $line == "sound" ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "input_map" ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "general" ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "saver_config" ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "layout_config"* ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "intro_config" ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "#"* ]]; then
  echo $line >> /tmp/temp.cfg
else
  echo -e "${line}" >> /tmp/temp.cfg
fi
done < /tmp/attract_tmp.cfg
}

function hide_display_traditional() {
currentdisplay="${1}"
ischoice="false"
while read line
do
if [[ $line == "display"*"${currentdisplay}" ]]; then
  echo $line >> /tmp/temp.cfg
  ischoice="true"
elif [[ $line == "display"* && $line != "displays_menu_exit"* ]]; then
  echo $line >> /tmp/temp.cfg
  ischoice="false"
elif [[ $line == *"in_cycle"* && $ischoice = "true" ]]; then
  echo -e "\tin_cycle             no" >> /tmp/temp.cfg
elif [[ $line == *"in_menu"* && $ischoice = "true" ]]; then
  echo -e "\tin_menu              no" >> /tmp/temp.cfg
  ischoice="false"
elif [[ $line == "rule"* ]]; then
  echo -e "${line}" >> /tmp/temp.cfg
elif [[ $line == "sound" ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "input_map" ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "general" ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "saver_config" ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "layout_config"* ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "intro_config" ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "#"* ]]; then
  echo $line >> /tmp/temp.cfg
else
  echo -e "${line}" >> /tmp/temp.cfg
fi
done < /tmp/attract_tmp.cfg
}

#########################################################
# Get listing of systems and check for existing ROM files
#

ifexist=0
while read sname romdir ext
do
if [[ -d "/home/pi/RetroPie/roms/${romdir}" ]];then
 ext=`echo "$ext" | sed "s/ /|/g"`
 files=`ls /home/pi/RetroPie/roms/${romdir} |egrep ${ext}` 2> /dev/null
 if [[ -z $files ]];then
  ifexist=0
  echo "${sname}" >> /tmp/hidedisplay.txt
 else
  ifexist=1
  echo "${sname}" >> /tmp/showdisplay.txt
 fi
fi
done < /home/pi/.attract/ambootcheck/amromcheck.info

################################################
# Update the nested romlist files

cp /home/pi/.attract/romlists/Arcades.txt /home/pi/.attract/romlists/Arcades.txt.bkp
cp /home/pi/.attract/romlists/Computers.txt /home/pi/.attract/romlists/Computers.txt.bkp
cp /home/pi/.attract/romlists/Consoles.txt /home/pi/.attract/romlists/Consoles.txt.bkp
cp /home/pi/.attract/romlists/Handhelds.txt /home/pi/.attract/romlists/Handhelds.txt.bkp

while read systemname
do
show_display_nested "${systemname}"
done < /tmp/showdisplay.txt

while read systemname
do
hide_display_nested "${systemname}"
done < /tmp/hidedisplay.txt

################################################
# Update the main attract.cfg menu

cp /home/pi/.attract/attract.cfg /home/pi/.attract/attract.cfg.bkp
cp /home/pi/.attract/attract.cfg /tmp/attract_tmp.cfg

isarcade=`cat /home/pi/.attract/romlists/Arcades.txt |grep -v "#" |grep -v "Classic" |grep -v "Capcom" |wc -l`
iscomputer=`cat /home/pi/.attract/romlists/Computers.txt |grep -v "#" |wc -l`
isconsole=`cat /home/pi/.attract/romlists/Consoles.txt |grep -v "#" |wc -l`
ishandheld=`cat /home/pi/.attract/romlists/Handhelds.txt |grep -v "#" |wc -l`

if [[ $isarcade > "0" ]]; then
  show_display_traditional "Arcades"
else
  hide_display_traditional "Arcades"
fi
mv /tmp/temp.cfg /tmp/attract_tmp.cfg
if [[ $iscomputer > "0" ]]; then
  show_display_traditional "Computers"
else
  hide_display_traditional "Computers"
fi
mv /tmp/temp.cfg /tmp/attract_tmp.cfg
if [[ $isconsole > "0" ]]; then
  show_display_traditional "Consoles"
else
  hide_display_traditional "Consoles"
fi
mv /tmp/temp.cfg /tmp/attract_tmp.cfg
if [[ $ishandheld > "0" ]]; then
  show_display_traditional "Handhelds"
else
  hide_display_traditional "Handhelds"
fi
mv /tmp/temp.cfg /tmp/attract_tmp.cfg

cp /tmp/attract_tmp.cfg /home/pi/.attract/attract.cfg

clear
