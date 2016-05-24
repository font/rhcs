#!/bin/bash

DIR=/home/ifont/srv/ceph
VAR=/home/ifont/srv/ceph-var
ETC=/home/ifont/srv/etc/ceph
IP=192.168.1.15
NET=192.168.1.0/24
IMAGE='font/rhcs:v2.0'

rm -rf ${VAR}/* ${ETC}/*

docker rm -f mon
docker run -d --net=host -e MON_IP=${IP}  -e CEPH_PUBLIC_NETWORK=${NET} -e CEPH_DAEMON=mon  -v ${ETC}:/etc/ceph -v ${VAR}:/var/lib/ceph --name mon ${IMAGE}

for i in 0 1 2
do
   umount /tmp/ceph_disk${i}
   dd if=/dev/zero of=${DIR}/d${i} bs=256M count=5 conv=notrunc
   mkfs -t xfs -f ${DIR}/d${i}
   mkdir -p /tmp/ceph_disk${i}
   mount -t xfs -o loop ${DIR}/d${i} /tmp/ceph_disk${i}
   docker rm -f osd${i}
   docker run -d --privileged --pid=host --net=host -e MON_IP=${IP}  -e CEPH_DAEMON=osd -e  OSD_TYPE=directory -v /tmp/ceph_disk${i}:/var/lib/ceph/osd/ -v ${VAR}:/var/lib/ceph -v ${ETC}:/etc/ceph --name osd${i} ${IMAGE}
done


#ceph -w 
#docker stop $(docker ps -q)
