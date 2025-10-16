# Samsung Cloud Platform v2 Advance Terraform 실습

## 사전 요구사항

- Samsung Cloud Platform Account 인증키

- Account/User에 실습에 필요한 권한 부여 확인

## Samsung Cloud Platform v2 Terraform 환경 검토

- Samsung Cloud Platform v2 [Terraform Provider Registry](https://registry.terraform.io/providers/SamsungSDSCloud/samsungcloudplatformv2/latest) 방문

- Samsung Cloud Platform v2 [Terraform GitHub](https://github.com/SamsungSDSCloud/terraform-provider-samsungcloudplatformv2) 방문

### Terraform 다운로드 및 환경 설정

- Requirement

  - Terraform 1.1.11 [Download Here](https://releases.hashicorp.com/terraform/)
  - Go v1.22.5 [Download Here](https://go.dev/dl/)

- Local Setting 파일 구성

```cmd
cd %USERPROFILE%
mkdir "./scpconf"
cd ./scpconf

(
echo {
echo    "auth-url": "https://iam.dev2.samsungsdscloud.com/v1",
echo    "default-region": "kr-west1"
echo }
) > cli-config.json


(
echo {
echo    "access-key": "xxxxxxxxxxxxxx",
echo    "secret-key": "xxxxxxxxxxxxxx"
echo }
) > credential.json
```

- 환경변수 PATH에 작업 폴더 경로를 등록한 후 Windows 재부팅

## Terraform 기본 명령어 실행

```powershell

terraform version

```

## Terraform 기본 명령 실행

```powershell

terraform init

terraform validate

terraform plan
```

## Terraform 템플릿

- main.tf

- variables.tf

- outputs.tf

- modules/

## 사용자 변수 입력

- /advance_iac/terraform/variables.tf

```hcl
variable "my_public_ip" {
  type        = string
  description = "Your public IP address for SSH and RDP access"
  default     = "x.x.x.x/32" # You need to replace this value to your public IP address.
}
```

## Terraform apply 자원 배포

```powershell

terraform apply --auto-approve
```
