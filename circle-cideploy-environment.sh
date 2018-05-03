#!/usr/bin/env bash
#!/bin/bash


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

ZIP_FINAL_NAME=$(head -n 1 /tmp/workspace/echo-output)


log "INFO" "=================="
log "INFO" "Start Deploy"
log "INFO" "=================="


aws elasticbeanstalk update-environment --environment-name $ENVIRONMENT --version-label $ZIP_FINAL_NAME --region sa-east-1

rc=$?
if [[ $rc -ne 0 ]] ; then
  log "ERROR" "Deploy Failure";
  exit $rc
fi



##############
## End Main
##############
