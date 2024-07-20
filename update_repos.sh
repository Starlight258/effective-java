#!/bin/bash

# 커밋 후, 실행 권한을 부여 후 실행하기!
# chmod +x update_repos.sh 로
# ./update_repos.sh

# upstream에서 최신 변경사항 가져오기
git fetch upstream

# 로컬 main 브랜치로 전환
git checkout main

# upstream/main과 병합
git merge upstream/main

# upstream에 푸시
git push upstream main

# origin(포크된 저장소)에 푸시
git push origin main

echo "모든 작업이 완료되었습니다."
