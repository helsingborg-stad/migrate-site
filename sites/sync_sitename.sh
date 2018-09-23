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
export DOCROOT_PROD=/path/to/your/production/www/dir

# Beta enviroment
export DOCROOT_BETA=/path/to/your/beta/www/dir

# Production domain
export REPLACE_PROD_URL=domain.se

# Beta domain
export REPLACE_BETA_URL=beta.domain.se

# Path to production vhost file
export VHOST_PROD_PATH=/path/to/your/vhost/file

# Path to beta vhost file
export VHOST_BETA_PATH=/path/to/your/vhost/beta_file

#Path to sync
export SYNC_DIR=/path/to/your/sync_enviroments/sync

#Import Sync and replace script
source $SYNC_DIR/sync_replace.sh

