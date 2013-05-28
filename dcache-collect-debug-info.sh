#!/bin/bash

# Collect debugging information for Dcache.

DCACHE_DEBUG_DIR=/var/log/dcache-debug

set -x

# Prepare directory (dcache dump fails when some files exists)
mkdir -p $DCACHE_DEBUG_DIR
rm -f $DCACHE_DEBUG_DIR/*

# Repeat thread dumps with few secs interval, Gerd likes that ;-)
HOW_MANY_THREAD_DUMPS=10
for i in `seq 1 $HOW_MANY_THREAD_DUMPS` ; do
  # Thread dumps are written in de *Domain.log files
  /usr/bin/dcache dump threads
  if [ "`hostname -s`" == "srm" ] ; then
    psql -U postgres dcache  -c "select * from pg_stat_activity;" > $DCACHE_DEBUG_DIR/pg_stat_activity-${i}-`date +%T`.txt
  fi
  if [ "`hostname -s`" == "namespace" ] ; then
    psql -U postgres chimera -c "select * from pg_stat_activity;" > $DCACHE_DEBUG_DIR/pg_stat_activity-${i}-`date +%T`.txt
  fi
  sleep 5
done

HOW_MANY_LINES=200000
# Save the last lines of each Dcache log file
for file in /var/log/*Domain.log ; do
  basename=`basename $file`
  tail -n $HOW_MANY_LINES $file > $DCACHE_DEBUG_DIR/${basename}-last-$HOW_MANY_LINES-lines-including-$HOW_MANY_THREAD_DUMPS-thread-dumps.txt
done

# Dump heap for all running Dcache domains
for domain in `/usr/bin/dcache status | grep 'Domain' | awk '{print $1}'` ; do 
  /usr/bin/dcache dump heap $domain $DCACHE_DEBUG_DIR/dcache-dump-heap-$domain.txt
done

cp /etc/dcache/dcache.conf $DCACHE_DEBUG_DIR/

top -b -n 1  > $DCACHE_DEBUG_DIR/top.txt

vmstat 1 10 > $DCACHE_DEBUG_DIR/vmstat.txt

lsof > $DCACHE_DEBUG_DIR/lsof.txt

netstat -nap > $DCACHE_DEBUG_DIR/netstat.txt

ps -efL > $DCACHE_DEBUG_DIR/ps.txt

chmod 644 $DCACHE_DEBUG_DIR/*

set +x

echo "Dumps and log files have been saved in $DCACHE_DEBUG_DIR."
if python -V 2>&1 | grep --silent ' 2\.[456789]\.' ; then
  echo "You can share them like this (preferably as an unprivileged user):"
  echo "cd $DCACHE_DEBUG_DIR ; nohup python -m SimpleHTTPServer 22222 &"
fi
