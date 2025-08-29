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

## 환경 설정

### Collection 생성

- Collection Name : Samsung Cloud Platform Resource Management

### Environment 생성

- Environment 이름 : Samsung Cloud Platform Environment

- Variables

| Variable | Type | Initial Value | Current Value |
|----------|------|---------------|---------------|
| base_url | default | https://virtualserver.kr-west1.e.samsungsdscloud.com | https://virtualserver.kr-west1.e.samsungsdscloud.com |
| auth_url | default | https://iam.e.samsungsdscloud.com/v1/endpoints | https://iam.e.samsungsdscloud.com/v1/endpoints |
| access_key | secret | 여기에 인증키 access-key 입력 | 여기에 인증키 access-key 입력 |
| access_secret_key | secret | 여기에 인증키 access-secret-key 입력 | 여기에 인증키 access-secret-key 입력 |
| region | default | kr-west1 | kr-west1 |
| vpc_name | default | VPC1 | VPC1 |
| vm_name | default | vm110w | vm110w |
| subnet_name | default | Subnet | Subnet |
| sg_name | default | bastionSG | bastionSG |

- Environment 활성화

### Collection Auth 설정

- Collection Auth
  - **Auth Type**: `AWS Signature`
  - **Add auth data to**: `Request Headers`
  - **AccessKey**: `{{access_key}}`
  - **SecretKey**: `{{access_secret_key}}`  
  - **AWS Region**: `kr-west1`
  - **Service Name**: `Samsung Cloud Platform v2`

- Scripts  
  Pre-req 탭에 아래 스크립트 입력

```javascript
// 현재 시간을 ISO 형식으로 생성
const now = new Date();
const amzDate = now.toISOString().replace(/[:\-]|\.\d{3}/g, '');
const dateStamp = amzDate.substr(0, 8);

// Environment 변수에 타임스탬프 저장
pm.environment.set('timestamp', amzDate);
pm.environment.set('date', dateStamp);

console.log('Pre-request script executed');
console.log('Timestamp:', amzDate);
```

## API 요청 생성

### Virtual Server 삭제 요청

- Request Name : `1-1. Get Virtual Server Infromation`

- Method : GET 
- URL : `{{base_url}}/compute/virtualserver/v1/servers`
- Params :
   - Key: `name`
   - Value: `{{vm_name}}`
- Headers  

| Key | Value |  
|-----|-------|  
| Content-Type | application/json |  
| X-Amz-Date | {{timestamp}} |

- Authorization
  
  - Inherit auth from parent

**Step 6**: 첫 API 호출 테스트
1. "Send" 버튼 클릭
2. 하단 Response 영역에서 결과 확인
3. Status가 200 OK인지 확인

## 리소스 삭제 순서

CLI 실습과 동일한 순서로 삭제를 진행해야 의존성 문제를 피할 수 있습니다:

1. Virtual Server 삭제
2. Public IP 삭제
3. Security Group 삭제
4. Subnet 삭제
5. Firewall 규칙 삭제
6. Internet Gateway 삭제
7. VPC 삭제

## 실제 리소스 삭제 API 요청 만들기

### 1. Virtual Server 삭제

#### 1-1. Virtual Server ID 조회 요청 만들기

**Step 1**: 새 요청 추가
1. Collection에서 "Add request" 클릭
2. Request 이름: `1-1. Get Virtual Server ID`

**Step 2**: 요청 설정
1. **Method**: `GET`
2. **URL**: `{{base_url}}/compute/virtualserver/v1/servers`
3. **Params** 탭:
   - Key: `name`, Value: `{{vm_name}}`

**Step 3**: Tests 스크립트 추가
1. "Tests" 탭 클릭
2. 다음 스크립트 입력:

```javascript
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

if (pm.response.code === 200) {
    const jsonData = pm.response.json();
    if (jsonData.servers && jsonData.servers.length > 0) {
        const serverId = jsonData.servers[0].id;
        pm.environment.set("server_id", serverId);
        console.log("Server ID saved:", serverId);
    }
}
```

