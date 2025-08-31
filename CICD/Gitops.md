## 将kubernetes集群放到Github中：

![alt text](image-6.png)

#### 将当前YAML Kustomize化，base 放通用声明（不含镜像 tag），overlay 放环境差异与具体镜像 tag。
#### 可以去https://github.com/RookieToExpert/az305/tree/main/kubernetes-docker/timeapp-config查看具体配置文件

## 安装Argo CD
```bash
kubectl create ns argocd
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

#### 可选：暴露 UI（临时）
```kubectl -n argocd port-forward svc/argocd-server 8080:80```
#### 初始 admin 密码：
```kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo # JrXVYD4y93U5PVTX```

## 在 Argo CD 里创建 Application
#### 私仓时,给 Argo 加 Git 凭据
```bash
# repo-az305.yaml
apiVersion: v1
kind: Secret
metadata:
  name: repo-az305
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  url: https://github.com/RookieToExpert/az305.git
  username: rui0821722@gmail.com
  password: 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
```
#### 执行创建secret
```kubectl apply -f repo-az305.yaml```

#### 创建 Application
```bash
# timeapp-argocd.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: timeapp-prod
  namespace: argocd
spec:
  project: default
  destination:
    server: https://kubernetes.default.svc
    namespace: timeapp
  source:
    repoURL: https://github.com/RookieToExpert/az305.git
    targetRevision: main
    path: "kubernetes-docker/timeapp-config/overlays/prod" 
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - ServerSideApply=true
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
      - ApplyOutOfSyncOnly=true
```
#### 执行创建application
```kubectl apply -f timeapp-argocd.yaml```

## 更新pipeline文件
#### 在github获得token，确保后续pipeline能自动更新argo cd yaml文件

![alt text](image-4.png)

并添加到pipeline中：

![alt text](image-5.png)

