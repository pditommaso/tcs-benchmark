#/bin/bash
set -e
set -u

#
# 0. define the env
export PRJNAME="tcs-align-$$"
export QUEUE=${QUEUE:-all.q}
export FASTA_4_MAFFT=$PWD/bin/fasta34
export MAFFT_BINARIES=$PWD/mafft/
export PATH=$PWD/bin:$PATH
export PATH=$PWD/mafft:$PATH
export RUN_MODE=debug
export COUNT=1
export METHODS="GS GR WR TG TS"
export ALL_STEPS="aln filter tree ml"
export STEPS="${@:-$ALL_STEPS}"

export DB_FOLDER=$PWD/data
export DATA_FOLDER=$PWD/results
export LOG_FOLDER=$PWD/logs
export ZIP_FOLDER=$PWD

if [ -e prolog.sh ]; then 
  . prolog.sh
fi 

#
# Sanity check
# 
if [[ ! -e $DB_FOLDER ||  ! $(ls -A $DB_FOLDER 2>/dev/null)  ]]; then echo "Missing or empty DB_FOLDER: $DB_FOLDER"; fi

if [ ! -e $DATA_FOLDER ]; then mkdir -p $DATA_FOLDER; fi
if [ ! -e $LOG_FOLDER ]; then mkdir -p $LOG_FOLDER; fi 
if [ ! -e $ZIP_FOLDER ]; then mkdir -p $ZIP_FOLDER; fi 


if [[ $STEPS == $ALL_STEPS || $STEPS == *clean* ]]; then 
  echo "Clean folders"
  rm -rf ${DATA_FOLDER}/tips*
  rm -rf ${LOG_FOLDER}/*
fi

date > log-$$-start

#
# Pipeline code begins here 
#
# 1. Alignment step
#
if [[ $STEPS == *aln* ]]; then
  bash submit.sh $COUNT genAln
  bash ./qwait.sh
  if [ -e qsync.sh ]; then bash qsync.sh; fi  
fi 

#
# 2. filter step
#
if [[ $STEPS == *filter* ]]; then
  for it in $METHODS; do 
    bash submit.sh $COUNT genFilter $it
  done
  bash ./qwait.sh
  if [ -e qsync.sh ]; then bash qsync.sh; fi 
fi

#
# 3. Tree step
#
if [[ $STEPS == *tree* ]]; then
  LONG_METHODS="$METHODS OA"
  for it in $LONG_METHODS; do 
    bash submit.sh $COUNT genTree $it
  done
  bash ./qwait.sh
  if [ -e qsync.sh ]; then bash qsync.sh; fi 
fi


#
# 4. ML step
#
if [[ $STEPS == *ml* ]]; then
  LONG_METHODS="$METHODS OA"
  for it in $LONG_METHODS; do
    bash submit.sh $COUNT genML $it  
  done
  bash ./qwait.sh
  if [ -e qsync.sh ]; then bash qsync.sh; fi 
fi

date > log-$$-end


#
# Invoke pipeline finalization script
#
if [ -e epilog.sh ]; then 
bash epilog.sh
fi


