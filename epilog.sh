#!/bin/bash
set -e
set -u

#
# Zip the result
#
echo "Zipping result" 
ZIP=$PRJNAME.zip
FULLZIP=$ZIP_FOLDER/$ZIP

# Zip the log files
zip -r $FULLZIP log* genlog*

# Zip the result
cd $DATA_FOLDER
zip -r $FULLZIP *     
cd $OLDPWD

#
# Upload the result
#
s3cmd --rr --acl-public put $FULLZIP s3://cbcrg-eu/$ZIP

#
# Upload logs
#
bash qupload.sh

#
# Send notification email
#
MAIL_BODY="$PRJNAME job completed\n\nDownload the result at this link http://cbcrg-eu.s3.amazonaws.com/$ZIP\n\nBye"
MAIL_RECIPIENTS="paolo.ditommaso@gmail.com"
MAIL_FROM="tcoffee.msa@gmail.com"
MAIL_SUBJECT="$PRJNAME terminated ($$)!"
echo -e "$MAIL_BODY" | ses-send-email.pl -s "$MAIL_SUBJECT" -f $MAIL_FROM $MAIL_RECIPIENTS

#
# Turn-off the cluster
#
if [ -e .instances ]; then
cat .instances | ec2-stop-instances - --region eu-west-1
fi