**Step 4**: 요청 실행
1. "Send" 버튼 클릭
2. Response에서 서버 정보 확인
3. Console에서 "Server ID saved" 메시지 확인

#### 1-2. Virtual Server 삭제 요청 만들기

**Step 1**: 새 요청 추가
1. Collection에서 "Add request" 클릭  
2. Request 이름: `1-2. Delete Virtual Server`

**Step 2**: 요청 설정
1. **Method**: `DELETE`
2. **URL**: `{{base_url}}/compute/virtualserver/v1/servers/{{server_id}}`
3. Authorization은 자동으로 Collection에서 상속

**Step 3**: Tests 스크립트 추가
```javascript
pm.test("Status code is 200 or 404", function () {
    pm.expect(pm.response.code).to.be.oneOf([200, 404]);
});

if (pm.response.code === 404) {
    console.log("Virtual Server already deleted or not found");
} else if (pm.response.code === 200) {
    console.log("Virtual Server deleted successfully");
}
```

### 2. Public IP 삭제

#### 2-1. Public IP ID 조회 요청 만들기

**Step 1**: 새 요청 추가
1. Request 이름: `2-1. Get Public IP ID`

**Step 2**: 요청 설정  
1. **Method**: `GET`
2. **URL**: `{{base_url}}/networking/vpc/v1/public-ips`
3. **Params** 탭:
   - Key: `state`, Value: `Reserved`

**Step 3**: Tests 스크립트
```javascript
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

if (pm.response.code === 200) {
    const jsonData = pm.response.json();
    if (jsonData.public_ips && jsonData.public_ips.length > 0) {
        const publicIpId = jsonData.public_ips[0].id;
        pm.environment.set("public_ip_id", publicIpId);
        console.log("Public IP ID saved:", publicIpId);
    }
}
```

#### 2-2. Public IP 삭제 요청 만들기

**Step 1**: 새 요청 추가
1. Request 이름: `2-2. Delete Public IP`

**Step 2**: 요청 설정
1. **Method**: `DELETE`
2. **URL**: `{{base_url}}/networking/vpc/v1/public-ips/{{public_ip_id}}`

### 3. 나머지 리소스 삭제 요청 만들기

위와 동일한 패턴으로 나머지 리소스들도 생성하세요:

#### 3-1. Security Group ID 조회
- Request 이름: `3-1. Get Security Group ID`
- Method: `GET`
- URL: `{{base_url}}/networking/security-group/v1/security-groups`
- Params: Key=`name`, Value=`{{sg_name}}`

#### 3-2. Security Group 삭제  
- Request 이름: `3-2. Delete Security Group`
- Method: `DELETE`
- URL: `{{base_url}}/networking/security-group/v1/security-groups/{{sg_id}}`

#### 4-1. Subnet ID 조회
- Request 이름: `4-1. Get Subnet ID`
- Method: `GET` 
- URL: `{{base_url}}/networking/vpc/v1/subnets`
- Params: Key=`name`, Value=`{{subnet_name}}`

#### 4-2. Subnet 삭제
- Request 이름: `4-2. Delete Subnet`
- Method: `DELETE`
- URL: `{{base_url}}/networking/vpc/v1/subnets/{{subnet_id}}`

#### 5-1. Firewall ID 조회
- Request 이름: `5-1. Get Firewall ID`
- Method: `GET`
- URL: `{{base_url}}/networking/firewall/v1/firewalls`  
- Params: Key=`vpc_name`, Value=`{{vpc_name}}`, Key=`product_type`, Value=`IGW`

#### 5-2. Firewall 규칙 삭제
- Request 이름: `5-2. Delete Firewall Rules`
- Method: `DELETE`
- URL: `{{base_url}}/networking/firewall/v1/firewall-rules`
- Body (JSON): `{"firewall_id": "{{firewall_id}}"}`

