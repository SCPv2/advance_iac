# Samsung Cloud Platform v2 CLI(Command Line Interface) 연습

## 실습 개요

Samsung Cloud Platform v2 CLI를 이용해서 VPC 내에 Virtual Server 만들고, 사용자의 PC에서 Virtual Server에 접속하는 실습을 수행한다.

## 사전 요구사항

1. Samsung Cloud Platform Account 인증키

2. Account/User에 실습에 필요한 권한 부여 확인

3. Virtual Server Keypair

4. Samsung Cloud Platorm CLI 설치 및 구성

    - [Samsung Cloud Paltform v2 Documentation](https://docs.e.samsungsdscloud.com/clireference/cli-common/)에서 다운로드

    - 작업 폴더에 scp-cli.exe 를 이동하고 이름을 scpcli.exe로 변경
    - 환경변수 PATH에 작업 폴더 경로를 등록한 후 Windows 재부팅
    - cli-config.json 파일 생성(인증키 정보 입력 필요)

```cmd
cd %USERPROFILE%
mkdir ./scp
cd ./scp
(
echo {
echo     "auth_url": "https://iam.e.samsungsdscloud.com/v1/endpoints",
echo     "access_key": "인증키 access-key 입력",
echo     "access_secret_key": "인증키 access-secret-key 입력",
echo     "default_scp_region": "kr-west1"
echo }
) > cli-config.json
```

## VPC 생성

VPC 생성

```powershell
scpcli vpc vpc create --name "VPC1" --cidr "10.1.0.0/16"
```

VPC 조회

```powershell
scpcli vpc vpc list --name "VPC1"
```

## Internet Gateway 및 Firewall 생성

VPC ID를 직접 입력해서 생성

```powershell
scpcli vpc internet-gateway create --vpc_id "앞서 만든 VPC ID 입력" --type "IGW" --firewall_enabled "true"
```

VPC ID를 조회해서 생성

```powershell
$vpcId = (scpcli vpc vpc list --name VPC1 -f json | ConvertFrom-Json).id; scpcli vpc internet-gateway create --vpc_id $vpcId --type "IGW" --firewall_enabled "true"
```

Internet Gateway와 Firewall 정보 조회

```powershell
scpcli vpc internet-gateway list
scpcli firewall firewall list
```

## Subnet 생성

VPC ID를 직접 입력해서 생성

```powershell
scpcli vpc subnet create --name "Subnet" --vpc_id "앞서 만든 VPC ID 입력" --cidr "10.1.1.0/24" --type "GENERAL"
```

VPC ID를 조회해서 생성

```powershell
$vpcId = (scpcli vpc vpc list --name VPC1 -f json | ConvertFrom-Json).id; scpcli vpc subnet create --name "Subnet" --vpc_id $vpcId --cidr "10.1.1.0/24" --type "GENERAL"
```

Subnet 조회

```powershell
scpcli vpc subnet list
```  

## Security Group 생성

Virtual Server에 연결할 Security Group 생성

```powershell
scpcli security-group security-group create --name "bastionSG"  
```

Security Group에 규칙 추가

직접 Security Group ID를 입력해서 생성

```powershell
scpcli security-group security-group-rule create --security_group_id "앞서 만든 Security Group ID 입력" --direction "ingress" --protocol "tcp" --port_range_min "3389" --port_range_max "3389" --remote_ip_prefix "사용하고 있는 PC의 Public IP 입력"
```

Security Group ID를 조회해서 생성

```powershell
$publicIp = "사용하고 있는 PC의 Public IP 주소 입력"; $sgId = (scpcli security-group security-group list --name bastionSG -f json | ConvertFrom-Json).id; scpcli security-group security-group-rule create --security_group_id $sgId --direction "ingress" --protocol "tcp" --port_range_min "3389" --port_range_max "3389" --remote_ip_prefix $publicIp
```

## Virtual Server 생성

- 서버 이미지 목록 조회

```powershell
scpcli virtualserver image list > vmimage.txt
```

- 서버 타입 목록 조회

```powershell
scpcli virtualserver server type list > servertype.txt
```

- Virtual Server에 연결할 Public IP 생성

```powershell
scpcli vpc public-ip create --type "IGW"
```

- Virtual Server 생성

```powershell
scpcli virtualserver server create --name "vm110w" --image_id "Virtual Server 생성에 사용할 운영체제의 이미지 ID 입력" --server_type_id "s1v1m2" --networks '{\"public_ip_id\": \"앞서 만든 Public IP의 ID 입력 \", \"subnet_id\": \"앞서 만든 Subnet의 ID 입력 \"}' --security_groups "앞서 만든 Serurity Group ID 입력" --keypair_name "mykey" --volumes '{\"boot_index\" : 0, \"delete_on_termination\": false, \"size\": 32, \"source_type\": \"image\", \"type\": \"SSD\"}'
```

## Internet Gateway Firewall 규칙 추가

직접 설정값을 입력하여 생성

```powershell
scpcli firewall firewall-rule create --status "ENABLE" --source_address "사용하고 있는 PC의 Public IP 주소 입력" --service '{\"service_type\": \"TCP\", \"service_value\": \"3389\"}' --direction "INBOUND" --destination_address 10.1.1.0/24 --action "ALLOW" --firewall_id "IGW Firewall ID 입력"
```

ID를 조회하여 생성

```powershell
$publicIp = "사용하고 있는 PC의 Public IP 주소 입력";$fwId = (scpcli firewall firewall list --vpc_name VPC1 --product_type "IGW" -f json | ConvertFrom-Json).id; scpcli firewall firewall-rule create --status "ENABLE" --source_address $publicIp --service '{\"service_type\": \"TCP\", \"service_value\": \"3389\"}' --direction "INBOUND" --destination_address "10.1.1.0/24" --action "ALLOW" --firewall_id $fwId
```

## 리소스 정리

[Open API 실습](openapi.md)을 수행하지 않을 경우 아래의 명령을 실행하여 생성한 자원 삭제

직접 ID를 입력하여 삭제

```powershell
# 서버 삭제
scpcli virtualserver server delete --server-id "Virtual Server의 ID 입력"

# Public IP 삭제
scpcli vpc public-ip delete --public-ip-id "Public IP의 ID 입력"

# Security Group 삭제
scpcli security-group security-group delete --security-group-id "Security Group의 ID 입력"

#Firewall 규칙 삭제
scpcli firewall firewall-rule delete --firewall_rule_id "Firewall 규칙의 ID 입력"

# Subnet 삭제
scpcli vpc subnet delete --subnet-id "Subnet ID 입력"

# VPC 삭제
scpcli vpc vpc delete --vpc-id "VPC ID 입력"
```

자동으로 ID를 조회하여 삭제

```powershell

# Virtual Server 삭제
$vmId = (scpcli virtualserver server list --name vm110w -f json | ConvertFrom-Json).id; scpcli virtualserver server delete --server_id $vmId

# Public IP 삭제
$publicipId = (scpcli vpc public-ip list --state Reserved -f json | ConvertFrom-Json).id; scpcli vpc public-ip delete --public_ip_id $publicipId

# Security Group 삭제
$sgId = (scpcli security-group security-group list --name bastionSG -f json | ConvertFrom-Json).id; scpcli security-group security-group delete --security_group_id $sgId

# Subnet 삭제
$subnetId = (scpcli vpc subnet list --name Subnet -f json | ConvertFrom-Json).id; scpcli vpc subnet delete --subnet_id $subnetId

# Firewall 규칙 삭제
$fwId = (scpcli firewall firewall list --vpc_name VPC1 --product_type "IGW" -f json | ConvertFrom-Json).id; scpcli firewall firewall-rule delete --firewall_id $fwId

# Internet Gateway 삭제
$igwId = (scpcli vpc internet-gateway list -f json | ConvertFrom-Json).id; scpcli vpc internet-gateway delete --internet_gateway_id $igwId

# VPC 삭제
$vpcId = (scpcli vpc vpc list --name VPC1 -f json | ConvertFrom-Json).id; scpcli vpc vpc delete --vpc_id $vpcId
```
