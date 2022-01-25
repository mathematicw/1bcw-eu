#!/usr/bin/env bash

# This script sets custom path to DB location during staging for upgrade (should be run after two official commands)
# Put this script into /etc/casper/
# give it a run permit
# set your own path to DB


# ! this script must be used with an argument $CASPER_VERSION. in format, like this:  sudo -u casper ./set_DB_path.sh 1_4_4


CONFIG_PATH="/etc/casper/$1"
CONFIG="$CONFIG_PATH/config.toml"

cd $CONFIG_PATH
sed -i 's@var/lib/casper/casper-node@mnt/data/casper-node@g' $CONFIG
# or :
sed -i 's/var\/lib\/casper\/casper-node/mnt\/data\/casper-node/g' $CONFIG
