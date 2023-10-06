#!/bin/sh
#RUN CLOUDFLARETEST

#此处修改CloudflareST程序储存的位置,并基于权限 chmod +x CloudflareST
folder=/root/cloudflare
$folder/CloudflareST -p 10 
rm $folder/getip.txt
cut -d ',' -f 1 $folder/result.csv | head -n 3 | tail -n 2 >> $folder/getip.txt
cat $folder/getip.txt


####全局变量
SecretId="修改为你的云API SecretId"
SecretKey="修改为你的云API SecretKey"
service="dnspod"
host="dnspod.tencentcloudapi.com"
region=""
action="ModifyRecord"
version="2021-03-23"
algorithm="TC3-HMAC-SHA256"
timestamp=$(date +%s)
date=$(date -u -d @$timestamp +"%Y-%m-%d")

###CURL1 修改记录
Domain=        #域名
SubDomain=     #子域名
RecordType=A      #记录模式(A,CHAME)
RecordLine=默认   #线路模式(默认,电信,联通...)
Value=$(cat $folder/getip.txt | sed -n '1p') #获取首个IP
TTL=3600
RecordId=       #记录ID
Status=ENABLE        #启动记录

payloadtmp="{\"Domain\":\"$Domain\",\"SubDomain\":\"$SubDomain\",\"RecordType\":\"$RecordType\",\"RecordLine\":\"$RecordLine\",\"Value\":\"$Value\",\"TTL\":$TTL,\"Status\":\"$ENABLE\",\"RecordId\":$RecordId}"
payload=$(echo $payloadtmp |iconv -t utf-8)
echo $payload
# 计算签名
http_request_method="POST"
canonical_uri="/"
canonical_querystring=""
canonical_headers="content-type:application/json; charset=utf-8\nhost:$host\nx-tc-action:$(echo $action | awk '{print tolower($0)}')\n"
signed_headers="content-type;host;x-tc-action"
hashed_request_payload=$(echo -n "$payload" | openssl sha256 -hex | awk '{print $2}')
canonical_request="$http_request_method\n$canonical_uri\n$canonical_querystring\n$canonical_headers\n$signed_headers\n$hashed_request_payload"
credential_scope="$date/$service/tc3_request"
hashed_canonical_request=$(printf "$canonical_request" | openssl sha256 -hex | awk '{print $2}')
string_to_sign="$algorithm\n$timestamp\n$credential_scope\n$hashed_canonical_request"
sign() {
    printf "$2" | openssl sha256 -hmac "$1" | awk '{print $2}'
}
secret_date=$(sign "TC3$SecretKey" "$date")
secret_date=$(printf $secret_date | xxd -r -p)
secret_service=$(sign "$secret_date" "$service")
secret_service=$(printf $secret_service | xxd -r -p)
secret_signing=$(sign "$secret_service" "tc3_request")
secret_signing=$(printf $secret_signing | xxd -r -p)
signature=$(printf "$string_to_sign" | openssl sha256 -hmac "$secret_signing" | awk '{print $2}')
authorization="$algorithm Credential=$SecretId/$date/$service/tc3_request, SignedHeaders=content-type;host;x-tc-action, Signature=$signature"
curl -XPOST "https://$host" -d "$payload" -H "Authorization: $authorization" -H "Content-Type: application/json; charset=utf-8" -H "Host: $host" -H "X-TC-Action: $action" -H "X-TC-Timestamp: $timestamp" -H "X-TC-Version: $version" -H "X-TC-Region: $region"

###CURL2 修改记录
Domain=
SubDomain=
RecordType=A
RecordLine=默认
Value=$(cat $folder/getip.txt | sed -n '2p') #IP2
TTL=3600
RecordId=
Status=ENABLE

payloadtmp="{\"Domain\":\"$Domain\",\"SubDomain\":\"$SubDomain\",\"RecordType\":\"$RecordType\",\"RecordLine\":\"$RecordLine\",\"Value\":\"$Value\",\"TTL\":$TTL,\"Status\":\"$ENABLE\",\"RecordId\":$RecordId}"
payload=$(echo $payloadtmp |iconv -t utf-8)
echo $payload
# 计算签名
http_request_method="POST"
canonical_uri="/"
canonical_querystring=""
canonical_headers="content-type:application/json; charset=utf-8\nhost:$host\nx-tc-action:$(echo $action | awk '{print tolower($0)}')\n"
signed_headers="content-type;host;x-tc-action"
hashed_request_payload=$(echo -n "$payload" | openssl sha256 -hex | awk '{print $2}')
canonical_request="$http_request_method\n$canonical_uri\n$canonical_querystring\n$canonical_headers\n$signed_headers\n$hashed_request_payload"
credential_scope="$date/$service/tc3_request"
hashed_canonical_request=$(printf "$canonical_request" | openssl sha256 -hex | awk '{print $2}')
string_to_sign="$algorithm\n$timestamp\n$credential_scope\n$hashed_canonical_request"
sign() {
    printf "$2" | openssl sha256 -hmac "$1" | awk '{print $2}'
}
secret_date=$(sign "TC3$SecretKey" "$date")
secret_date=$(printf $secret_date | xxd -r -p)
secret_service=$(sign "$secret_date" "$service")
secret_service=$(printf $secret_service | xxd -r -p)
secret_signing=$(sign "$secret_service" "tc3_request")
secret_signing=$(printf $secret_signing | xxd -r -p)
signature=$(printf "$string_to_sign" | openssl sha256 -hmac "$secret_signing" | awk '{print $2}')
authorization="$algorithm Credential=$SecretId/$date/$service/tc3_request, SignedHeaders=content-type;host;x-tc-action, Signature=$signature"
curl -XPOST "https://$host" -d "$payload" -H "Authorization: $authorization" -H "Content-Type: application/json; charset=utf-8" -H "Host: $host" -H "X-TC-Action: $action" -H "X-TC-Timestamp: $timestamp" -H "X-TC-Version: $version" -H "X-TC-Region: $region"
