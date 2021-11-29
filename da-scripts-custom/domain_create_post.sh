#!/usr/bin/env bash

# /usr/local/directadmin/scripts/custom/domain_create_post.sh
# https://help.directadmin.com/item.php?id=28
function ReadINIfile()
{ 
	awk -F '=' '/\['config'\]/{a=1}a==1&&$1~/'$1'/{print $2;exit}' ~/.directslave
}
HOSTNS=`ReadINIfile HOSTNS`
DOMAINNAME=${domain}
DA_URL="https://`hostname`:2222"
DA_USERNAME='admin'
DA_PASSWORD=`ReadINIfile DA_PASSWORD`
OLD_IP4=`ReadINIfile OLD_IP4`
MAIN_IP4=`ReadINIfile MAIN_IP4`
MAIN_IP6=`ReadINIfile MAIN_IP6`

if [ -z ${MAIN_IP6} ]; then
    NEWSFP="value=\"v=spf1 a mx ip4:${MAIN_IP4} ~all\""
    SFPMX="value=\"v=spf1 a mx ip4:${OLD_IP4} ~all\""
else
    NEWSFP="value=\"v=spf1 a mx ip4:${MAIN_IP4} ip6:${MAIN_IP6} ~all\""
    SFPMX="value=\"v=spf1 a mx ip4:${OLD_IP4} ip6:${MAIN_IP6} ~all\""
fi

MXA="txtrecs0=name=${DOMAINNAME}.&${SFPMX}"

if [ `/usr/local/directadmin/directadmin v | awk '{print $3}' | cut -d. -f2,3` == '1.62' ]; then
    RESULT="$(curl -s -o /dev/null --data-urlencode "${MXA}" --data-urlencode "${NEWSFP}" --user "${DA_USERNAME}:${DA_PASSWORD}" "${DA_URL}/CMD_API_DNS_ADMIN?domain=${DOMAINNAME}&action=edit&type=TXT&name=${DOMAINNAME}.&json=yes")"
fi
# https://forum.directadmin.com/threads/how-to-get-list-of-all-domains.30997
DS_URL=`ReadINIfile DS_URL`
DS_USERNAME=`ReadINIfile DS_USERNAME`
DS_PASSWORD=`ReadINIfile DS_PASSWORD`

RESULT="$(curl -s -d "action=exists&domain=${DOMAINNAME}" -u "${DS_USERNAME}:${DS_PASSWORD}" "${DS_URL}/CMD_API_DNS_ADMIN")"

if [ -z `echo $RESULT |grep 'error=0&exists=1'` ]; then
    # not exists
    curl -s -o /dev/null -d "action=rawsave&domain=${DOMAINNAME}&hostname=${HOSTNS}" -u "${DS_USERNAME}:${DS_PASSWORD}" "${DS_URL}/CMD_API_DNS_ADMIN"
else
    # exists
    echo 1 >> /dev/null
fi
