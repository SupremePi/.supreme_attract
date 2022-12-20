
IFS=";"

romdir=""
gname=""

while read romdir gname
do
emu=`grep "${romdir}" /home/pi/.attract/emulators/*.cfg |grep rompath |cut -f6 -d "/" |cut -f1 -d ":" |cut -f1 -d "."` 
game=`echo "${gname}" |cut -f7 -d "/" |sed 's/.\{4\}$//'`
trueemu=`echo ${emu} |head -1`
cat "/home/pi/.attract/romlists/${trueemu}.txt" |grep "^${game};" > /tmp/newgame

while read fullline
do
cat "/home/pi/.attract/romlists/Last Played.txt" |grep -v "${fullline}" > /tmp/tmpfile
cat /tmp/newgame >> /tmp/tmpfile
maxgame=`cat /tmp/tmpfile  |wc -l`
if [[ ${maxgame} > "24" ]]; then
  tail -24 /tmp/tmpfile > /tmp/tmpfile2
  mv /tmp/tmpfile2 "/home/pi/.attract/romlists/Last Played.txt"
else
  mv /tmp/tmpfile "/home/pi/.attract/romlists/Last Played.txt"
fi
done < /tmp/newgame

done < /tmp/lastplayed


