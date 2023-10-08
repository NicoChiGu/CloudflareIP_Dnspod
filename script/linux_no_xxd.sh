#!/bin/sh
#RUN CLOUDFLARETEST
folder=$(pwd)
if [ -e $folder/CloudflareST ]
then
  echo "run"
else
  folder=/???/cloudflare #检测不到$PWD 则返回绝对路径
fi
 $folder/CloudflareST -p 10 
rm $folder/getip.txt
cut -d ',' -f 1 $folder/result.csv | head -n 3 | tail -n 2 > $folder/getip.txt
cat $folder/getip.txt


###全局变量
SecretId=
SecretKey=
service="dnspod"
host="dnspod.tencentcloudapi.com"
region=""
action="ModifyRecord"
version="2021-03-23"
algorithm="TC3-HMAC-SHA256"
timestamp=$(date +%s)
Language=zh-CN
date=$(date -u -d @$timestamp +"%Y-%m-%d")


##CURL1 修改记录
Domain=
SubDomain=
RecordType=A
RecordLine=默认
Value=$(cat $folder/getip.txt | sed -n '1p')
TTL=600
RecordId=
Status=ENABLE
payloadtmp="{\"Domain\":\"$Domain\",\"SubDomain\":\"$SubDomain\",\"RecordType\":\"$RecordType\",\"RecordLine\":\"$RecordLine\",\"Value\":\"$Value\",\"TTL\":$TTL,\"Status\":\"$Status\",\"RecordId\":$RecordId}"
payload=$(echo $payloadtmp |iconv -t utf-8)

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
secret_date=$(printf "$date" | openssl sha256 -hmac "TC3$SecretKey" | awk '{print $2}')
# 转二进制
secret_service=$(printf $service | openssl dgst -sha256 -mac hmac -macopt hexkey:"$secret_date" | awk '{print $2}')
secret_signing=$(printf "tc3_request" | openssl dgst -sha256 -mac hmac -macopt hexkey:"$secret_service" | awk '{print $2}')
signature=$(printf "$string_to_sign" | openssl dgst -sha256 -mac hmac -macopt hexkey:"$secret_signing" | awk '{print $2}')
authorization="$algorithm Credential=$SecretId/$credential_scope, SignedHeaders=$signed_headers, Signature=$signature"

curl -XPOST "https://$host" -d "$payload" -H "Authorization: $authorization" -H "X-TC-Language: zh-CN" -H "Content-Type: application/json; charset=utf-8" -H "Host: $host" -H "X-TC-Action: $action" -H "X-TC-Timestamp: $timestamp" -H "X-TC-Version: $version" -H "X-TC-Region: $region"

## CURL2 修改记录
Domain=
SubDomain=
RecordType=A
RecordLine=默认
Value=$(cat $folder/getip.txt | sed -n '2p') #IP2
TTL=600
RecordId=
payloadtmp="{\"Domain\":\"$Domain\",\"SubDomain\":\"$SubDomain\",\"RecordType\":\"$RecordType\",\"RecordLine\":\"$RecordLine\",\"Value\":\"$Value\",\"TTL\":$TTL,\"Status\":\"$Status\",\"RecordId\":$RecordId}"
payload=$(echo $payloadtmp |iconv -t utf-8)

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
secret_date=$(printf "$date" | openssl sha256 -hmac "TC3$SecretKey" | awk '{print $2}')
# 转二进制
secret_service=$(printf $service | openssl dgst -sha256 -mac hmac -macopt hexkey:"$secret_date" | awk '{print $2}')
secret_signing=$(printf "tc3_request" | openssl dgst -sha256 -mac hmac -macopt hexkey:"$secret_service" | awk '{print $2}')
signature=$(printf "$string_to_sign" | openssl dgst -sha256 -mac hmac -macopt hexkey:"$secret_signing" | awk '{print $2}')
authorization="$algorithm Credential=$SecretId/$credential_scope, SignedHeaders=$signed_headers, Signature=$signature"
 
curl -XPOST "https://$host" -d "$payload" -H "Authorization: $authorization" -H "X-TC-Language: zh-CN" -H "Content-Type: application/json; charset=utf-8" -H "Host: $host" -H "X-TC-Action: $action" -H "X-TC-Timestamp: $timestamp" -H "X-TC-Version: $version" -H "X-TC-Region: $region"
