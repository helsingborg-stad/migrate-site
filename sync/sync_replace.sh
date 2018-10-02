#!/bin/bash

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Script for Syncing Wordpress Production site with Beta enviroment
# Syncs databases and uploads dir
# By Helsingborg Stad
# ______________________________________________________________________________

source $SYNCREPLACE/fetch_enviroment_vars.sh


# ------------------------------------------------------------------------------
# Check if vhost exist
# ------------------------------------------------------------------------------

if [ ! -e ${VHOST_PROD_PATH} ]; then
    printf "\033[1;31mSync error: Hallooooo! No vhost for docroot found, exit...\033[0m\n"
    exit 1
fi

if [ ! -e ${VHOST_BETA_PATH} ]; then
    printf "\033[1;31mSync error: Where is beta? No vhost for docroot_beta found, exit...\033[0m\n"
    exit 1
fi


# ------------------------------------------------------------------------------
# Checking if production enviroment exist
# ------------------------------------------------------------------------------

get_enviroment_vars ${VHOST_PROD_PATH};
PROD_DATABASE_NAME=${DATABASE_NAME}

if [ -z $PROD_DATABASE_NAME ]; then
    printf "\033[1;31mSync error: :-/ Could not find production database, exit...\033[0m\n"
    exit 1
fi


# ------------------------------------------------------------------------------
# Checking if beta enviroment exist
# ------------------------------------------------------------------------------

get_enviroment_vars ${VHOST_BETA_PATH};
BETA_DATABASE_NAME=${DATABASE_NAME}

if [ -z $BETA_DATABASE_NAME ]; then
    printf "\033[1;31mSync error: Where is that data? Could not find beta database, exit...\033[0m\n"
    exit 1
fi


# ------------------------------------------------------------------------------
# Export production database and import into beta database
# ------------------------------------------------------------------------------

printf "\033[0;32mSync: Your Vhost Enviroment variables looks great. So lets do some sync magic. \nWe start with copying ${PROD_DATABASE_NAME} tables to ${BETA_DATABASE_NAME}... \033[0m\n"

if [ "${PROD_DATABASE_NAME}" == "${BETA_DATABASE_NAME}" ]; then
    printf "\033[0;31mSync error: Production: ${PROD_DATABASE_NAME} \033[0m\n"
    printf "\033[0;31mSync error: Beta: ${BETA_DATABASE_NAME} \033[0m\n"
    printf "\033[1;31mSync error: Production database is same as Beta database, Check your vhost file, if enviroment variables has trailing whitespace. \033[0m\n"
    printf "\033[1;31mSync error: There is a risk of deleting your production database, if this script continue. Exit procedure....  \033[0m\n"
    exit 1
else
    mysql -e "drop database ${BETA_DATABASE_NAME}; create database ${BETA_DATABASE_NAME};"
    mysqldump ${PROD_DATABASE_NAME} | mysql ${BETA_DATABASE_NAME}
    printf "\033[0;32mSync: Great! Databases are in sync \033[0m\n"
fi


# ------------------------------------------------------------------------------
# WP CLI Search and replace domains
# ------------------------------------------------------------------------------

CD_ROOT_PATH=${DOCROOT_BETA}"/"
cd $CD_ROOT_PATH


if (wp --url=http://"${REPLACE_BETA_URL}" core is-installed --network --allow-root --path=`${DOCROOT_BETA}/`); then
    wp search-replace --url=http://${REPLACE_PROD_URL} ${REPLACE_PROD_URL} ${REPLACE_BETA_URL} --path=`${DOCROOT_BETA}/` --recurse-objects --network --skip-columns=guid --skip-tables=wp_users --allow-root --quiet
    printf "\033[0;32mSync: WP CLI replaced url's in beta database (Multisite) \033[0m\n";
else
    wp search-replace --url=http://${REPLACE_PROD_URL} ${REPLACE_PROD_URL} ${REPLACE_BETA_URL} --path=`${DOCROOT_BETA}/` --recurse-objects --skip-columns=guid --skip-tables=wp_users --allow-root --quiet
    printf "\033[0;32mSync: WP CLI replaced url's in beta database \033[0m\n";
fi
wp cache flush --allow-root --quiet


# ------------------------------------------------------------------------------
# Sync files in production uploads to beta uploads
# ------------------------------------------------------------------------------

PROD_CONTENT_DIR="${DOCROOT_PROD}/wp-content/uploads"
BETA_CONTENT_DIR="${DOCROOT_BETA}/wp-content/uploads"

if [ -d ${PROD_CONTENT_DIR} ]; then
    printf "\033[0;32mSync: Copying content from ${PROD_CONTENT_DIR}...\033[0m\n\033[0;36m"
    rsync --delete -av ${PROD_CONTENT_DIR}/. ${BETA_CONTENT_DIR}/.
else
    printf "\033[1;31mSync: Hey, mr, mrs, miss.... Directory '${PROD_CONTENT_DIR}' not found, ignore... \033[0m\n"
fi

printf "Sync: Good job :-D ! $ENVIRONMENT Beta is synced and up to date \033[0m\n"

