#!/bin/bash
#total: 2(tips)*6(variation)*5(aln length)*3(aligners)*100(sets)=18,000
#####################################################################

QUEUE=${QUEUE:-main}
qcn_cmd="qsub -cwd -j yes -V -q $QUEUE"
qsub_cmd="$qcn_cmd"

RUN_MODE=${RUN_MODE:-debug}
if [ $RUN_MODE == "debug" ]
then                       
  tips=("tips32") #tips number
  divers=("asymmetric_0.5")   
  lens=("0400") #aln len      
  alns=("MA" "CL" "PC") #MAFFT, ClustalW2, ProbCons
else                                               
  tips=("tips32" "tips64") #tips number, tips16:300 sets, tips32,tips64:300 sets
  #divergence level                                                             
  divers=("asymmetric_0.5" "asymmetric_1.0" "asymmetric_2.0" "symmetric_0.5" "symmetric_1.0" "symmetric_2.0")
  lens=("0400" "0800" "1200" "1600" "3200") #aln len                                                     
  alns=("MA" "CL" "PC") #MAFFT, ClustalW2, ProbCons                                                      
fi                                                                                                       

#GS:Gblock relax, GS:Gblock stringent, TG:trimal gappyout, TS:trimal strictplus
( [ $# != 2 ] && [ $# != 3 ] ) && echo "[USAGE] ./submit #_sets-2-run action[genAln,genFilter,genTree] method[GS,GR,WR,TG,TS]" && exit

NUM_SET=$1
action=$2
method=$3

echo "#_sets-2-run = $NUM_SET"
echo "run mode     = $RUN_MODE"
echo "action       = $action"
echo "method       = $method"
echo ""

for tip in "${tips[@]}"
do
  for diver in "${divers[@]}"
  do
    for len in "${lens[@]}"
    do
	for aln in "${alns[@]}"
	do	
	  case $action in
	  "genAln")
	    LOG="${LOG_FOLDER}/${action}_aln-${aln}"
	    $qsub_cmd -o $LOG -t 1-$NUM_SET ./wrapper-4-genAln $tip $diver $len $aln
	    ;;
	  "genFilter")
	    LOG="${LOG_FOLDER}/${action}_method-${method}_aln-${aln}"
	    $qsub_cmd -o $LOG -t 1-$NUM_SET ./wrapper-4-genFilter $tip $diver $len $aln $method
	    ;;
	  "genTree")
            LOG="${LOG_FOLDER}/${action}_method-${method}_aln-${aln}"
	    $qsub_cmd -o $LOG -t 1-$NUM_SET ./wrapper-4-genTree $tip $diver $len $aln $method
	    ;;
	   "genML")
            LOG="${LOG_FOLDER}/${action}_method-${method}_aln-${aln}"
	    $qsub_cmd -o $LOG -t 1-$NUM_SET ./wrapper-4-genML $tip $diver $len $aln $method
	    ;;
	  esac
	done
    done
  done
done
