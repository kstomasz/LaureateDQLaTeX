#!/bin/bash

if [ $# -lt 1 ]; then
  echo Usage: #0 [remote_repository_name]
  exit 1;
fi

git remote rename origin upstream
git remote add origin git:$1
git push origin master
git branch master --set-upstream-to origin/master
