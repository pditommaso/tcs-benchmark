#/bin/bash
set -e

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

export EMAIL_4_TCOFFEE="tcoffee.msa@gmail.com"
export TMP_4_TCOFFEE="$PWD/tmp/tcoffee/tmp/"
export CACHE_4_TCOFFEE="$PWD/tmp/tcoffee/cache/"
export LOCKDIR_4_TCOFFEE="$PWD/tmp/tcoffee/lck"
mkdir -p $TMP_4_TCOFFEE
mkdir -p $CACHE_4_TCOFFEE
mkdir -p $LOCKDIR_4_TCOFFEE

rm -rf wrapper-4-genAln.*
rm -rf wrapper-4-genTree.*
rm -rf wrapper-4-genFilter.*
rm -rf tips*

date > log-$$-start

#
# 1. execute the pipeline 
bash submit $COUNT genAln
bash ./qwait.sh

for it in $METHODS; do 
bash submit $COUNT genFilter $it
done
bash ./qwait.sh

LONG_METHODS="$METHODS OA"
for it in $LONG_METHODS; do 
bash submit $COUNT genTree $it
done
bash ./qwait.sh

date > log-$$-end

#
# 2. zip the result 
ZIP=$PRJNAME.zip
zip -r $ZIP tips* wrapper-4-* log-* 

#
# 3. upload the result 
s3cmd --rr --acl-public put $ZIP s3://cbcrg-eu/$ZIP

#
# 4. send notification email 
MAIL_BODY="$PRJNAME job completed\n\nDownload the result at this link http://cbcrg-eu.s3.amazonaws.com/$ZIP\n\nBye"
MAIL_RECIPIENTS="paolo.ditommaso@gmail.com chang.jiaming@gmail.com"
MAIL_FROM="tcoffee.msa@gmail.com"
MAIL_SUBJECT="$PRJNAME terminated ($$)!"
echo -e "$MAIL_BODY" | ses-send-email.pl -s "$MAIL_SUBJECT" -f $MAIL_FROM $MAIL_RECIPIENTS

#
# 5. turn-off 
if [ -e .instances ]; then
cat .instances | ec2-stop-instances --region eu-west-1
fi
