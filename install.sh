#!/bin/bash

script_path=`echo -e "$0" | rev | cut -d/ -f2- | rev;`;
destination="/etc/letsencrypt/scripts";

link="false";
if ! [[ -z "$1" ]]; then
  if [[ "$1" == "--link" ]]; then
    link="true";
  fi
fi

sudo="";
if ! [[ "$USER" == "root" ]]; then
  sudo="sudo ";
fi

${sudo}chmod 554 "$PWD/check-letsencrypt-certs.sh";

if ! [[ -d "$destination" ]]; then
  ${sudo}mkdir --parents --verbose "$destination"
fi

if [[ "$link" == "true" ]]; then
  echo "Linking $destination/check-letsencrypt-certs.sh to local file.";
  ${sudo}ln --symbolic --verbose "$PWD/check-letsencrypt-certs.sh" "$destination/check-letsencrypt-certs.sh";
else
  echo "Copying script to $destination";
  ${sudo}cp --update --verbose "$PWD/check-letsencrypt-certs.sh" "$destination";
fi
echo "-- Complete --";
