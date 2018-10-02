#!/bin/bash

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Back up and sync multiple sites and databses
# -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

source config.sh

export SYNCDIR=$SITEDIR/sync_enviroments
export SYNCREPLACE=$SYNCDIR/sync
export SCRIPTDIR=$SYNCDIR/sites
export BACKUPDIR=$SYNCDIR/backup
export LOGDIR=$SYNCDIR/logs

# -----------------------------------------------------------------------------------------
# Fetch Enviroment variables
# @param vhost file
# @return void
# -----------------------------------------------------------------------------------------

source $SYNCREPLACE/fetch_enviroment_vars.sh

# -----------------------------------------------------------------------------------------
# Delete log files that are older than 30 days
# -----------------------------------------------------------------------------------------

find $LOGDIR/sync.log -mtime +30 -type f -delete

# -----------------------------------------------------------------------------------------
# Check if file not exist - Create new log file
# -----------------------------------------------------------------------------------------

logfile=$LOGDIR/sync.log

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
        if [[ $SYNCID ]]; then
            if [ "$SYNC" != "false" ]; then

                printf "\033[0;34m---------------------------------------------------------------- \033[0m\n"
                printf "\033[0;35m  Sync: Backup ${SYNCID} Beta and Production Database \033[0m\n"
                printf "\033[0;34m---------------------------------------------------------------- \033[0m\n"

                cd $SITEDIR/${SYNCDIR}/

                mkdir -p $BACKUPDIR

                wp db export --allow-root - | gzip >  $BACKUPDIR/${SYNCID}.sql.gz
                wp db export --allow-root - | gzip >  $BACKUPDIR/${SYNCID}_beta.sql.gz

                printf "\033[0;31m---------------------------------------------------------------- \033[0m\n"
                printf "\033[1;31m  Sync: Lets do some syncmagic on ${SYNCID} \033[0m\n"
                printf "\033[0;31m---------------------------------------------------------------- \033[0m\n"

                source $SCRIPTDIR/sync_$SYNCID.sh

                export DOCROOT_PROD=$SITEDIR/$PRODWWW
                export DOCROOT_BETA=$SITEDIR/$BETAWWW
                export REPLACE_PROD_URL=$PRODURL
                export REPLACE_BETA_URL=$BETAURL
                export VHOST_PROD_PATH=$VHOSTDIR/$PRODVHOST
                export VHOST_BETA_PATH=$VHOSTDIR/$BETAVHOST

                source $SYNCREPLACE/sync_replace.sh

                echo "Time: $(date). $SYNCID synced." >> $LOGDIR/sync.log
                wait
            fi
        fi
    fi

done

printf "\033[0;32m ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^  \033[0m\n"
printf "\033[0;33m   Tada . All script are executed and hopefully all sites are up todate \033[0m\n"
printf "\033[0;32m ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ ^—^ \033[0m\n"

exit 1
