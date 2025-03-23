#!/bin/bash

#
#  Copyright (c) Oleksii Gaienko, 2021
#  Contact: galexsoftware@gmail.com
#
#  Module name: pre-deployment Bash scripts file
#  Author(s): Oleksii Gaienko 
#  Reviewer(s):
#
#  Abstract:
#     Bash script for automatic pre-deployment Docker(R) gsw_report project.
#

SETTINGS_FILE=.env
CURRENT_DIR=$PWD

if [ -f "$CURRENT_DIR/$SETTINGS_FILE" ]; then
  echo "Settings file exists!"
else
  echo "Settings file not find in current directory!"
  exit
fi

source $SETTINGS_FILE
SUDO=''
INSTALL_PATH=$DOCKERS_DATA_ROOTDIR/$COMPOSE_PROJECT_NAME
echo "Install path: $INSTALL_PATH"

PG_SVC_USER=pg-svc
PG_SVC_GROUP=postgres
MB_SVC_USER=mb-svc

# ref: https://ryanstutorials.net/bash-scripting-tutorial/bash-functions.php
rollback() {
  echo "Start rollback to previous state"
  $SUDO rm -rf "$INSTALL_PATH/"
  $SUDO userdel -fr $PG_SVC_USER
  echo "End rollback to previous state"
}

copy_file_to_dir() {
  # input arguments:
  # $1 - source file
  # $2 - destination directory

  # return values:
  # 0 - success copy
  # 1 - error copy
  # 2 - source not exist
  # 3 - destination not exist
  local source=$1
  local destination=$2

#  echo $source
#  echo $destination

  if test -r "$source"; then
    if test -d "$destination"; then
      $SUDO cp -f "$source" "$destination" || {
        echo "Error"
        return 1
        }
    else
      echo "error test -d"
      return 3
    fi
  else
    echo "error test -r"
    return 2
  fi
  return 0
}

# ref: https://askubuntu.com/a/30157/8698
if ! [ "$( id -u )" = 0 ]; then
  echo "The script need to be run as root!"
  echo "sudo $0 $*"
  SUDO='sudo'
fi

if [ -d "$INSTALL_PATH" ]; then
  echo "Remove $INSTALL_PATH container path..."
  $SUDO rm -rf "$INSTALL_PATH/"
fi

# ref: https://stackoverflow.com/questions/14810684/check-whether-a-user-exists
#getent group $PG_SVC_GROUP > /dev/null 2&>1
getent group $PG_SVC_GROUP > /dev/null
if [ $? -ne 0 ]; then
  echo "Group $PG_SVC_GROUP not exists"
  $SUDO groupadd $PG_SVC_GROUP >/dev/null 2>&1
  # echo $?
  if [ $? -ne 0 ]; then
    echo "Error create group $PG_SVC_GROUP"
    #rollback
    exit
  fi
  echo "Group $PG_SVC_GROUP succseful created"
else
  echo "Group $PG_SVC_GROUP exists"
fi

#getent passwd $PG_SVC_USER > /dev/null 2&>1
getent passwd $PG_SVC_USER > /dev/null
if [ $? -ne 0 ]; then
  echo "User $PG_SVC_USER not exists"
  $SUDO useradd -M -r -s /bin/false $PG_SVC_USER -G $PG_SVC_GROUP >/dev/null 2>&1
  # echo $?
  if [ $? -ne 0 -a $? -ne 9 ]; then
    echo "Error create user $PG_SVC_USER and add his to group $PG_SVC_GROUP"
    #rollback
    exit
  fi
  echo "User $PG_SVC_USER succseful created"
else
  echo "User $PG_SVC_USER exists"
fi

#getent passwd $MB_SVC_USER >/dev/null 2&>1
getent passwd $MB_SVC_USER > /dev/null
if [ $? -ne 0 ]; then
  echo "User $MB_SVC_USER not exists"
  $SUDO useradd -M -r -s /bin/false $MB_SVC_USER > /dev/null 2>&1
  # echo $?
  if [ $? -ne 0 -a $? -ne 9 ]; then
    echo "Error create user $MB_SVC_USER"
    #rollback
    exit
  fi
  echo "User $MB_SVC_USER succseful created"
else
  echo "User $MB_SVC_USER exists"
fi

