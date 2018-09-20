#!/bin/bash

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Script for Syncing Wordpress Production site with Beta enviroment
# Syncs databases and uploads dir
# By Helsingborg Stad
# ______________________________________________________________________________


# ------------------------------------------------------------------------------
# Set your site specific variables
# ------------------------------------------------------------------------------

# Production enviroment 
DOCROOT_PROD=/path/to/your/production/site/dir/

# Beta enviroment
DOCROOT_BETA=/path/to/your/beta/site/dir/

# Production domain
REPLACE_PROD_URL=domain.se

# Beta domain
REPLACE_BETA_URL=beta.domain

# Path to production vhost file
VHOST_PROD_PATH=/path/to/your/apache2/conf.d/production_vhost

# Path to beta vhost file
VHOST_BETA_PATH=/path/to/your/apache2/conf.d/beta_vhost


# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Yo dude, No need to change script bellow 
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


# ------------------------------------------------------------------------------
# Function to export the enviroment variables from vhost files
# @param VHOST_PATH
# @return void
# ------------------------------------------------------------------------------

get_enviroment_vars () {

	filename="$1"

	if [ ! -e "${filename}" ]; then
    		echo "No, No, No, No vhost ${filename} found, I will ignore this and go back to sleep."
    		exit 1
	fi

	grep -q ENVIRONMENT ${filename} && grep -q DATABASE_NAME ${filename} && grep -q DATABASE_HOST ${filename} && grep -q DATABASE_USERNAME ${filename} && grep -q DATABASE_PASSWORD ${filename}

	if [ $? != "0" ]; then
    		echo "Hmmmm, vhost file does not contain all necessary variables, ignore"
    		exit 1
	fi

	`cat ${filename} | grep SetEnv |sed -e 's/.*SetEnv \(.*\) \(.*\)$/export \1=\2/g'`
}


# ------------------------------------------------------------------------------
# Check if vhost exist
# ------------------------------------------------------------------------------

if [ ! -e ${VHOST_PROD_PATH} ]; then
    echo "Hallooooo! No vhost for docroot found, exit..."
    exit 1
fi

if [ ! -e ${VHOST_BETA_PATH} ]; then
    echo "Where is beta? No vhost for docroot_beta found, exit..."
    exit 1
fi


# ------------------------------------------------------------------------------
# Checking if production enviroment exist
# ------------------------------------------------------------------------------

get_enviroment_vars ${VHOST_PROD_PATH};
PROD_DATABASE_NAME=${DATABASE_NAME}

if [ -z $PROD_DATABASE_NAME ]; then
    echo ":-/ Could not find production database, exit..."
    exit 1
fi


# ------------------------------------------------------------------------------
# Checking if beta enviroment exist
# ------------------------------------------------------------------------------

get_enviroment_vars ${VHOST_BETA_PATH};
BETA_DATABASE_NAME=${DATABASE_NAME}

if [ -z $BETA_DATABASE_NAME ]; then
    echo "Where is that data? Could not find beta database, exit..."
    exit 1
fi


# ------------------------------------------------------------------------------
# Export production database and import into beta database
# ------------------------------------------------------------------------------

echo "Goodie! Now we Copy ${PROD_DATABASE_NAME} tables to ${BETA_DATABASE_NAME}..."

if ("${PROD_DATABASE_NAME}" == "${BETA_DATABASE_NAME}"); then
    echo "Production: ${PROD_DATABASE_NAME}"
    echo "Beta: ${BETA_DATABASE_NAME}"
    echo "Production database is same as Beta database, Check your vhost file, if enviroment variables has trailing whitespace."
    echo "There is a risk of deleting your production database, if this script continue. Exit procedure.... "
    exit 1
else
    mysql -e "drop database ${BETA_DATABASE_NAME}; create database ${BETA_DATABASE_NAME};"
    mysqldump ${PROD_DATABASE_NAME} | mysql ${BETA_DATABASE_NAME}
    echo "Great! Databases are in sync"
fi


# ------------------------------------------------------------------------------
# WP CLI Search and replace domains
# ------------------------------------------------------------------------------

CD_ROOT_PATH=${DOCROOT_BETA}"/"
cd $CD_ROOT_PATH


if (wp --url=http://"${REPLACE_BETA_URL}" core is-installed --network --allow-root --path=`${DOCROOT_BETA}/`); then
    wp search-replace --url=http://${REPLACE_PROD_URL} ${REPLACE_PROD_URL} ${REPLACE_BETA_URL} --path=`${DOCROOT_BETA}/` --recurse-objects --network --skip-columns=guid --skip-tables=wp_users --allow-root
    echo "WP CLI replaced url's in beta database (Multisite)";
else
    wp search-replace --url=http://${REPLACE_PROD_URL} ${REPLACE_PROD_URL} ${REPLACE_BETA_URL} --path=`${DOCROOT_BETA}/` --recurse-objects --skip-columns=guid --skip-tables=wp_users --allow-root
    echo "WP CLI replaced url's in beta database";
fi
wp cache flush --allow-root


# ------------------------------------------------------------------------------
# Sync files in production uploads to beta uploads
# ------------------------------------------------------------------------------

PROD_CONTENT_DIR="${DOCROOT_PROD}/wp-content/uploads"
BETA_CONTENT_DIR="${DOCROOT_BETA}/wp-content/uploads"

if [ -d ${PROD_CONTENT_DIR} ]; then
    echo "Copying content from ${PROD_CONTENT_DIR}..."
    rsync --delete -av ${PROD_CONTENT_DIR}/. ${BETA_CONTENT_DIR}/.
else
    echo "Hey, mr, mrs, miss.... Directory '${PROD_CONTENT_DIR}' not found, ignore..."
fi

echo "Woop woop! $ENVIRONMENT Beta is synced and up to date"
