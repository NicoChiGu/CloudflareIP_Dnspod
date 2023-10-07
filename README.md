# CloudflareIP Dnspod

本方法基于 [signature-process-demo](https://github.com/TencentCloud/signature-process-demo) 以及 [CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest) 结合而成

测试环境位于Deiban/Ubuntu

此方法需要先进行一次记录的添加,使用API方式修改记录的IP地址。
###
### 使用方法:
- 1、安装OpenSSL XXD `sudo apt install openssl xxd` [下载运行程序](https://github.com/XIU2/CloudflareSpeedTest/releases/latest)
- 2、修改脚本
-   - 本脚本将[CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest)中的CloudflareST二进制文件放置于`/root/cloudflare`中，可以手动修改`folder`变量到你安装的位置
    - 修改`SecretId` `SecretKey` 的变量值 [不知道在哪？点这里获取](https://console.cloud.tencent.com/cam/capi)
    - 修改脚本中 "CURL1 修改记录"下的

| 变量名 | 意义 | 参数值 |
| :-------------: | :-------------: | :-------------: |
| Domain | 注册域名 | Domain |
| SubDomain | 子域名 | XXX.Domain |
| RecordType | 记录模式 | A,CHAME |
| RecordLine | 线路模式 | 默认,电信,联通... |
| Value | 值(IP、域名) | 此参数无需修改,从[CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest)中获取|
| TTL | TTL值 | 600-604800 |
| RecordId | 记录ID | [获取方式]() |
| Status | 记录状态(启用/暂停) | ENABLE |

- 3、运行脚本
- 4、基于脚本权限,配合crontab和systemd可以定时进行IP替换
### 如何获取RecordID
- 访问腾讯云 [云API](https://console.cloud.tencent.com/api/explorer?Product=dnspod&Version=2021-03-23&Action=DescribeRecordList)
- 填写domain和subdomain 找到之前添加的Value值,就可以定位RecordId
- ![image](https://github.com/NicoChiGu/CloudflareIP_Dnspod/assets/34607782/06542ee6-7f0f-48f2-aa09-6cba1419577f)


