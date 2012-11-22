#!/bin/bash

XHOST=$(hostname -s)

echo "Zipping and uploading log files for: $XHOST" 

# Zipping 
ZIP=$TMPDIR/$PRJNAME-logs-$XHOST.zip
cd $LOG_FOLDER
zip -r $ZIP * 

# Uploading to S3
s3cmd --rr --acl-public put $ZIP s3://cbcrg-eu/$(basename $ZIP)
