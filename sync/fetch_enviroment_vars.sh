#!/bin/bash

# ------------------------------------------------------------------------------
# Function to export the enviroment variables from vhost files
# @param VHOST_PATH
# @return void
# ------------------------------------------------------------------------------

get_enviroment_vars () {

    filename="$1"

    if [ ! -e "${filename}" ]; then
    printf "\033[1;31mSync error: No, No, No, No vhost ${filename} found, I will ignore this and go back to sleep.\033[0m\n"
    exit 1
    fi

    grep -q SYNCDIR ${filename} && grep -q SYNC ${filename} && grep -q SYNCID ${filename} && grep -q ENVIRONMENT ${filename} && grep -q DATABASE_NAME ${filename} && grep -q DATABASE_HOST ${filename} && grep -q DATABASE_USERNAME ${filename} && grep -q DATABASE_PASSWORD ${filename}

    if [ $? != "0" ]; then
    printf "\033[1;31mSync error: Hmmmm, vhost file does not contain all necessary variables, ignore\033[0m\n"
    exit 1
    fi

    `cat ${filename} | grep SetEnv |sed -e 's/.*SetEnv \(.*\) \(.*\)$/export \1=\2/g'`
}

