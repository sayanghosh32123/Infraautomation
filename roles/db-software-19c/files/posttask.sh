for ORACLE_SID in `cat /etc/oratab | egrep -v "^agent|^#|oms"| cut -d':' -f 1`; do
SQLCONN="/@${ORACLE_SID}_SYSDBA as sysdba"
source /usr/local/bin/nnip_oraenv ${ORACLE_SID}
lsnrctl start LISTENER_${ORACLE_SID}
sqlplus  /@${ORACLE_SID}_sysdba as sysdba<<EOF
startup mount 
EOF
DB_ROLE=$((printf "set heading off\nset feedback off \nset pages 0\nselect database_role from v\$database;\n")| sqlplus -s -l ${SQLCONN})
if [[  ${DB_ROLE} == "PRIMARY"  ]]; then
sqlplus /@${ORACLE_SID}_sysdba as sysdba << EOF
alter system set threaded_execution=FALSE scope=spfile;
shu immediate;
startup upgrade;
EOF
${ORACLE_HOME}/OPatch/datapatch -verbose
sqlplus /@${ORACLE_SID}_sysdba as sysdba << EOF
shu immediate;
startup;
@?/rdbms/admin/utlrp.sql
EOF
else
sqlplus /@${ORACLE_SID}_sysdba as sysdba << EOF
alter database recover managed standby database disconnect from session;
EOF
fi
done