#### web
```bash
# azure-pipelines-web.yml
trigger: { branches: { include: [ main ] } }
pr:       { branches: { include: [ main ] } }

variables:
  # 镜像（web）
  webRepo: 'docker.io/rayrayye/timeapp-web'
  dockerfilePath: 'Dockerfile'
  buildContext: '.'

  # 配置仓（org/repo）和路径（注意带 &）
  githubOrgRepo: 'RookieToExpert/az305'
  configPath: 'kubernetes&docker/timeapp-config/overlays/prod'

  # 版本号（web 独立计数）
  major: '1'
  counterKey: 'web-1'
  patch: $[ counter(variables['counterKey'], 0) ]
  version: '$(major).$(patch)'

stages:
# ---------- Build & Push ----------
- stage: Build
  displayName: Build & Push (web)
  jobs:
  - job: build
    pool: { vmImage: 'ubuntu-latest' }
    steps:
    - task: Docker@2
      displayName: Login Docker Hub
      inputs: { command: login, containerRegistry: 'toDockerHub' }   # ← 你的 Docker Hub service connection
    - task: Docker@2
      displayName: Build+Push web:$(version)
      inputs:
        command: buildAndPush
        repository: '$(webRepo)'
        Dockerfile: '$(dockerfilePath)'
        buildContext: '$(buildContext)'
        tags: |
          $(version)

# ---------- Create PR to config repo ----------
- stage: ConfigPR
  displayName: Create PR (bump web tag)
  dependsOn: Build
  jobs:
  - job: pr
    pool: { vmImage: 'ubuntu-latest' }
    steps:
    - checkout: none

    # yq + jq（改 YAML、解析 PR 响应）
    - script: |
        set -euo pipefail
        curl -L https://github.com/mikefarah/yq/releases/download/v4.44.3/yq_linux_amd64 -o /usr/local/bin/yq
        chmod +x /usr/local/bin/yq
        sudo apt-get update -y
        sudo apt-get install -y jq
      displayName: Install yq & jq

    - script: |
        set -euo pipefail

        git config --global user.name  "ado-bot"
        git config --global user.email "ado-bot@example.com"

        # 1) 用 PAT 克隆配置仓（用 $GITHUB_TOKEN，不要写 $(...)）
        GIT_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git"
        git clone "$GIT_URL" configrepo
        cd configrepo

        # 2) 新建分支
        BR="bump-web-${VERSION}-${BUILD_ID}"
        git switch -c "$BR"

        # 3) 改 Kustomize 的镜像 tag（只改 web）
        FILE="${CONFIG_PATH}/kustomization.yaml"
        yq -i '(.images[] | select(.name == env(IMG_NAME))).newTag = env(VERSION)' "$FILE"

        git add "$FILE"
        git commit -m "chore(web): bump to ${VERSION}"
        git push -u origin "$BR"

        # 4) 用 REST API 创建 PR 并打印链接
        RESP=$(curl -sS -X POST "https://api.github.com/repos/${GITHUB_REPO}/pulls" \
          -H "Authorization: token ${GITHUB_TOKEN}" \
          -H "Accept: application/vnd.github+json" \
          -d "{\"title\":\"Bump web to ${VERSION}\",\"body\":\"Update web image tag to ${VERSION} for GitOps\",\"head\":\"$BR\",\"base\":\"main\",\"maintainer_can_modify\":true}")
        echo "$RESP" | jq -r '.html_url'

        # （可选）自动合并：分支保护允许时再打开下面两行
        # PR_NUM=$(echo "$RESP" | jq -r '.number')
        # curl -sS -X PUT "https://api.github.com/repos/${GITHUB_REPO}/pulls/${PR_NUM}/merge" -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/vnd.github+json" -d '{"merge_method":"merge"}'
      displayName: 'Bump web tag & open PR'
      env:
        GITHUB_TOKEN: $(GITHUB_TOKEN)                      # ← DevOps Secret 变量
        GITHUB_REPO: $(githubOrgRepo)
        CONFIG_PATH: '$(configPath)'
        IMG_NAME: '$(webRepo)'
        VERSION: $(version)
        BUILD_ID: $(Build.BuildId)

```
#### api
```bash
# azure-pipelines-api.yml
trigger: { branches: { include: [ main ] } }
pr:       { branches: { include: [ main ] } }

variables:
  apiRepo: 'docker.io/rayrayye/timeapp-api-new'   # 注意 -new
  dockerfilePath: 'Dockerfile'
  buildContext: '.'

  githubOrgRepo: 'RookieToExpert/az305'
  configPath: 'kubernetes&docker/timeapp-config/overlays/prod'

  major: '1'
  counterKey: 'api-1'
  patch: $[ counter(variables['counterKey'], 0) ]
  version: '$(major).$(patch)'

stages:
- stage: Build
  displayName: Build & Push (api)
  jobs:
  - job: build
    pool: { vmImage: 'ubuntu-latest' }
    steps:
    - task: Docker@2
      displayName: Login Docker Hub
      inputs: { command: login, containerRegistry: 'toDockerHub' }
    - task: Docker@2
      displayName: Build+Push api:$(version)
      inputs:
        command: buildAndPush
        repository: '$(apiRepo)'
        Dockerfile: '$(dockerfilePath)'
        buildContext: '$(buildContext)'
        tags: |
          $(version)

- stage: ConfigPR
  displayName: Create PR (bump api tag)
  dependsOn: Build
  jobs:
  - job: pr
    pool: { vmImage: 'ubuntu-latest' }
    steps:
    - checkout: none

    - script: |
        set -euo pipefail
        curl -L https://github.com/mikefarah/yq/releases/download/v4.44.3/yq_linux_amd64 -o /usr/local/bin/yq
        chmod +x /usr/local/bin/yq
        sudo apt-get update -y
        sudo apt-get install -y jq
      displayName: Install yq & jq

    - script: |
        set -euo pipefail

        git config --global user.name  "ado-bot"
        git config --global user.email "ado-bot@example.com"

        GIT_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git"
        git clone "$GIT_URL" configrepo
        cd configrepo

        BR="bump-api-${VERSION}-${BUILD_ID}"
        git switch -c "$BR"

        FILE="${CONFIG_PATH}/kustomization.yaml"
        yq -i '(.images[] | select(.name == env(IMG_NAME))).newTag = env(VERSION)' "$FILE"

        git add "$FILE"
        git commit -m "chore(api): bump to ${VERSION}"
        git push -u origin "$BR"

        RESP=$(curl -sS -X POST "https://api.github.com/repos/${GITHUB_REPO}/pulls" \
          -H "Authorization: token ${GITHUB_TOKEN}" \
          -H "Accept: application/vnd.github+json" \
          -d "{\"title\":\"Bump api to ${VERSION}\",\"body\":\"Update api image tag to ${VERSION} for GitOps\",\"head\":\"$BR\",\"base\":\"main\",\"maintainer_can_modify\":true}")
        echo "$RESP" | jq -r '.html_url'

        # （可选）自动合并
        # PR_NUM=$(echo "$RESP" | jq -r '.number')
        # curl -sS -X PUT "https://api.github.com/repos/${GITHUB_REPO}/pulls/${PR_NUM}/merge" -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/vnd.github+json" -d '{"merge_method":"merge"}'
      displayName: 'Bump api tag & open PR'
      env:
        GITHUB_TOKEN: $(GITHUB_TOKEN)
        GITHUB_REPO: $(githubOrgRepo)
        CONFIG_PATH: '$(configPath)'
        IMG_NAME: '$(apiRepo)'                  # ← 与 kustomization.yaml 的 name 完全一致
        VERSION: $(version)
        BUILD_ID: $(Build.BuildId)
```
还要设置