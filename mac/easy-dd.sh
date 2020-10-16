#!/bin/bash
#  @title Easy-dd
#  @author Kamaran Layne <github.com/KamaranL>
#  @system MacOS
#  @description Helps with using DD to write a disk/image to another disk/image


__construct ()
{
  YES="([yY][eE][sS])|([yY])"
  NO="([nN][oO])|([nN])"
  LINEBR="\n------------------------------\n"
}

listDisk ()
{
  diskutil list
}

generateConfig ()
{
  until [[ "$confirmConfig" =~ $YES ]]; do
    read -p "Enter the full path of the destination you wish to WRITE to: " destinationLocation
    read -p "Enter the full path of the source you wish to READ from: " sourceLocation
    echo -e "$LINEBR"
    echo -e "Source:       $sourceLocation"
    echo -e "Destination:  $destinationLocation"
    echo -e "$LINEBR"
    read -p "Does this configuration look correct? (Y)es/(N)o: " confirmConfig
    echo -e "\n"
  done
}

runConfig ()
{
  sudo dd bs=1m if="$sourceLocation" of="$destinationLocation"; sync
}

main ()
{
  if [ "$USER" == "root" ]; then
    __construct
    listDisk
    generateConfig
    runConfig
  else
    echo "ERROR: Please run again as root."
    exit 1
  fi
}

main
