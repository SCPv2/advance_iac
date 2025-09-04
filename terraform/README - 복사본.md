# Samsung Cloud Platform v2 Terraform 101 실습 교재

## 📋 목차

- [실습 환경 준비](#실습-환경-준비)
- [Terraform 기초 개념](#terraform-기초-개념)
- [Samsung Cloud Platform v2 Provider 설정](#samsung-cloud-platform-v2-provider-설정)
- [실습 1: VPC 생성](#실습-1-vpc-생성)
- [실습 2: Subnet과 Internet Gateway 구성](#실습-2-subnet과-internet-gateway-구성)
- [실습 3: Security Group 설정](#실습-3-security-group-설정)
- [실습 4: Virtual Server 배포](#실습-4-virtual-server-배포)
- [Terraform 명령어 실습](#terraform-명령어-실습)
- [모듈 구조 이해](#모듈-구조-이해)
- [문제 해결 가이드](#문제-해결-가이드)
- [Best Practices](#best-practices)

---

## 🚀 실습 환경 준비

### 사전 요구사항

- **Terraform 설치**: v1.11 이상
- **Samsung Cloud Platform v2 계정** 및 API 인증키
- **Key Pair** 생성 완료
- **텍스트 에디터**: VS Code, Vim 등

### Terraform 설치 확인

```bash
# Terraform 버전 확인
terraform version

# 출력 예시:
# Terraform v1.11.0
# on windows_amd64
```

### 작업 디렉토리 준비

```bash
# 실습 디렉토리로 이동
cd D:\scpv2\advance_iac\terraform

# 파일 구조 확인
ls -la

# 예상 출력:
# main.tf
# variables.tf
# outputs.tf
# modules/
#   ├── vpc/
#   ├── internet_gateway/  
#   ├── subnet/
#   ├── security_group/
#   └── virtual_server/
```

---

## 📚 Terraform 기초 개념

### Infrastructure as Code (IaC)란?

- **정의**: 인프라를 코드로 정의하고 관리하는 방법론
- **장점**:
  - 버전 관리 가능
  - 반복 가능한 배포
  - 협업 및 리뷰 프로세스
  - 인프라 변경 추적

### Terraform 핵심 개념

#### 1. **Provider (프로바이더)**

클라우드 서비스와의 연결을 담당하는 플러그인

```hcl
terraform {
  required_providers {
    samsungcloudplatformv2 = {
      version = "1.0.3"
      source  = "SamsungSDSCloud/samsungcloudplatformv2"
    }
  }
  required_version = ">= 1.11"
}

provider "samsungcloudplatformv2" {
  # 인증 정보는 환경변수 또는 설정파일에서 자동으로 로드
}
```

#### 2. **Resource (리소스)**

생성하고 관리할 인프라 구성요소

```hcl
resource "samsungcloudplatformv2_vpc_vpc" "vpc1" {
  name        = "VPC1"
  cidr        = "10.1.0.0/16"
  description = "실습용 VPC"
  
  tags = {
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}
```

#### 3. **Variable (변수)**

재사용 가능한 값 정의

```hcl
variable "vpc_name" {
  type        = string
  default     = "VPC1"
  description = "VPC 이름"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.1.0.0/16"
  description = "VPC CIDR 블록"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "유효한 CIDR 블록을 입력해주세요."
  }
}
```

#### 4. **Output (출력)**

생성된 리소스 정보 노출

```hcl
output "vpc_id" {
  value       = samsungcloudplatformv2_vpc_vpc.vpc1.id
  description = "생성된 VPC의 ID"
}

output "vpc_cidr" {
  value       = samsungcloudplatformv2_vpc_vpc.vpc1.cidr
  description = "VPC CIDR 블록"
}
```

---

## 🔧 Samsung Cloud Platform v2 Provider 설정

### 인증 설정

Samsung Cloud Platform v2 API 사용을 위한 인증 정보 설정

```bash
# 환경 변수로 설정 (권장)
export SCP_ACCESS_KEY="your-access-key"
export SCP_SECRET_KEY="your-secret-key"
export SCP_REGION="kr-west-1"

# 또는 Windows에서
set SCP_ACCESS_KEY=your-access-key
set SCP_SECRET_KEY=your-secret-key
set SCP_REGION=kr-west-1
```

### Provider 버전 고정

```hcl
terraform {
  required_providers {
    samsungcloudplatformv2 = {
      version = "~> 1.0.3"  # 마이너 버전 자동 업데이트 허용
      source  = "SamsungSDSCloud/samsungcloudplatformv2"
    }
  }
  required_version = ">= 1.11"
}
```

---

## 📝 실습 1: VPC 생성

### 학습 목표

- VPC 리소스 생성 방법 이해
- 변수 사용법 습득
- Terraform 기본 워크플로우 실습

### VPC 모듈 구조 분석

```
modules/vpc/
├── main.tf       # 리소스 정의
├── variables.tf  # 입력 변수
└── outputs.tf    # 출력 값
```

### 📄 `modules/vpc/main.tf` 분석

```hcl
# Terraform 버전 및 Provider 요구사항
terraform {
  required_providers {
    samsungcloudplatformv2 = {
      version = "1.0.3"
      source  = "SamsungSDSCloud/samsungcloudplatformv2"
    }
  }
  required_version = ">= 1.11"
}

# VPC 리소스 정의
resource "samsungcloudplatformv2_vpc_vpc" "vpc1" {
  name        = var.name         # 변수에서 값 참조
  cidr        = var.cidr         # CIDR 블록 (예: 10.1.0.0/16)
  description = var.description  # VPC 설명
  
  # 태그를 통한 리소스 관리
  tags = {
    name = var.name
  }
}
```

### 📄 `modules/vpc/variables.tf` 분석

```hcl
variable "name" {
  type        = string
  default     = "VPC1"
  description = "VPC 이름"
}

variable "cidr" {
  type        = string
  default     = "10.1.0.0/16"
  description = "VPC CIDR 블록"
  
  validation {
    condition     = can(cidrhost(var.cidr, 0))
    error_message = "유효한 CIDR 블록을 입력해주세요."
  }
}

variable "description" {
  type        = string
  default     = "VPC1 created by Terraform"
  description = "VPC 설명"
}
```

### 📄 `modules/vpc/outputs.tf` 생성

```hcl
output "vpc_id" {
  value       = samsungcloudplatformv2_vpc_vpc.vpc1.id
  description = "생성된 VPC의 ID"
}

output "vpc_cidr" {
  value       = samsungcloudplatformv2_vpc_vpc.vpc1.cidr
  description = "VPC CIDR 블록"
}

output "vpc_name" {
  value       = samsungcloudplatformv2_vpc_vpc.vpc1.name
  description = "VPC 이름"
}
```

### 실습 명령어

```bash
# 1. Terraform 초기화
terraform init

# 2. 계획 확인 (VPC만 생성)
terraform plan -target=module.vpc

# 3. VPC 생성
terraform apply -target=module.vpc

# 4. 생성된 VPC 정보 확인
terraform output
```

---

## 🌐 실습 2: Subnet과 Internet Gateway 구성

### 학습 목표

- 네트워크 구성 요소 간의 관계 이해
- 의존성(dependency) 설정 방법 학습
- Subnet과 Internet Gateway 생성

### Internet Gateway 모듈 분석

#### 📄 `modules/internet_gateway/main.tf`

```hcl
terraform {
  required_providers {
    samsungcloudplatformv2 = {
      version = "1.0.3"
      source  = "SamsungSDSCloud/samsungcloudplatformv2"
    }
  }
  required_version = ">= 1.11"
}

# Internet Gateway 생성
resource "samsungcloudplatformv2_vpc_internet_gateway" "IGW_vpc1" {
  type        = var.type         # IGW 타입
  vpc_id      = var.vpc_id       # 연결할 VPC ID
  description = var.description  # 설명
}
```

#### 📄 `modules/internet_gateway/variables.tf`

```hcl
variable "vpc_id" {
  type        = string
  description = "Internet Gateway를 연결할 VPC ID"
}

variable "type" {
  type        = string
  default     = "IGW"
  description = "Internet Gateway 타입"
}

variable "description" {
  type        = string
  default     = "Internet Gateway created by Terraform"
  description = "Internet Gateway 설명"
}
```

### Subnet 모듈 분석

#### 📄 `modules/subnet/main.tf`

```hcl
terraform {
  required_providers {
    samsungcloudplatformv2 = {
      version = "1.0.3"
      source  = "SamsungSDSCloud/samsungcloudplatformv2"
    }
  }
  required_version = ">= 1.11"
}

# Public Subnet 생성
resource "samsungcloudplatformv2_vpc_subnet" "subnet01" {
  vpc_id      = var.vpc_id
  name        = var.name_sbn01
  type        = var.type_sbn01
  cidr        = var.cidr_sbn01
  description = "Public subnet for VPC1"
}

# Private Subnet 생성 (옵션)
resource "samsungcloudplatformv2_vpc_subnet" "subnet02" {
  vpc_id      = var.vpc_id
  name        = var.name_sbn02
  type        = var.type_sbn02
  cidr        = var.cidr_sbn02
  description = "Private subnet for VPC1"
}
```

### 메인 모듈에서의 의존성 설정

#### 📄 `main.tf`에서 모듈 호출

```hcl
# VPC 모듈
module "vpc" {
  source = "./modules/vpc"
}

# Internet Gateway 모듈 (VPC 생성 후)
module "internet_gateway" {
  source = "./modules/internet_gateway"
  vpc_id = module.vpc.vpc_id  # VPC 모듈의 출력값 사용
}

# Subnet 모듈 (Internet Gateway 생성 후)
module "subnet" {
  source     = "./modules/subnet"
  vpc_id     = module.vpc.vpc_id
  depends_on = [module.internet_gateway]  # 명시적 의존성
}
```

### 실습 명령어

```bash
# 1. Internet Gateway 생성
terraform plan -target=module.internet_gateway
terraform apply -target=module.internet_gateway

# 2. Subnet 생성
terraform plan -target=module.subnet
terraform apply -target=module.subnet

# 3. 전체 네트워크 구성 확인
terraform show | grep -E "(vpc|subnet|gateway)"
```

---

## 🔒 실습 3: Security Group 설정

### 학습 목표

- Security Group과 규칙 설정 방법
- 보안 모범 사례 적용
- 네트워크 접근 제어 구성

### Security Group 구조

- **Bastion Host**: 관리용 서버 (RDP/SSH 접근)
- **Application**: 웹/앱 서버용 보안 그룹
- **Database**: 데이터베이스 서버용 보안 그룹

### 📄 `modules/security_group/main.tf` 분석

```hcl
terraform {
  required_providers {
    samsungcloudplatformv2 = {
      version = "1.0.3"
      source  = "SamsungSDSCloud/samsungcloudplatformv2"
    }
  }
  required_version = ">= 1.11"
}

# Bastion Host용 Security Group
resource "samsungcloudplatformv2_security_group_security_group" "SGbastion" {
  name        = "SGbastion"
  description = "Security group for bastion host"
  loggable    = false
  
  tags = {
    Name = "SGbastion"
    Purpose = "Bastion access"
  }
}

# SSH 접근 허용 (관리자 IP만)
resource "samsungcloudplatformv2_security_group_security_group_rule" "allow_ssh" {
  security_group_id = samsungcloudplatformv2_security_group_security_group.SGbastion.id
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.my_ip  # 관리자 IP 주소만 허용
  description       = "Allow SSH from admin"
}

# RDP 접근 허용 (Windows 서버용)
resource "samsungcloudplatformv2_security_group_security_group_rule" "allow_rdp" {
  security_group_id = samsungcloudplatformv2_security_group_security_group.SGbastion.id
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = 3389
  port_range_max    = 3389
  remote_ip_prefix  = var.my_ip
  description       = "Allow RDP from admin"
}

# HTTP 아웃바운드 허용
resource "samsungcloudplatformv2_security_group_security_group_rule" "allow_http_out" {
  security_group_id = samsungcloudplatformv2_security_group_security_group.SGbastion.id
  direction         = "egress"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  description       = "Allow HTTP outbound"
}

# HTTPS 아웃바운드 허용
resource "samsungcloudplatformv2_security_group_security_group_rule" "allow_https_out" {
  security_group_id = samsungcloudplatformv2_security_group_security_group.SGbastion.id
  direction         = "egress"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  description       = "Allow HTTPS outbound"
}
```

### Security Group 규칙 설계 원칙

#### 1. **최소 권한 원칙 (Principle of Least Privilege)**

```hcl
# ❌ 잘못된 예: 모든 트래픽 허용
remote_ip_prefix = "0.0.0.0/0"

# ✅ 올바른 예: 특정 IP/대역만 허용
remote_ip_prefix = var.admin_ip  # 예: "203.0.113.1/32"
```

#### 2. **명확한 설명 추가**

```hcl
resource "samsungcloudplatformv2_security_group_security_group_rule" "web_to_db" {
  security_group_id = samsungcloudplatformv2_security_group_security_group.db_sg.id
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = 5432
  port_range_max    = 5432
  remote_group_id   = samsungcloudplatformv2_security_group_security_group.web_sg.id
  description       = "Allow PostgreSQL access from web servers"
}
```

### 실습 명령어

```bash
# 1. Security Group 계획 확인
terraform plan -target=module.security_group

# 2. Security Group 생성
terraform apply -target=module.security_group

# 3. 생성된 규칙 확인
terraform state show module.security_group.samsungcloudplatformv2_security_group_security_group.SGbastion
```

---

## 💻 실습 4: Virtual Server 배포

### 학습 목표

- 가상 서버 생성 방법
- 키 페어와 이미지 설정
- 네트워크 인터페이스 구성

### Virtual Server 구성 요소

#### 1. **Key Pair 설정**

```hcl
resource "samsungcloudplatformv2_virtualserver_keypair" "keypair" {
  name = var.name_keypair
}
```

#### 2. **포트 기반 IP 설정**

```hcl
resource "samsungcloudplatformv2_vpc_port" "vm_port" {
  name             = "vm111r-port"
  description      = "Port for vm111r"
  subnet_id        = var.subnet_id
  fixed_ip_address = var.fixed_ip  # 10.1.1.111
  security_groups  = [var.security_group_id]
}
```

#### 3. **Virtual Server 생성**

```hcl
resource "samsungcloudplatformv2_virtualserver_server" "server_001" {
  name           = var.name_vm      # vm111r
  state          = var.vmstate      # "ACTIVE"
  image_id       = "img-123456"     # 실제 이미지 ID로 교체 필요
  server_type_id = "stype-123456"   # 실제 서버 타입 ID로 교체 필요
  keypair_name   = samsungcloudplatformv2_virtualserver_keypair.keypair.name
  
  # 네트워크 설정
  networks = {
    interface_1 : {
      port_id = samsungcloudplatformv2_vpc_port.vm_port.id
    }
  }
  
  # 부팅 디스크 설정
  boot_volume = {
    size = 100
    type = "SSD"
    delete_on_termination = true
  }
  
  # 태그
  tags = {
    Name = var.name_vm
    Environment = "lab"
  }
}
```

### 이미지 및 서버 타입 조회

#### Data Source를 사용한 동적 조회

```hcl
# Rocky Linux 이미지 조회
data "samsungcloudplatformv2_virtualserver_images" "rocky" {
  os_distro = "rocky"
  status    = "active"
  
  filter {
    name      = "scp_os_version"
    values    = ["9.4"]
    use_regex = false
  }
}

# 조회된 이미지 ID 사용
locals {
  rocky_image_id = length(data.samsungcloudplatformv2_virtualserver_images.rocky.ids) > 0 ? data.samsungcloudplatformv2_virtualserver_images.rocky.ids[0] : ""
}

resource "samsungcloudplatformv2_virtualserver_server" "server_001" {
  # ... 기타 설정
  image_id = local.rocky_image_id
}
```

### 실습 명령어

```bash
# 1. 사용 가능한 이미지 확인 (Terraform 콘솔 사용)
terraform console
> data.samsungcloudplatformv2_virtualserver_images.rocky

# 2. Virtual Server 계획 확인
terraform plan -target=module.virtual_server

# 3. Virtual Server 생성
terraform apply -target=module.virtual_server

# 4. 생성된 서버 정보 확인
terraform output
```

---

## 🛠 Terraform 명령어 실습

### 기본 워크플로우

#### 1. **초기화 (Initialize)**

```bash
# 프로바이더 다운로드 및 설정
terraform init

# 실행 결과 예시:
# Initializing modules...
# Initializing the backend...
# Initializing provider plugins...
# - Finding samsungsdsdcloud/samsungcloudplatformv2 versions matching "1.0.3"...
# - Installing samsungsdsdcloud/samsungcloudplatformv2 v1.0.3...
# - Installed samsungsdsdcloud/samsungcloudplatformv2 v1.0.3
```

#### 2. **계획 수립 (Plan)**

```bash
# 전체 리소스 계획 확인
terraform plan

# 특정 리소스만 계획 확인
terraform plan -target=module.vpc

# 계획을 파일로 저장
terraform plan -out=tfplan

# 변수 파일 사용
terraform plan -var-file="prod.tfvars"
```

#### 3. **적용 (Apply)**

```bash
# 대화형 승인 모드
terraform apply

# 자동 승인 모드 (주의 필요!)
terraform apply -auto-approve

# 저장된 계획 실행
terraform apply tfplan

# 특정 리소스만 생성
terraform apply -target=module.vpc
```

#### 4. **상태 확인 (Show/State)**

```bash
# 현재 상태 전체 보기
terraform show

# 상태 파일의 리소스 목록
terraform state list

# 특정 리소스 상세 정보
terraform state show module.vpc.samsungcloudplatformv2_vpc_vpc.vpc1

# 출력 값만 보기
terraform output

# 특정 출력 값만 보기
terraform output vpc_id
```

#### 5. **검증 (Validate/Format)**

```bash
# 설정 파일 문법 검증
terraform validate

# 코드 포맷팅
terraform fmt

# 재귀적으로 모든 하위 디렉토리 포맷팅
terraform fmt -recursive
```

#### 6. **제거 (Destroy)**

```bash
# 전체 리소스 제거 계획
terraform plan -destroy

# 리소스 제거 실행
terraform destroy

# 특정 리소스만 제거
terraform destroy -target=module.virtual_server
```

### 고급 명령어

#### 7. **콘솔 (Console)**

```bash
# Terraform 콘솔 시작
terraform console

# 콘솔에서 실행 가능한 명령 예시:
# > var.vpc_name
# > module.vpc.vpc_id  
# > length(var.subnet_cidrs)
# > cidrhost("10.1.0.0/16", 10)
```

#### 8. **그래프 (Graph)**

```bash
# 의존성 그래프 생성
terraform graph | dot -Tpng > graph.png

# 또는 온라인 도구 사용
terraform graph > graph.dot
# graph.dot을 http://magjac.com/graphviz-visual-editor/에서 시각화
```

#### 9. **가져오기 (Import)**

```bash
# 기존 리소스를 Terraform 상태로 가져오기
terraform import module.vpc.samsungcloudplatformv2_vpc_vpc.vpc1 vpc-12345678

# 가져오기 전 빈 리소스 블록 작성 필요
```

---

## 📁 모듈 구조 이해

### 모듈이란?

Terraform 모듈은 재사용 가능한 Terraform 설정의 모음입니다.

### 권장 모듈 구조

```
modules/
├── vpc/
│   ├── main.tf       # 리소스 정의
│   ├── variables.tf  # 입력 변수
│   ├── outputs.tf    # 출력 값
│   └── README.md     # 모듈 문서
├── subnet/
├── security_group/
└── virtual_server/
```

### 모듈 설계 원칙

#### 1. **단일 책임 원칙**

```hcl
# ✅ 좋은 예: VPC만 담당하는 모듈
module "vpc" {
  source = "./modules/vpc"
  name   = "production-vpc"
  cidr   = "10.0.0.0/16"
}

# ❌ 나쁜 예: 너무 많은 책임을 가진 모듈
module "everything" {
  source = "./modules/everything"
  # VPC, Subnet, Server, Database 등 모든 것을 한 번에
}
```

#### 2. **명확한 인터페이스**

```hcl
# 📄 modules/vpc/variables.tf
variable "name" {
  type        = string
  description = "VPC 이름"
  
  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 20
    error_message = "VPC 이름은 1-20자 사이여야 합니다."
  }
}

variable "cidr" {
  type        = string
  description = "VPC CIDR 블록 (예: 10.1.0.0/16)"
  
  validation {
    condition     = can(cidrhost(var.cidr, 0))
    error_message = "유효한 CIDR 블록을 입력해주세요."
  }
}
```

#### 3. **유용한 출력값**

```hcl
# 📄 modules/vpc/outputs.tf
output "vpc_id" {
  value       = samsungcloudplatformv2_vpc_vpc.vpc1.id
  description = "생성된 VPC의 ID"
}

output "vpc_cidr" {
  value       = samsungcloudplatformv2_vpc_vpc.vpc1.cidr
  description = "VPC CIDR 블록"
}

# 민감한 정보는 sensitive로 표시
output "database_password" {
  value     = random_password.db_password.result
  sensitive = true
}
```

### 모듈 버전 관리

#### Git 태그를 사용한 버전 관리

```hcl
module "vpc" {
  source = "git::https://github.com/your-org/terraform-modules.git//vpc?ref=v1.0.0"
  
  name = "production-vpc"
  cidr = "10.0.0.0/16"
}
```

---

## 🔍 문제 해결 가이드

### 자주 발생하는 오류와 해결법

#### 1. **인증 오류**

```
Error: Failed to authenticate with Samsung Cloud Platform v2
```

**해결 방법:**

```bash
# 환경 변수 확인
echo $SCP_ACCESS_KEY
echo $SCP_SECRET_KEY
echo $SCP_REGION

# 환경 변수 재설정
export SCP_ACCESS_KEY="your-access-key"
export SCP_SECRET_KEY="your-secret-key"
export SCP_REGION="kr-west-1"
```

#### 2. **리소스 종속성 오류**

```
Error: resource depends on resource that cannot be determined until apply
```

**해결 방법:**

```hcl
# 명시적 depends_on 사용
resource "samsungcloudplatformv2_vpc_subnet" "subnet01" {
  vpc_id = samsungcloudplatformv2_vpc_vpc.vpc1.id
  
  depends_on = [
    samsungcloudplatformv2_vpc_internet_gateway.IGW_vpc1
  ]
}
```

#### 3. **상태 파일 잠금 오류**

```
Error: Error locking state: Error acquiring the state lock
```

**해결 방법:**

```bash
# 강제 잠금 해제 (주의!)
terraform force-unlock <LOCK_ID>

# 또는 다른 터미널에서 실행 중인 terraform 프로세스 종료
```

#### 4. **이미지 또는 서버 타입을 찾을 수 없는 오류**

```
Error: Image not found or Server type not available
```

**해결 방법:**

```hcl
# 데이터 소스로 동적 조회
data "samsungcloudplatformv2_virtualserver_images" "available" {
  status = "active"
  
  filter {
    name      = "os_distro"
    values    = ["rocky"]
    use_regex = false
  }
}

# 첫 번째 사용 가능한 이미지 사용
locals {
  image_id = length(data.samsungcloudplatformv2_virtualserver_images.available.ids) > 0 ? data.samsungcloudplatformv2_virtualserver_images.available.ids[0] : ""
}
```

### 디버깅 도구

#### 1. **로그 레벨 설정**

```bash
# 상세 로그 출력
export TF_LOG=DEBUG
terraform apply

# 로그를 파일로 저장
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform.log
terraform apply
```

#### 2. **상태 파일 분석**

```bash
# 상태 파일의 구조 확인
terraform show -json > state.json

# 특정 리소스의 속성 확인
terraform state show module.vpc.samsungcloudplatformv2_vpc_vpc.vpc1
```

---

## ✅ Best Practices

### 1. **프로젝트 구조**

```
terraform-project/
├── main.tf                 # 메인 설정
├── variables.tf            # 전역 변수
├── outputs.tf              # 전역 출력
├── terraform.tfvars        # 변수 값 (git 제외)
├── terraform.tfvars.example # 변수 예시
├── versions.tf             # 프로바이더 버전
├── modules/                # 로컬 모듈
│   ├── vpc/
│   ├── security_group/
│   └── virtual_server/
├── environments/           # 환경별 설정
│   ├── dev/
│   ├── staging/
│   └── prod/
└── README.md
```

### 2. **네이밍 컨벤션**

```hcl
# 리소스 네이밍: <service>_<type>_<name>
resource "samsungcloudplatformv2_vpc_vpc" "main_vpc" { }
resource "samsungcloudplatformv2_vpc_subnet" "public_subnet_1" { }
resource "samsungcloudplatformv2_virtualserver_server" "web_server_1" { }

# 변수 네이밍: 명사_형용사 순서
variable "vpc_cidr" { }
variable "subnet_public_cidrs" { }
variable "server_instance_type" { }
```

### 3. **보안 모범 사례**

```hcl
# ✅ 민감한 정보는 변수로 분리
variable "db_password" {
  type        = string
  description = "데이터베이스 비밀번호"
  sensitive   = true
}

# ✅ 최소 권한 원칙 적용
resource "samsungcloudplatformv2_security_group_security_group_rule" "ssh_access" {
  remote_ip_prefix = var.admin_cidr  # 특정 IP 대역만 허용
}

# ❌ 하드코딩하지 말 것
# password = "admin123"
```

### 4. **상태 파일 관리**

```hcl
# 원격 백엔드 사용 (권장)
terraform {
  backend "s3" {
    bucket = "your-terraform-state"
    key    = "vpc/terraform.tfstate"
    region = "kr-west-1"
  }
}
```

### 5. **코드 품질**

```bash
# 자동화된 검증
terraform fmt -check -recursive
terraform validate
terraform plan -detailed-exitcode

# 외부 도구 사용
tflint                    # Terraform 린터
terraform-docs           # 자동 문서화
checkov                  # 보안 및 모범 사례 검사
```

### 6. **변수 검증**

```hcl
variable "environment" {
  type        = string
  description = "배포 환경"
  
  validation {
    condition = contains(["dev", "staging", "prod"], var.environment)
    error_message = "환경은 dev, staging, prod 중 하나여야 합니다."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR 블록"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "유효한 CIDR 블록을 입력해주세요."
  }
  
  validation {
    condition     = can(regex("^10\\.", var.vpc_cidr))
    error_message = "사설 IP 대역(10.x.x.x)만 허용됩니다."
  }
}
```

---

## 🎯 실습 과제

### 과제 1: 기본 인프라 구성 (초급)

1. VPC (10.2.0.0/16) 생성
2. Public Subnet (10.2.1.0/24) 생성
3. Internet Gateway 연결
4. Bastion Host용 Security Group 생성
5. Rocky Linux 서버 1대 생성 (IP: 10.2.1.100)

### 과제 2: 다중 계층 아키텍처 (중급)

1. 3-tier 네트워크 구성
   - Web Subnet: 10.3.1.0/24
   - App Subnet: 10.3.2.0/24  
   - DB Subnet: 10.3.3.0/24
2. 각 계층별 Security Group 구성
3. 웹 서버 2대, 앱 서버 2대 배포
4. 적절한 네트워크 ACL 설정

### 과제 3: 모듈화 및 재사용 (고급)

1. 재사용 가능한 모듈 생성
2. 환경별(dev/prod) 변수 파일 구성
3. 원격 상태 백엔드 설정
4. CI/CD 파이프라인 통합

---

## 📚 추가 학습 자료

### 공식 문서

- [Terraform 공식 문서](https://www.terraform.io/docs)
- [Samsung Cloud Platform v2 Provider 문서](https://registry.terraform.io/providers/SamsungSDSCloud/samsungcloudplatformv2/latest/docs)

### 학습 리소스

- [Terraform 튜토리얼](https://learn.hashicorp.com/terraform)
- [Infrastructure as Code 모범 사례](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

### 커뮤니티

- [Terraform GitHub](https://github.com/hashicorp/terraform)
- [Terraform Community](https://discuss.hashicorp.com/c/terraform-core/27)

---

## 📞 지원 및 문의

실습 중 문제가 발생하거나 질문이 있으시면:

1. **문서 확인**: 이 README 파일의 문제 해결 가이드 참조
2. **로그 분석**: `TF_LOG=DEBUG` 환경 변수 설정 후 오류 로그 확인
3. **커뮤니티 질문**: Terraform 커뮤니티 포럼 활용
4. **기술 지원**: Samsung Cloud Platform v2 기술 지원 팀 연락

---

**Happy Terraforming! 🚀**
