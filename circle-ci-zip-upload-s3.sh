#!/usr/bin/env bash

NOW="$(date +'%Y-%m-%d')"
SEPARATOR="-"
ZIP_EXTENSION=".zip"
S3_URL="s3://elasticbeanstalk-sa-east-1-980074370134/com/cash/app/"


  function log() {
    echo "$(date +%Y-%m-%d'T'%H:%M:%S)" $@
  }

##############
## Main
##############
git config --global user.email "sistemas@cash-online.com.ar"
git config --global user.name "Cash Online"

mvn release:update-versions -B
git add .
git commit -m "Circle Ci update version [ci skip]"
git push https://$CASH_BITBUCKET_USER:$CASH_BITBUCKET_PASSWORD@bitbucket.org/transconteam/cash-api.git


MVN_VERSION=$(cat pom.xml | grep "^    <version>.*</version>$" | awk -F'[><]' '{print $3}')
MVN_ARTIFACT=$(cat pom.xml | grep "^    <artifactId>.*</artifactId>$" | awk -F'[><]' '{print $3}')
echo $MVN_VERSION
echo $MVN_VERSION
echo $MVN_VERSION
echo $MVN_VERSION
log "INFO" "=================="
log "INFO" "=================="
log "INFO" "=================="
log "INFO" "=================="
log "INFO" "=================="
echo $MVN_ARTIFACT
echo $MVN_ARTIFACT
echo $MVN_ARTIFACT
echo $MVN_ARTIFACT

ZIP_FINAL_NAME="$MVN_ARTIFACT$SEPARATOR$MVN_VERSION$SEPARATOR$NOW$SEPARATOR$CIRCLE_BUILD_NUM$ZIP_EXTENSION"
echo $ZIP_FINAL_NAME
echo $ZIP_FINAL_NAME
echo $ZIP_FINAL_NAME
echo $ZIP_FINAL_NAME
echo $ZIP_FINAL_NAME
echo $ZIP_FINAL_NAME


log "INFO" "INFO PARAMS"
log "INFO" "=================="
log "INFO" "Zip name: $ZIP_FINAL_NAME"
log "INFO" "=================="


mvn clean package -q -DskipTests
rc=$?
if [[ $rc -ne 0 ]] ; then
  log "ERROR" "BUILD FAILURE";
  exit $rc
fi
mv target/api*.jar target/api.jar
zip -r -j  $ZIP_FINAL_NAME target/newrelic/newrelic.jar run.sh target/api.jar Procfile src/main/resources/newrelic.yml
zip -r  $ZIP_FINAL_NAME ./.ebextensions/





log "INFO" "=================="
log "INFO" "Zip Success ==> Zip name: $ZIP_FINAL_NAME"
log "INFO" "=================="


log "INFO" "=================="
log "INFO" "Trying to upload zip file to AWS S3"
log "INFO" "=================="


aws s3  cp $ZIP_FINAL_NAME "$S3_URL"

echo $ZIP_FINAL_NAME > workspace/echo-output

rc=$?
if [[ $rc -ne 0 ]] ; then
  log "ERROR" "Upload to s3 Failure";
  exit $rc
fi

