# Samsung Cloud Platform v2 Open API

## 실습 개요

Samsung Cloud Platform v2 Open API를 이용해서 [CLI 실습](./cli.md)에서 만든 자원을 삭제하는 실습 수행

## 사전 요구사항

1. Samsung Cloud Platform [CLI 실습](./cli.md) 수행하여 리소스 생성 완료

2. Samsung Cloud Platform Account 인증키

3. Account/User에 실습에 필요한 권한 부여 확인

## Open API 실습 도구 설치

### Postman 다운로드 및 설치

- [Postman 공식 사이트](https://www.postman.com/downloads/)에서 운영체제에 맞는 버전 다운로드 및 실행

## Environment 설정

- [Environment 설정 파일](Samsung%20Cloud%20Platform%20v2%20Variables.postman_environment.json) Import

- accessKey와 secretKey에 인증키 입력

## Collection 생성

- Collection Name : `SCP Resource Management`

## Request 생성

- Params : None
- Authorization : No Auth
- Headers

```config
Scp-Accesskey:{{accessKey}}
Scp-Signature:{{signature}}
Scp-Timestamp:{{timestamp}}
Scp-ClientType:Openapi
Accept-Language:ko-KR
Content-Type:application/json
```

- Body : None
- Scripts : Pre-request

```javascript
var timestamp = Date.now().toString();
var method = pm.request.method;
var url = pm.request.url.toString();
var accessKey = pm.environment.get("accessKey");
var secretKey = pm.environment.get("secretKey");
var clientType = "Openapi";

if (!secretKey) {
    console.error("Secret Key가 없습니다!");
    return;
}

console.log("CryptoJS available:", typeof CryptoJS);
console.log("CryptoJS.HmacSHA256 available:", typeof CryptoJS.HmacSHA256);

try {
    var message = method + url + timestamp + accessKey + clientType;
    console.log("Message to sign:", message);
    
    var hash = CryptoJS.HmacSHA256(message, secretKey);
    console.log("Hash generated:", hash);
    
    var signature = CryptoJS.enc.Base64.stringify(hash);
    console.log("Signature generated:", signature);
    
    pm.environment.set("timestamp", timestamp);
    pm.environment.set("signature", signature);
    
} catch (error) {
    console.error("서명 생성 오류:", error);
    console.error("Error details:", JSON.stringify(error));
}
```

## Virtual Server 조회

Method : GET

Request URL : `https://virtualserver.kr-west1.e.samsungsdscloud.com/v1/servers`

## Virtual Server 삭제

Method : DELETE

Request URL : `https://virtualserver.kr-west1.e.samsungsdscloud.com/v1/servers/{Server_ID}`

## Security Group 조회

Method : GET

Request URL : `https://security-group.kr-west1.e.samsungsdscloud.com/v1/security-groups`

## Security Group 삭제

Method : DELETE

Request URL : `https://security-group.kr-west1.e.samsungsdscloud.com/v1/security-groups/{security-group_ID}`

## Firewall 조회

Method : GET

Request URL : `https://firewall.kr-west1.e.samsungsdscloud.com/v1/firewalls`

## Firewall Rule 조회

Method : GET

Request URL : `https://firewall.kr-west1.e.samsungsdscloud.com/v1/firewalls/rules?firewall_id={Firewall_id}`

## Firewall Rule 삭제

Method : DELETE

Request URL : `https://firewall.kr-west1.e.samsungsdscloud.com/v1/firewalls/rules/{Firewall_rule_id}`

## Subnet 조회

Method : GET

Request URL : `https://vpc.kr-west1.e.samsungsdscloud.com/v1/subnets`

## Subnet 삭제

Method : DELETE

Request URL : `https://vpc.kr-west1.e.samsungsdscloud.com/v1/subnets/{subnet_ID}`

## Inetenet Gateway 조회

Method : GET

Request URL : `https://vpc.kr-west1.e.samsungsdscloud.com/v1/internet-gateways`

## Internet Gateway 삭제

Method : DELETE

Request URL : `https://vpc.kr-west1.e.samsungsdscloud.com/v1/internet-gateways/{internet-gateway_ID}`

## VPC 삭제

Method : DELETE

Request URL : `https://vpc.kr-west1.e.samsungsdscloud.com/v1/vpcs/{VPC_ID}`

## Public IP 조회

Method : GET

Request URL : `https://vpc.kr-west1.e.samsungsdscloud.com/v1/publicips`

## Public IP 삭제

Method : DELETE

Request URL : `https://vpc.kr-west1.e.samsungsdscloud.com/v1/publicips/{Public_IP_ID}`
