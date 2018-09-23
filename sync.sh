#!/bin/bash

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Back up and sync multiple sites and databses
# -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

# -----------------------------------------------------------------------------------------
# Config path
# -----------------------------------------------------------------------------------------

VHOSTDIR=/path/to/vhost/dir
SITEDIR=/path/to/www
SYNCDIR=$SITEDIR/syncdir
SCRIPTDIR=$SYNCDIR/sites
BACKUPDIR=$SYNCDIR/backup
LOGDIR=$SYNCDIR/logs

# -----------------------------------------------------------------------------------------
# Fetch Enviroment variables
# @param vhost file
# @return void
# -----------------------------------------------------------------------------------------

source $SYNCDIR/sync/fetch_enviroment_vars.sh


# -----------------------------------------------------------------------------------------
# Delete log files that are older than 30 days
# -----------------------------------------------------------------------------------------

find $LOGDIR/sync.log -mtime +30 -type f -delete

# -----------------------------------------------------------------------------------------
# Check if file not exist - Create new log file
# -----------------------------------------------------------------------------------------

logfile=$SYNCDIR/sync.log

if [ ! -f $logfile ]
then
	touch $logfile
fi

# -----------------------------------------------------------------------------------------
# Run Sync script for all sites, backing up sql before sync
# -----------------------------------------------------------------------------------------

VHOSTFILES=$VHOSTDIR/*
for f in $VHOSTFILES
do

    if [ "$f" != "${VHOSTDIR}/catch-all" -a "$f" != "${VHOSTDIR}/catch-all-ssl" ]; then

        get_enviroment_vars "$f";

        if [ "$SYNC" != "false" ]; then

            printf "\033[0;34m---------------------------------------------------------------- \033[0m\n"
            printf "\033[0;35m  Sync: Backup ${SYNCID} Beta and Production Database \033[0m\n"
            printf "\033[0;34m---------------------------------------------------------------- \033[0m\n"

            cd $SITEDIR/${SYNCDIR}/
            wp db export --allow-root - | gzip >  $BACKUPDIR/${SYNCID}.sql.gz
            wp db export --allow-root - | gzip >  $BACKUPDIR/${SYNCID}_beta.sql.gz

            printf "\033[0;31m---------------------------------------------------------------- \033[0m\n"
            printf "\033[1;31m  Sync: Lets do some syncmagic on ${SYNCID} \033[0m\n"
            printf "\033[0;31m---------------------------------------------------------------- \033[0m\n"

            bash $SCRIPTDIR/sync_$SYNCID.sh
            echo "Time: $(date). Fredriksdal synced." >> $LOGDIR/sync.log
            wait
        fi
    fi

done

printf "\033[0;32m ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^  \033[0m\n"
printf "\033[0;33m   Tada . All script are executed and hopefully all sites are up todate      \033[0m\n"
printf "\033[0;32m ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ \033[0m\n"

