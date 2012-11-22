#!/bin/bash

for hh in {1..9}; do 
   hh="worker$hh"
   if grep -bqs "\b$hh\b" /etc/hosts; then
     echo "Syncing node: $hh" 
     qsub -cwd -o $LOG_FOLDER/sync-$hh-\$JOB_ID.log -j yes -q $QUEUE@$hh -V rsync.sh
   fi
done

echo "Waiting for sync termination"
bash qwait.sh
