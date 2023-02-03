#!/bin/bash

install_script_path=`echo -e "$0" | rev | cut -d/ -f2- | rev;`;
le_script_name="check-letsencrypt-certs";
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

echo ""
echo -e "Installing \e[38;5;33mBlueKnight\e[0m's $le_script_name script";

if ! [[ -d "$destination" ]]; then
  ${sudo}mkdir --parents --verbose "$destination"
  if ! [[ -d "$destination" ]]; then
    echo -e "\e[38;5;160mError 1\e[0m: Failed to make $destination";
    exit 1;
  fi
fi

if ! [[ -f "${install_script_path}/${le_script_name}.sh" ]]; then
    echo -e "\e[38;5;160mError 2\e[0m: can not locate script in the installer's directory.";
    exit 2;
fi

if [[ "$link" == "true" ]]; then
  echo "Linking ${destination}/${le_script_name}.sh to local file.";
  ${sudo}ln --symbolic --verbose "${PWD}/${le_script_name}.sh" "${destination}/${le_script_name}.sh";
else
  echo "Copying script to ${destination}";
  ${sudo}cp --update --verbose "${install_script_path}/${le_script_name}.sh" "${destination}";
fi

echo -e "-- \e[38;5;40mInstall Complete\e[0m --";
echo "";
exit 0;
