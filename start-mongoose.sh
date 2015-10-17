#!/bin/bash
MIMDIR="/opt/mongooseim/rel/mongooseim/"

S1=$EJABBERD_API_AUTH_TOKEN
S2=$EJABBERD_DOMAIN
S3=$EJABBERD_API_CONTEXT_PATH

echo "$S1"
echo "$S2"
echo "$S3"

sed -e "s/api_auth_token/$S1/" -i /opt/mongooseim/rel/mongooseim/etc/ejabberd.cfg
sed -e "s/ejabberd_domain/$S2/" -i /opt/mongooseim/rel/mongooseim/etc/ejabberd.cfg
sed -e "s/auth_context_path/$S3/" -i /opt/mongooseim/rel/mongooseim/etc/ejabberd.cfg

if [ -n "$HOSTNAME" ]; then
    VMARGS=/opt/mongooseim/rel/mongooseim/etc/vm.args
    echo "-kernel inet_dist_listen_min 9100 inet_dist_listen_max 9100" >> $VMARGS
    SEDARG="-i 's/sname mongooseim@localhost/sname mongooseim@$HOSTNAME/g' $VMARGS"
    eval sed "$SEDARG"
fi


if [ -n "$CLUSTER_WITH"  ]; then
   # checking this to be able to gently handle updates, when we want to preserve content
   if [ -d "/data/mnesia/Mnesia.mongooseim@$HOSTNAME" ]; then
       ## verify if we are in cluster ?
       echo "the node is probably part of a cluster"
   else
       $MIMDIR/bin/mongooseimctl add_to_cluster mongooseim@$CLUSTER_WITH
       mv -f "$MIMDIR/Mnesia.mongooseim@$HOSTNAME" "/data/mnesia/Mnesia.mongooseim@$HOSTNAME"
   fi
fi

if [ "$#" -ne 1 ]; then
   $MIMDIR/bin/mongooseim live --noshell -noinput +Bd  -mnesia dir \"/data/mnesia/Mnesia.mongooseim@$HOSTNAME\"
else
   $MIMDIR/bin/mongooseimctl $1
fi
