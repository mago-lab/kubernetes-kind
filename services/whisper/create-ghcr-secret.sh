#!/bin/bash

# GHCR Secret 생성 스크립트

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
    log_error "GITHUB_TOKEN 환경 변수가 설정되지 않았습니다."
    echo "export GITHUB_TOKEN=your_github_personal_access_token"
    exit 1
fi

# 기존 Secret 삭제 (있다면)
log_info "기존 GHCR Secret을 삭제합니다..."
kubectl delete secret ghcr-secret --ignore-not-found=true

# 새 Secret 생성
log_info "새 GHCR Secret을 생성합니다..."
kubectl create secret docker-registry ghcr-secret \
    --docker-server=ghcr.io \
    --docker-username="$GITHUB_USERNAME" \
    --docker-password="$GITHUB_TOKEN" \
    --docker-email="${GITHUB_EMAIL:-$GITHUB_USERNAME@example.com}"

log_info "GHCR Secret이 성공적으로 생성되었습니다!"

# Secret 확인
echo ""
log_info "생성된 Secret 정보:"
kubectl get secret ghcr-secret
echo ""
kubectl describe secret ghcr-secret
