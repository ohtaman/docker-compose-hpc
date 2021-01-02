#!/bin/bash

# set locale
export LANG=ja_JP.utf8
export LC_ALL=C

TIMEOUT=120

# get uid/gid from local user
if [ -f /host/passwd ]; then
    LOCAL_UID=$(cat /host/passwd | grep $LOCAL_USER | cut -d: -f3)
    LOCAL_GID=$(cat /host/passwd | grep $LOCAL_USER | cut -d: -f4)
fi

# create user with same uid/gid as local user
if [ ! "$LOCAL_UID" == "" ]; then
    if ! groups $LOCAL_USER &> /dev/null; then
        groupadd -g $LOCAL_GID $LOCAL_USER
        useradd -M -u $LOCAL_UID -g $LOCAL_GID $LOCAL_USER
    fi
else
    useradd $LOCAL_USER
fi

# update setting of pbs
sed -i -e "s/^PBS_SERVER=.*$/PBS_SERVER=$PBS_SERVER/g" /etc/pbs.conf
sed -i -e "s/^\$clienthost.*$/\$clienthost $PBS_SERVER/g" /var/spool/pbs/mom_priv/config
echo 'TZ=Asia/Tokyo' >> /var/spool/pbs/pbs_environment

# wait for head node ready
echo "Waiting for $PBS_SERVER ready"
for t in `seq $TIMEOUT`; do
    nc -z $PBS_SERVER 22 > /dev/null
    res=$?
    if [ $res -eq 0 ]; then
        echo "$PBS_SERVER is now ready"
        sleep 1
        break
    fi
    sleep 1
done

# start pbs
/etc/init.d/pbs start

# Add self node
ssh $PBS_SERVER "qmgr -c \"create node $HOSTNAME\""
ssh $PBS_SERVER "qmgr -c \"set node $HOSTNAME queue=workq\""

# start ssh server
rm -f /run/nologin
echo "$HOSTNAME is ready"
/sbin/sshd -D
