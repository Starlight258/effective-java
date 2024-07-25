#!/bin/bash

# 커밋 후, 실행 권한을 부여 후 실행하기!
# chmod +x update_repos.sh 로 실행 권한 부여(맨 처음 한번만)
# ./update_repos.sh 터미널에 입력하기
# 참고: upstream은 원본 repo 주소로 등록하면 편하다.

# upstream에서 최신 변경사항 가져오기
git fetch upstream

# 로컬 main 브랜치로 전환
git checkout main

# upstream/main의 변경사항을 rebase
git rebase upstream/main

# upstream에 push
git push upstream main --force

# origin의 main 브랜치를 upstream의 main 브랜치와 동기화
git push origin main --force

echo "커밋 반영 완료"
