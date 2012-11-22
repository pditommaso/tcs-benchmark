#!/bin/bash

echo "Uploading logs .. "

for hh in {1..9}; do 
   hh="worker$hh"
   if grep -bqs "\b$hh\b" /etc/hosts; then
     echo "Uploading logs for: $hh"
     qsub -cwd -o $LOG_FOLDER/upload-$hh.log -j yes -q $QUEUE@$hh -V ziplogs.sh
   fi
done

echo "Waiting for logs upload termination"
bash qwait.sh
