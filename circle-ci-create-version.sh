#!/bin/bash

ENVIRONMENT=
NOW="$(date +'%Y-%m-%d')"



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
  echo "#################"
  exit 1
}

  function log() {
    echo "$(date +%Y-%m-%d'T'%H:%M:%S)" $@
  }


##############
## Main
##############

ZIP_FINAL_NAME=$(head -n 1 /tmp/workspace/echo-output)

echo $ZIP_FINAL_NAME

parseValidArguments $@
validateArguments
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



##############
## End Main
##############