#### 6-1. Internet Gateway ID 조회
- Request 이름: `6-1. Get IGW ID` 
- Method: `GET`
- URL: `{{base_url}}/networking/vpc/v1/internet-gateways`

#### 6-2. Internet Gateway 삭제
- Request 이름: `6-2. Delete Internet Gateway`
- Method: `DELETE`
- URL: `{{base_url}}/networking/vpc/v1/internet-gateways/{{igw_id}}`

#### 7-1. VPC ID 조회
- Request 이름: `7-1. Get VPC ID`
- Method: `GET`
- URL: `{{base_url}}/networking/vpc/v1/vpcs`
- Params: Key=`name`, Value=`{{vpc_name}}`

#### 7-2. VPC 삭제
- Request 이름: `7-2. Delete VPC`
- Method: `DELETE` 
- URL: `{{base_url}}/networking/vpc/v1/vpcs/{{vpc_id}}`

## Collection Runner를 이용한 일괄 실행

모든 요청을 만든 후, 순서대로 자동 실행할 수 있습니다.

**Step 1**: Collection Runner 열기
1. Collection 이름 옆의 "..." 클릭
2. "Run collection" 선택
3. 또는 상단의 "Runner" 버튼 클릭

**Step 2**: 실행 설정
1. **Collection**: 생성한 Collection 선택
2. **Environment**: SCP-Production 선택  
3. **Iterations**: 1
4. **Delay**: 2000ms (2초 간격)
5. **Data**: 필요시 CSV 파일 업로드

**Step 3**: 요청 순서 확인
삭제 순서가 올바른지 확인:
1. Virtual Server 관련 (1-1, 1-2)
2. Public IP 관련 (2-1, 2-2)
3. Security Group 관련 (3-1, 3-2)
4. Subnet 관련 (4-1, 4-2)  
5. Firewall 관련 (5-1, 5-2)
6. Internet Gateway 관련 (6-1, 6-2)
7. VPC 관련 (7-1, 7-2)

**Step 4**: 실행
1. "Run Samsung Cloud Platform Resource Management" 버튼 클릭
2. 실행 결과를 실시간으로 모니터링
3. 각 요청의 성공/실패 상태 확인

## Console 로그 확인하기

**Step 1**: Console 열기
1. Postman 하단의 "Console" 버튼 클릭
2. 또는 View → Show Postman Console

**Step 2**: 로그 확인
- Pre-request Script 실행 로그
- Tests 결과 및 저장된 변수들
- API 응답 상태 및 에러 메시지

## 자주 발생하는 문제 해결

### 1. 인증 오류 (401 Unauthorized)
**증상**: Authorization 헤더 관련 오류
**해결방법**:
1. Environment에서 access_key, access_secret_key 확인
2. Collection의 Authorization 설정 재확인
3. Pre-request Script 동작 확인

### 2. 리소스를 찾을 수 없음 (404 Not Found)  
**증상**: 삭제하려는 리소스가 없음
**해결방법**:
1. 조회 요청으로 리소스 존재 여부 확인
2. Environment 변수의 이름들이 실제와 일치하는지 확인
3. 이미 삭제된 리소스일 수 있음 (정상)

### 3. 의존성 충돌 (409 Conflict)
**증상**: 다른 리소스가 사용 중이라 삭제 불가
**해결방법**:
1. 삭제 순서 재확인
2. 의존 리소스 먼저 삭제
3. 잠시 대기 후 재시도

### 4. 변수가 설정되지 않음
**증상**: `{{variable_name}}` 형태로 URL에 표시
**해결방법**:
1. Environment 활성화 상태 확인
2. Tests 스크립트의 변수 설정 코드 확인
3. Console에서 변수 저장 로그 확인

## 참고 자료

- [Samsung Cloud Platform v2 API Reference](https://docs.e.samsungsdscloud.com/apireference/)
- [Postman Learning Center](https://learning.postman.com/)
- [AWS Signature Version 4 Signing Process](https://docs.aws.amazon.com/general/latest/gr/signature-version-4.html)