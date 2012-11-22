#!/bin/bash


count=0
MAX=5
while [ $count -lt $MAX ]; do
  count=$(( $count + 1 ))
  
  rsync -rltzv ${OUT_FOLDER}/* master:/${OUT_FOLDER} 
##  rsync -rltz master:/${OUT_FOLDER}/* ${OUT_FOLDER}

  if [[ $? -eq 0 || $count -eq $MAX ]]; then
    break
  else
    sleep $(( $count * 5 ))
  fi
done
