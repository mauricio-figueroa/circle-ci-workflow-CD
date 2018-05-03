#!/usr/bin/env bash


ZIP_FINAL_NAME=$(head -n 1 /tmp/workspace/echo-output)


git config --global user.email "sistemas@cash-online.com.ar"
git config --global user.name "Cash Online"
git tag -a "$ZIP_FINAL_NAME" -m "$ZIP_FINAL_NAME"
git push https://$CASH_BITBUCKET_USER:$CASH_BITBUCKET_PASSWORD@bitbucket.org/transconteam/cash-api.git --tags

rc=$?
if [[ $rc -ne 0 ]] ; then
  log "ERROR" "Git tag Failure";
  exit $rc
fi

