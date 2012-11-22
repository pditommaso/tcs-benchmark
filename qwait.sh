#/bin/bash

QDELAY=${QDELAY:-60}

while true; do
  JOBS=`qstat -u "$USER" | grep $USER | wc -l`
  echo "$JOBS to go .. wait for completion"
  if [ $JOBS == "0" ]; then break; fi
  sleep $QDELAY
done;
