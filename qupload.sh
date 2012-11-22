#!/bin/bash

echo "Uploading logs .. "

function upload() {
     echo "Uploading logs for: $1"
     qsub -cwd -o $LOG_FOLDER/upload-$1.log -j yes -q $QUEUE@$1 -V ziplogs.sh
}

# Upload logs for master 
upload master

# Upload logs for nodes
for hh in {1..9}; do 
   hh="worker$hh"
   if grep -bqs "\b$hh\b" /etc/hosts; then
     upload $hh
   fi
done


echo "Waiting for logs upload termination"
bash qwait.sh
