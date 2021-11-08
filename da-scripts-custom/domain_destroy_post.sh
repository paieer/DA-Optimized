#!/usr/bin/env bash

# /usr/local/directadmin/scripts/custom/domain_destroy_post.sh
# https://help.directadmin.com/item.php?id=28
function ReadINIfile()
{ 
	awk -F '=' '/\['config'\]/{a=1}a==1&&$1~/'$1'/{print $2;exit}' ~/.directslave
}
DOMAINNAME=${domain}
DS_URL=`ReadINIfile DS_URL`
DS_USERNAME=`ReadINIfile DS_USERNAME`
DS_PASSWORD=`ReadINIfile DS_PASSWORD`


RESULT="$(curl -s -d "action=exists&domain=${DOMAINNAME}" -u "${DS_USERNAME}:${DS_PASSWORD}" "${DS_URL}/CMD_API_DNS_ADMIN")"
if [ -z `echo $RESULT |grep 'error=0&exists=1'` ]; then
    # not exists
    echo 1 >> /dev/null
else
    # exists delete
    curl -s -o /dev/null -c "/tmp/cookie" "${DS_URL}/login" -d "user=${DS_USERNAME}&pass=${DS_PASSWORD}&action=Login"
    curl -s -o /dev/null -b "/tmp/cookie" "${DS_URL}/dashboard/domains/remove?domain=${DOMAINNAME}"
fi
