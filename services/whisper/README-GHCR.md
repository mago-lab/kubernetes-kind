# GHCR에서 test-whisper 배포하기

이 문서는 GitHub Container Registry (GHCR)에서 `test-whisper` 이미지를 다운받아 Kubernetes에 배포하는 방법을 설명합니다.

## 파일 설명

- `deploy-ghcr.yaml`: GHCR에서 이미지를 다운받아 배포하는 YAML 파일
- `ghcr-secret.yaml`: GHCR 인증을 위한 Secret YAML 파일 (선택사항)
- `deploy-ghcr.sh`: 자동화된 배포 스크립트
- `create-ghcr-secret.sh`: GHCR Secret 생성 스크립트
- `deploy.yaml`: 로컬 이미지를 사용하는 기존 YAML 파일

## 사용 방법

### 1. 기본 배포 (Public 이미지인 경우)

```bash
# 기본 배포 (Secret 없이)
kubectl apply -f deploy-ghcr.yaml
```

**참고**: 이미지가 Public인 경우 Secret 없이도 배포할 수 있습니다.

### 2. Private 이미지인 경우 (Secret 사용)

#### 2.1 Secret 생성

```bash
# 방법 1: 스크립트 사용 (권장)
./create-ghcr-secret.sh

# 방법 2: 수동 생성
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=YOUR_GITHUB_USERNAME \
  --docker-password=$GITHUB_TOKEN \
  --docker-email=YOUR_EMAIL
```

#### 2.2 Secret을 사용한 배포

```bash
# Secret을 사용하여 배포
kubectl apply -f deploy-ghcr.yaml
```

### 3. 배포 확인

```bash
# Pod 상태 확인
kubectl get pods -l app=test-whisper-ghcr

# Service 확인
kubectl get services -l app=test-whisper-ghcr

# 로그 확인
kubectl logs -l app=test-whisper-ghcr
```

## 환경 변수 설정

배포 전에 다음 환경 변수를 설정해야 합니다:

```bash
export GITHUB_TOKEN=your_github_personal_access_token
export GITHUB_USERNAME=your_github_username
```

## 이미지 경로 형식

GHCR 이미지 경로는 다음과 같은 형식을 사용합니다:

```
ghcr.io/{GITHUB_USERNAME}/{REPOSITORY_NAME}:{TAG}
```

예시:
```
ghcr.io/johndoe/test-whisper:latest
ghcr.io/johndoe/test-whisper:v1.0.0
```

## 문제 해결

### 이미지 풀 에러

```bash
# Pod 이벤트 확인
kubectl describe pod <pod-name>

# 이미지 풀 시크릿 확인
kubectl get secrets
```

### 권한 문제

Private 이미지의 경우 다음을 확인하세요:
1. GitHub Personal Access Token이 올바른 권한을 가지고 있는지
2. Secret이 올바르게 생성되었는지
3. Deployment에서 `imagePullSecrets`가 올바르게 참조되고 있는지

## 포트 정보

- **Container Port**: 59005
- **Service Port**: 9005
- **NodePort**: 30082 (기본), 30083 (Secret 사용)

## 정리

```bash
# 배포 삭제
kubectl delete -f deploy-ghcr.yaml

# Secret 삭제 (필요한 경우)
kubectl delete secret ghcr-secret
```
