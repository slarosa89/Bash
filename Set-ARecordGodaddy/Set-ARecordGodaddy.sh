domain=""
name=""
key=""
secret=""
auth="sso-key${key}:${secret}"
api_url="https://api.godaddy.com/v1/domains/${domain}/records/A/${name}"
ip_url="https://ipinfo.io/json"

ip=$(curl ${ip_url} | jq -r '.ip')
dnsip=$(curl -X GET -H"Authorization: sso-key ${key}:${secret}" ${api_url})



assoc2json() {
    declare -n v=$1
    printf '%s\0' "${!v[@]}" "${v[@]}" |
    jq -Rs 'split("\u0000") | . as $v | (length / 2) as $n | reduce range($n) as $idx ({}; .[$v[$idx]]=$v[$idx+$n])'
}

if [ "${ip}" != "${dnsip}"  ] ; then
        declare -A attributes
        attributes[ttl]="3600"
        attributes[data]="${ip}"
        curl -X PUT -H 'Content-Type: application/json' -H 'Accept: application/json' -H "Authorization: sso-key $key:$secret" "$api_url" -d "[{\"data\": \"$ip\"}]"
fi
