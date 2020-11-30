#!/bin/bash

HOSTNAME=$1
TAGS=$2

if [ -z ${HOSTNAME} ] || [ -z "$TAGS" ]; then
    echo "Usage $0 hostname tag1,tag2|all"
    echo
    echo Tags: db-software-19c, upgradeDB or all
    exit 1
fi

ENV=`echo ${HOSTNAME:2:1}|tr '[:upper:]' '[:lower:]'`

if [ ! -f hosts/${ENV}/${HOSTNAME}.yml ]; then
    echo "File hosts/${ENV}/${HOSTNAME}.yml does not exist. Create it first!"
    exit 1
fi

export ANSIBLE_ROLES_PATH=$PWD/roles/
export ANSIBLE_REMOTE_USER=${ENV}${USER}

echo "ansible-playbook -vvv -i "${HOSTNAME}," playbooks/oracledb.yml --ask-vault-pass --extra-vars=hosts/${ENV}/${HOSTNAME}.yml"
ansible-playbook -vv -i  "${HOSTNAME}," playbooks/oracledb.yml --private-key=private/${ENV}-ansible-tower.key  --ask-vault-pass --extra-vars "@hosts/${ENV}/${HOSTNAME}.yml"  --tags "${TAGS}"