# ref: https://askubuntu.com/questions/957275/creating-multiple-directories-at-once-using-a-shell-script-with-mkdir-and-variab
echo "Create directory tree for PostgreSQL..."
WORK_PATH=( "$INSTALL_PATH"/postgres/{config/init,db/{data,tbspaces},logs,import} )
$SUDO mkdir -pv "${WORK_PATH[@]}" >/dev/null 2>&1
# echo $?
if [ $? -ne 0 ]; then
  echo "Error create directory tree for PostgreSQL."
  #rollback
  exit
fi
echo "Directory tree for PostgreSQL successful created."

echo "Create directory tree for pgAdmin..."
WORK_PATH=( "$INSTALL_PATH"/pgadmin/{config/init,db,import,logs} )
$SUDO mkdir -pv "${WORK_PATH[@]}" >/dev/null 2>&1
# echo $?
if [ $? -ne 0 ]; then
  echo "Error create directory tree for pgAdmin."
  #rollback
  exit
fi
echo "Directory tree for pgAdmin successful created."

echo "Create directory tree for Reporting service..."
WORK_PATH=( "$INSTALL_PATH"/reporting/{config/init,db,plugins,logs} )
$SUDO mkdir -pv "${WORK_PATH[@]}" >/dev/null 2>&1
# echo $?
if [ $? -ne 0 ]; then
  echo "Error create directory tree for Reporting service."
  #rollback
  exit
fi
echo "Directory tree for Reporting service successful created."

echo "Copy PostgreSQL DB init file data to init directory..."
echo "$INSTALL_PATH/postgres/config/init"
FILE_TO_COPY=$CURRENT_DIR/postgres/initdb.sh
DEST_DIR=$INSTALL_PATH/postgres/config/init/
copy_file_to_dir "$FILE_TO_COPY" "$DEST_DIR"
case $? in
  0) echo "PostgreSQL DB init file success copied to init directory."
      ;;
  1) echo "Error copy PostgreSQL DB init file to init directory"
      rollback
      exit
      ;;
  2) echo "Error copy PostgreSQL DB init file to init directory"
      rollback
      exit
      ;;
  3) echo "Error copy PostgreSQL DB init file to init directory - destination directory not exists"
      rollback
      exit
      ;;
esac

echo "Change owner for PostgreSQL work directory..."
$SUDO chown -R $PG_SVC_USER:$PG_SVC_USER "$INSTALL_PATH/postgres" >/dev/null 2>&1
# echo $?
if [ $? -ne 0 ]; then
  echo "Error change owner for PostgreSQL work directory"
  #rollback
  exit
fi
echo "Owner for PostgreSQL work directory succseful changed."

echo "Change owner for Reporting service directory..."
$SUDO chown -R $MB_SVC_USER:$MB_SVC_USER "$INSTALL_PATH/reporting" >/dev/null 2>&1
# echo $?
if [ $? -ne 0 ]; then
  echo "Error change owner for Reporting service directory"
  #rollback
  exit
fi
echo "Owner for Reporting service directory succseful changed."

echo "Change group for PostgreSQL import directory..."
$SUDO chgrp $PG_SVC_GROUP "$INSTALL_PATH/postgres/import" >/dev/null 2>&1
# echo $?
if [ $? -ne 0 ]; then
  echo "Error change group for PostgreSQL import directory"
  #rollback
  exit
fi
echo "Owner for PostgreSQL group directory succseful changed."

echo "Change permisions for PostgreSQL import directory..."
$SUDO chmod 775 "$INSTALL_PATH/postgres/import" >/dev/null 2>&1
# echo $?
if [ $? -ne 0 ]; then
  echo "Error change permisions for PostgreSQL import directory"
  #rollback
  exit
fi
echo "Permisions for PostgreSQL import directory succseful changed."

echo "Change owner for pgAdmin work directory..."
$SUDO chown -R 5050:5050 "$INSTALL_PATH/pgadmin" >/dev/null 2>&1
# echo $?
if [ $? -ne 0 ]; then
  echo "Error change owner for pgAdmin work directory"
  #rollback
  exit
fi
echo "Owner for pgAdmin work directory succseful changed."

echo
echo "PostgreSQL Service account info:"
$SUDO cat /etc/passwd | grep $PG_SVC_USER
echo
echo "Reporting Service account info:"
$SUDO cat /etc/passwd | grep $MB_SVC_USER
echo
echo "gsw_reports pre-install script end succseful"

exit 0
