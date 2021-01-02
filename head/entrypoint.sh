#!/bin/bash

# set locale
export LANG=ja_JP.utf8
export LC_ALL=C

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

# start pbs
/etc/init.d/pbs start

# start ssh server
rm -f /run/nologin
echo "$HOSTNAME is ready"
/sbin/sshd -D
