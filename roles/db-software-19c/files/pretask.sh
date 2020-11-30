for ORACLE_SID in `cat /etc/oratab | egrep -v "^agent|^#|oms"| cut -d':' -f 1`; do
source /usr/local/bin/nnip_oraenv ${ORACLE_SID}
sqlplus  /@${ORACLE_SID}_sysdba as sysdba<<EOF
shu immediate 
EOF
lsnrctl stop LISTENER_${ORACLE_SID}
done

