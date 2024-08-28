#!/bin/bash
_GREP=/bin/grep
_LOGGER=/bin/logger
_ECHO=/bin/echo
_SERVICE=/sbin/service
_CHECKCONFIG=/sbin/chkconfig
_MV=/bin/mv
_CP=/bin/cp
_CHMOD=/bin/chmod
_CHOWN=/bin/chown
_SED=/bin/sed
_SEMANAGE=/usr/sbin/semanage
_RESTORECON=/sbin/restorecon
_CONFIGURE_SQL=/ericsson/3pp/mysql-openidm/bin/mysql-openidm_config.sh


info()
{
	${_LOGGER} -s -t ENM_OPENIDM -p user.notice "INFORMATION  ( %post ): $@"
}

error()
{
	${_LOGGER} -s -t ENM_OPENIDM -p user.err "ERROR  ( %post ): $@"
}

${_CHMOD} 775 /ericsson/enm/dumps

info "Running Service Group RPM postinstall"
##turn on openidm
info "Setting openidm chkconfig on"
${_CHECKCONFIG} openidm on
${_CHECKCONFIG} mysqld on

# Moving MySql database to persistent volume
${_CP} /var/lib/mysql/* /ericsson/mysql/
${_CHOWN} -R mysql:mysql /ericsson/mysql/
${_SED} -i 's/datadir=.*/datadir=\/ericsson\/mysql/g' /etc/my.cnf

# Selinux Updates
${_SEMANAGE} fcontext -a -t mysqld_db_t "/ericsson"
${_SEMANAGE} fcontext -a -t mysqld_db_t "/ericsson/mysql(/.*)?"
${_RESTORECON} -R -v /ericsson/
${_RESTORECON} -R -v /ericsson/mysql/


#Adding openidm and mysql start to rc.local in VM's
$_GREP -q "${_SERVICE} mysqld start" /etc/rc.local

if [ $? -ne 0 ] ;then

    $_ECHO "#Start mysqld on VM start-up
    ${_SERVICE} mysqld start" >> /etc/rc.local

fi


$_GREP -q "${_CONFIGURE_SQL}" /etc/rc.local

if [ $? -ne 0 ] ;then
    
    $_ECHO "#Configure MYQSL Users, privliages, and schemas
    . ${_CONFIGURE_SQL}" >> /etc/rc.local

fi


$_GREP -q "${_SERVICE} openidm start" /etc/rc.local
if [ $? -ne 0 ] ;then

    $_ECHO "#Start openidm on VM start-up
    ${_SERVICE} openidm start" >> /etc/rc.local

fi



