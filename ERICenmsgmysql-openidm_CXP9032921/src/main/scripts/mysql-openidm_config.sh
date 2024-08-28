#!/bin/bash
# Try to set the password using the actual password
mysql -u root -pMysqlAdm01 -e "SET PASSWORD FOR root@localhost = PASSWORD('MysqlAdm01');"
# If the command returns other than 0, the password has not been set yet
if [[ $? -ne 0 ]];
then
    mysql -u root -e "SET PASSWORD FOR root@localhost = PASSWORD('MysqlAdm01');"
fi

# Check if db exists
db_exists=$(mysql -u root -pMysqlAdm01 -s -N -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='openidm'")
# If and empty string is returned, run the script to create the db
if [[ -z "$db_exists" ]];
then
    #Create users, grant permissions and create Openidm tables
    mysql -u root "-pMysqlAdm01"</ericsson/3pp/mysql-openidm/bin/mysql_openidm.sql
fi
