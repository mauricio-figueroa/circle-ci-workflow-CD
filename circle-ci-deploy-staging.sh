#!/usr/bin/env bash
#!/bin/bash

ENVIRONMENT=
NOW="$(date +'%Y-%m-%d')"
SEPARATOR="-"
ZIP_EXTENSION=".zip"
S3_URL="s3://elasticbeanstalk-sa-east-1-980074370134/com/cash/app/"


function parseValidArguments() {
  while :; do
    case $1 in

      -env|--environment) ENVIRONMENT="$2"; shift
      ;;
      -h|--help) help
      ;;
      *) break
    esac
    shift
  done
}


function validateArguments(){

  if [[ -z "$ENVIRONMENT" ]]; then
    echo "Environment name required ( Param: -env or--environment)"
    exit 1;
  fi
}


function help() {
  echo "#################"

  echo "Options you can use:"
  echo "  -h   | --help : this help"
  echo "  -zp  | --zipname :  name of zip file (required)"

  echo "#################"
  exit 1
}

  function log() {
    echo "$(date +%Y-%m-%d'T'%H:%M:%S)" $@
  }


##############
## Main
##############

parseValidArguments $@
validateArguments


MVN_VERSION=$( mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -v '\[')
MVN_ARTIFACT=$( mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.artifactId | grep -v '\[')

ZIP_FINAL_NAME="$MVN_ARTIFACT$SEPARATOR$NOW$SEPARATOR$CIRCLE_BUILD_NUM$ZIP_EXTENSION"
#ZIP_FINAL_NAME="$MVN_ARTIFACT$SEPARATOR$MVN_VERSION$SEPARATOR$NOW$SEPARATOR$ZIP_EXTENSION"
#ZIP_FINAL_NAME="0.0.1-SNAPSHOT-2018-04-24.zip"


log "INFO" "INFO PARAMS"
log "INFO" "=================="
log "INFO" "Zip name: $ZIP_FINAL_NAME"
log "INFO" "=================="


mvn clean package
rc=$?
if [[ $rc -ne 0 ]] ; then
  log "ERROR" "BUILD FAILURE";
  exit $rc
fi
mv target/api*.jar target/api.jar
zip -r -j  app.zip t target/newrelic/newrelic.jar run.sh target/api.jar Procfile src/main/resources/newrelic.yml
zip -r  app.zip ./.ebextensions/

log "INFO" "=================="
log "INFO" "Zip Success ==> Zip name: $ZIP_FINAL_NAME"
log "INFO" "=================="

log "INFO" "Trying to upload zip file to AWS S3"

mv app.zip "$ZIP_FINAL_NAME"
aws s3  cp "$ZIP_FINAL_NAME" "$S3_URL"

rc=$?
if [[ $rc -ne 0 ]] ; then
  log "ERROR" "Upload to s3 Failure";
  exit $rc
fi


log "INFO" "=================="
log "INFO" "Upload Success ==> Zip name: $ZIP_FINAL_NAME"
log "INFO" "=================="


log "INFO" "=================="
log "INFO" "Trying to create application version"
log "INFO" "=================="

aws elasticbeanstalk create-application-version --application-name cash-api --version-label "$ZIP_FINAL_NAME" --source-bundle "S3Bucket=elasticbeanstalk-sa-east-1-980074370134,S3Key=com/cash/app/$ZIP_FINAL_NAME" --region sa-east-1


rc=$?
if [[ $rc -ne 0 ]] ; then
  log "ERROR" "Application version create Failure";
  exit $rc
fi


log "INFO" "=================="
log "INFO" "Create application versionSuccess ==> app-version: $ZIP_FINAL_NAME"
log "INFO" "=================="

log "INFO" "=================="
log "INFO" "Start Deploy"
log "INFO" "=================="


aws elasticbeanstalk update-environment --environment-name $ENVIRONMENT --version-label $ZIP_FINAL_NAME --region sa-east-1

rc=$?
if [[ $rc -ne 0 ]] ; then
  log "ERROR" "Deploy Failure";
  exit $rc
fi



git tag -a "$ZIP_FINAL_NAME" -m "$ZIP_FINAL_NAME"
git push https://$CASH_BITBUCKET_USER:$CASH_BITBUCKET_PASSWORD@bitbucket.org/transconteam/cash-api.git --tags

rc=$?
if [[ $rc -ne 0 ]] ; then
  log "ERROR" "Git tag Failure";
  exit $rc
fi



##############
## End Main
##############
