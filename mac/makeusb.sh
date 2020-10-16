#!/bin/bash
#  @title Make USB
#  @author Kamaran Layne <github.com/KamaranL>
#  @system MacOS
#  @description Helps with creating a USB Installer for MacOS


__construct ()
{
  YES="([yY][eE][sS])|([yY])"
  NO="([nN][oO])|([nN])"
  LINEBR="\n------------------------------\n"
}

chooseInstallMedia ()
{
  until [[ "$confirmMedia" =~ $YES ]]; do
    read -p "Enter the volume name (case sensitive) of your External Media (USB): " externalMedia
    echo
    echo -e "External Media (USB) Path: /Volumes/$externalMedia \n"
    read -p "Does this path look correct? (Y)es/(N)o: " confirmMedia
    echo
  done


}

selectOS ()
{
  read -p '  0) Sierra
  1) High Sierra
  2) Mojave
  3) Catalina

  Select the Apple OS you are trying to create an installer USB for: ' osSelection
}

createUsb ()
{
  case $osSelection in
    "0")
      /Applications/Install\ macOS\ Sierra.app/Contents/Resources/createinstallmedia --volume /Volumes/$externalMedia;;
    "1")
      /Applications/Install\ macOS\ High\ Sierra.app/Contents/Resources/createinstallmedia --volume /Volumes/$externalMedia;;
    "2")
      /Applications/Install\ macOS\ Mojave.app/Contents/Resources/createinstallmedia --volume /Volumes/$externalMedia;;
    "3")
      /Applications/Install\ macOS\ Catalina.app/Contents/Resources/createinstallmedia --volume /Volumes/$externalMedia;;
  esac
}


main ()
{
  if [ "$USER" == "root" ]; then
    __construct
    chooseInstallMedia
    selectOS
    createUsb
  else
    echo "ERROR: Please run again as root."
    exit 1
  fi
}

main
