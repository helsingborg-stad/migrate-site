# migrate-site
Shell script to migrate a site

With this bash scripts you can sync one or more Beta wordpress installations with your Production environment.
The 
You need to set a few things before you can run the script.


## What?
The following things happen when you run the script.

1. Backing up the production database and beta database
2. Exports the production database and replace the beta database data with production data
3. Using WP CLI to replace static url's so they match beta enviroment
4. Creates a log file

## Dependencies
Linux/Unix Bash, WP CLI, MySQL

## Things you need to do
1. Edit config.sh and set the path to your vhost directory and www directory
2. Edit or add one or more site files in /sites directory. Edit directory names and domains.
