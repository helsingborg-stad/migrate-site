#!/bin/bash

# -----------------------------------------------------------------------------------------
# Script to Back up and sync multiple sites and databses
# -----------------------------------------------------------------------------------------

# Path to vhost dir
VHOSTDIR=/path/to/your/vhost/file/dir

# Path to www 
SITEDIR=/path/to/www

# Path to where you put this sync script
SYNCDIR=$SITEDIR/path/to/sync/dir

# Path where you put all sync scripts
SCRIPTDIR=$SYNCDIR/scripts

# Path to sql backup up dir
BACKUPDIR=$SYNCDIR/backup

# Path to log dir
LOGDIR=$SYNCDIR/logs

# -----------------------------------------------------------------------------------------
# Fetch Enviroment variables
# -----------------------------------------------------------------------------------------

get_enviroment_vars () {

    filename="$1"

    if [ ! -e "${filename}" ]; then
        echo "No, No, No, No vhost ${filename} found, I will ignore this and go back to sleep."
        exit 1
    fi

    grep -q SYNCDIR ${filename} && grep -q SYNC ${filename} && grep -q SYNCID ${filename} && grep -q DATABASE_NAME ${filename} && grep -q DATABASE_HOST ${filename} && grep -q DATABASE_USERNAME ${filename} && grep -q DATABASE_PASSWORD ${filename}

    if [ $? != "0" ]; then
        echo "Hmmmm, vhost file does not contain all necessary variables, ignore"
        exit 1
    fi

    `cat ${filename} | grep SetEnv |sed -e 's/.*SetEnv \(.*\) \(.*\)$/export \1=\2/g'`
}


# -----------------------------------------------------------------------------------------
# Delete log files that are older than 30 days
# -----------------------------------------------------------------------------------------

find $LOGDIR/sync.log -mtime +30 -type f -delete

# -----------------------------------------------------------------------------------------
# Check if file not exist - Create new log file
# -----------------------------------------------------------------------------------------

filename=$SYNCDIR"/sync.log"

if [ ! -f $filename ]
then
	touch $filename
fi

# -----------------------------------------------------------------------------------------
# Run Sync script for all sites, backing up sql before sync
# -----------------------------------------------------------------------------------------

FILES=$VHOSTDIR/*
for f in $FILES
do

    if [ "$f" != "${VHOSTDIR}/catch-all" -a "$f" != "${VHOSTDIR}/catch-all-ssl" ]; then

        get_enviroment_vars "$f";

        if [ "$SYNC" != "false" ]; then

            printf "\033[0;32m ---------------------------------------------------------------- \033[0m\n"
            printf "\033[0;32m Export ${SYNCID} Beta and Production Database \033[0m\n"
            printf "\033[0;32m ---------------------------------------------------------------- \033[0m\n"

            cd "$SITEDIR/${SYNCDIR}/"
            wp db export --allow-root - | gzip >  $BACKUPDIR"/"${SYNCID}".sql.gz"
            wp db export --allow-root - | gzip >  $BACKUPDIR"/"${SYNCID}"_beta.sql.gz"

            printf "\033[0;31m ---------------------------------------------------------------- \033[0m\n"
            printf "\033[1;31m ${SYNCID} \033[0m\n"
            printf "\033[0;31m ---------------------------------------------------------------- \033[0m\n"

            sh $SCRIPTDIR"/sync_"$SYNCID".sh"
            echo "Time: $(date). Fredriksdal synced." >> $LOGDIR/sync.log
            wait
        fi
    fi

done

printf "\033[0;32m ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^  \033[0m\n"
printf "\033[0;33m   Tada . All script are executed and hopefully all sites are up todate \033[0m\n"
printf "\033[0;32m ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ \033[0m\n"

