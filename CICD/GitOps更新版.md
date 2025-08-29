#### 重新配置pipeline脚本
```bash
trigger: { branches: { include: [ main ] } }
pr:       { branches: { include: [ main ] } }

variables:
  # 镜像（web）
  webRepo: 'docker.io/rayrayye/timeapp-web'
  dockerfilePath: 'Dockerfile'
  buildContext: '.'

  # 配置仓（GitHub）
  githubOrgRepo: 'RookieToExpert/az305'     # 形如 org/repo
  configPath: 'kubernetes&docker/timeapp-config/overlays/prod'
  configBranchPrefix: 'bump-web'

  # 版本号（独立于 api 的计数器）
  major: '1'
  counterKey: 'web-1'
  patch: $[ counter(variables['counterKey'], 0) ]
  version: '$(major).$(patch)'

stages:
- stage: Build
  displayName: Build & Push (web)
  jobs:
  - job: build
    pool: { vmImage: 'ubuntu-latest' }
    steps:
    - task: Docker@2
      displayName: Login Docker Hub
      inputs: { command: login, containerRegistry: 'toDockerHub' }

    - task: Docker@2
      displayName: Build+Push web:$(version)
      inputs:
        command: buildAndPush
        repository: '$(webRepo)'
        Dockerfile: '$(dockerfilePath)'
        buildContext: '$(buildContext)'
        tags: |
          $(version)

- stage: ConfigPR
  displayName: 'Create PR to bump web tag (GitOps)'
  dependsOn: Build
  jobs:
  - job: pr
    pool: { vmImage: 'ubuntu-latest' }
    steps:
    - script: |
        set -eux
        curl -L https://github.com/mikefarah/yq/releases/download/v4.44.3/yq_linux_amd64 -o /usr/local/bin/yq
        chmod +x /usr/local/bin/yq
        sudo apt-get update && sudo apt-get install -y gh
      displayName: Install yq & gh

    - script: |
        set -eux
        export GH_TOKEN="$(GITHUB_TOKEN)"
        git config --global user.name  "ado-bot"
        git config --global user.email "ado-bot@example.com"

        # 1) 克隆配置仓
        git clone "https://github.com/$(githubOrgRepo).git" configrepo
        cd configrepo

        # 2) 新建分支
        BR="$(configBranchPrefix)-$(version)-$(Build.BuildId)"
        git checkout -b "$BR"

        # 3) 修改 Kustomize 的 images[].newTag（只改 web）
        FILE="$(configPath)/kustomization.yaml"
        export IMG_NAME="$(webRepo)"
        export VERSION="$(version)"
        yq -i '(.images[] | select(.name == env(IMG_NAME))).newTag = env(VERSION)' "$FILE"

        echo "After change:" && yq '.images' "$FILE"

        git add "$FILE"
        git commit -m "chore(web): bump to $(version)"
        git push -u origin "$BR"

        # 4) 创建 PR（手动或自动合并均可）
        gh pr create \
          --repo "$(githubOrgRepo)" \
          --base main --head "$BR" \
          --title "Bump web to $(version)" \
          --body "Update web image tag to $(version) for GitOps" \
          --label "gitops"
      displayName: Bump web tag & open PR
      env:
        GITHUB_TOKEN: $(GITHUB_TOKEN)

```
