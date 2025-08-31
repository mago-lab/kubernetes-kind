#!/bin/bash

# GHCR에서 test-whisper 배포 스크립트

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 함수 정의
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 환경 변수 확인
if [ -z "$GITHUB_USERNAME" ]; then
    log_error "GITHUB_USERNAME 환경 변수가 설정되지 않았습니다."
    echo "export GITHUB_USERNAME=your_github_username"
    exit 1
fi

if [ -z "$GITHUB_TOKEN" ]; then
    log_warn "GITHUB_TOKEN이 설정되지 않았습니다. Public 이미지로 간주합니다."
    USE_SECRET=false
else
    USE_SECRET=true
    log_info "Private 이미지로 배포합니다."
fi

# YAML 파일에서 GitHub 사용자명 치환
log_info "GitHub 사용자명을 $GITHUB_USERNAME으로 설정합니다."

# 임시 YAML 파일 생성
TEMP_YAML="deploy-ghcr-temp.yaml"
sed "s/{YOUR_GITHUB_USERNAME}/$GITHUB_USERNAME/g" deploy-ghcr.yaml > $TEMP_YAML

# Secret 생성 (필요한 경우)
if [ "$USE_SECRET" = true ]; then
    log_info "GHCR Secret을 생성합니다..."
    
    # 기존 Secret 삭제 (있다면)
    kubectl delete secret ghcr-secret --ignore-not-found=true
    
    # 새 Secret 생성
    kubectl create secret docker-registry ghcr-secret \
        --docker-server=ghcr.io \
        --docker-username="$GITHUB_USERNAME" \
        --docker-password="$GITHUB_TOKEN" \
        --docker-email="${GITHUB_EMAIL:-$GITHUB_USERNAME@example.com}"
    
    log_info "Secret이 생성되었습니다."
fi

# 배포 실행
log_info "test-whisper를 배포합니다..."
kubectl apply -f $TEMP_YAML

# 임시 파일 정리
rm -f $TEMP_YAML

# 배포 상태 확인
log_info "배포 상태를 확인합니다..."
kubectl get pods -l app=test-whisper-ghcr

log_info "Service 상태를 확인합니다..."
kubectl get services -l app=test-whisper-ghcr

log_info "배포가 완료되었습니다!"
echo ""
echo "다음 명령어로 상태를 확인할 수 있습니다:"
echo "  kubectl get pods -l app=test-whisper-ghcr"
echo "  kubectl logs -l app=test-whisper-ghcr"
echo "  kubectl get services -l app=test-whisper-ghcr"
echo ""
echo "NodePort: 30082 (기본), 30083 (Secret 사용)"
