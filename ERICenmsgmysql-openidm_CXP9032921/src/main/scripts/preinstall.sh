#!/bin/bash

# GLOBAL VARIABLES
_BASENAME=/bin/basename
_LOGGER=/bin/logger
_GROUPADD=/usr/sbin/groupadd
_USERDEL=/usr/sbin/userdel
_USERADD=/usr/sbin/useradd
_USERMOD=/usr/sbin/usermod
_ID=/usr/bin/id
_ECHO=/bin/echo
_GETENT=/bin/getent
_ENM_GROUP=enm
_MYSQL_USER=mysql
_MYSQL_HOME=/home/mysql
_MYSQL_UID=318
_SCRIPT_NAME="${_BASENAME} ${0}"
_LOG_TAG="mysqlopenidm"
_OPENIDM_USER=openidm
_IDMMYSQL_UID=301
_IDMMYSQL_USER=idmmysql

# This function will print an error message to /var/log/messages
# Arguments:
#       $1 - Message
# Return: 0
#//////////////////////////////////////////////////////////////
error()

{
    ${_LOGGER}  -t ${_LOG_TAG} -p user.err "ERROR ( ${_SCRIPT_NAME} ): $1"
}

#//////////////////////////////////////////////////////////////
# This function will print an info message to /var/log/messages
# Arguments:
#       $1 - Message
# Return: 0
#/////////////////////////////////////////////////////////////

info()
{
    ${_LOGGER}  -t ${_LOG_TAG} -p user.notice "INFORMATION ( ${_SCRIPT_NAME} ): $1"
}

#//////////////////////////////////////////////////////////////
# This function will delete the jboss_user if it exists
# Arguments:
#       None
# Return: 0
#/////////////////////////////////////////////////////////////

remove_jboss_user()
{
    info "Removing jboss_user from VM if it exists"
    ${_ID} jboss_user > /dev/null 2>&1
    if [[ $? == 0 ]];
    then
        ${_USERDEL} jboss_user
    fi
}

#//////////////////////////////////////////////////////////////
# This function will create the mysql user
# Arguments:
#       None
# Return: 0
#/////////////////////////////////////////////////////////////

add_mysql_user_to_enm_group()

{
    info "Adding mysql user in ${_ENM_GROUP}"
    ${_USERMOD} -a -G ${_ENM_GROUP} ${_MYSQL_USER} > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        info "Addition of ${_MYSQL_USER} to the ${_ENM_GROUP} group was successful"
    else
        error "Addition of ${_MYSQL_USER} to the ${_ENM_GROUP} group failed"
    fi
}

update_mysql_user_uid()

{
    info "Updating mysql user in ID"
    ${_USERMOD} -u ${_MYSQL_UID} ${_MYSQL_USER} > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        info "Update of ${_MYSQL_USER} UID to ${_MYSQL_UID} was successful"
    else
        error "Update of ${_MYSQL_USER} UID to ${_MYSQL_UID} failed"
    fi
}

#//////////////////////////////////////////////////////////////
# This function will create the idmmysql user
# Arguments:
#       None
# Return: 0
#//////////////////////////////////////////////////////////////

create_idmmysql_group_and_user()

{
    info "Creating idmmysql group and user"
    ${_GROUPADD} -g ${_IDMMYSQL_UID} ${_IDMMYSQL_USER}
    ${_USERADD} -u ${_IDMMYSQL_UID} -g ${_IDMMYSQL_UID} ${_IDMMYSQL_USER} 
}

#//////////////////////////////////////////////////////////////
# This function will create the openidm user
# Arguments:
#       None
# Return: 0
#//////////////////////////////////////////////////////////////
create_openidm_user()
{
    if ! ${_GETENT} shadow ${_OPENIDM_USER} > /dev/null 2>&1; then
        ${_ECHO} "Adding user '${_OPENIDM_USER}'"
        info "Adding user '${_OPENIDM_USER}'"
        ${_USERADD} ${_OPENIDM_USER} -g 205
    fi
}

#//////////////////////////////////////////////////////////////
# Main
# Arguments:
#       None
# Return: 0
#/////////////////////////////////////////////////////////////

remove_jboss_user
add_mysql_user_to_enm_group
#update_mysql_user_uid
create_idmmysql_group_and_user
create_openidm_user
