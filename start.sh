#!/bin/bash
#for i in {13..19} {21..46}
for i in 14 20
do
	echo $i
	scp iss 192.168.2.$i:/tmp 
	ssh 192.168.2.$i 'DISPLAY=:0 nohup /tmp/iss < /dev/null > std.out 2> std.err &'
done
