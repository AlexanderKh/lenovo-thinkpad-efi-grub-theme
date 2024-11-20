#! /usr/bin/env bash

set -o errexit

# Check if running as root or sudo
if [ $(id -u) -ne 0 ]
then
  echo "Please run this script as root or using sudo"
  exit 0
fi

THEME_DIR_NAME="lenovo-thinkpad-efi"
DIST_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CANCEL_INSTALLATION="Cancel installation"
DO_NOTHING="Do nothing"
PS3="Enter selection number: "

# Choose installation folder
LOCATION_BOOT="/boot/grub/themes"
LOCATION_USR="/usr/share/grub/themes"
echo ""
echo "Choose install location:"
select install_location in $LOCATION_BOOT $LOCATION_USR "$CANCEL_INSTALLATION"
do
  case "$install_location" in
    $LOCATION_BOOT | $LOCATION_USR)
      break
    ;;
    $CANCEL_INSTALLATION*)
      exit 0
    ;;
  esac
done

# Back up files to be modified
echo ""
if [[ ! -f /etc/default/grub.lenovoefi.bak ]]
then
  echo "Backing up /etc/default/grub"
  cp -an /etc/default/grub /etc/default/grub.lenovoefi.bak
else
  echo "/etc/default/grub.lenovoefi.bak already exists"
fi

# Copy theme
echo "Copying theme to $install_location"
mkdir -p "$install_location"
cp -ar --no-preserve=ownership "$DIST_DIR"/"$THEME_DIR_NAME" "$install_location"

# Patch /etc/default/grub
echo 'Patching /etc/default/grub'

THEME_TXT="$install_location"/"$THEME_DIR_NAME"/theme.txt
if grep -q "^GRUB_THEME=" /etc/default/grub
then
  ESCAPED_THEME_TXT=$(echo "$THEME_TXT" | sed 's|\/|\\\/|g')
  sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$ESCAPED_THEME_TXT\"|" /etc/default/grub
else
  echo "" >> /etc/default/grub
  echo "GRUB_THEME=\"$THEME_TXT\"" >> /etc/default/grub
fi

# update-grub
echo "Running update-grub"
update-grub

echo "OK"