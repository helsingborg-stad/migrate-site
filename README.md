# migrate-site
Shell script to migrate one ore more websites

With this bash scripts you can sync one or more Beta wordpress installations with your Production environment.
You need to set a few things before you can run the script.


## What?
The following things happen when you run the script.

1. Backing up the production database and beta database
2. Exports the production database and replace the beta database data with production data
3. Using WP CLI to replace static url's so they match beta enviroment
4. Creates a log file

## Dependencies
Linux/Unix Bash, WP CLI, Wordpress site/sites, MySQL

## Install - Things you need to do
1. Add following Enviroment variables to the vhost file:

    SetEnv ENVIRONMENT docroot_your_name
  
    SetEnv SYNC true

    SetEnv SYNCID website Id (example: my-kool-site)
  
    SetEnv SYNCDIR website-directory-name
  
    SetEnv DATABASE_NAME database-name
  
    SetEnv DATABASE_HOST localhost
  
    SetEnv DATABASE_USERNAME username
  
    SetEnv DATABASE_PASSWORD password

2. Create a file name config.sh, use the config-example.sh as a template and set the path to your vhost directory and www directory
3. Edit or add one or more site files in /sites directory. Use sitename.sh as example and edit directory names and domains. Save site configs with same name/value as vhost Enviroment variable SYNCID (example: my-kool-site.sh).

## Run script manualy
1. cd to migrate-site directory
2. Type: bash sync.sh to execute the script

## Run script once a week in cron
0 14 * * 1  yourusername  bash /path_to_this_app/sync.sh > /dev/null
