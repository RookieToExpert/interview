## 在VMSS中搭建前端
#### 1. 下载nginx
  ```shell
  sudo apt-get update -y
  sudo apt-get install -y nginx
  sudo systemctl enable nginx
  ```
#### 2. 放置前端静态网页 /var/www/timeapp/index.html
  i. 创建静态网页的目录：sudo mkdir -p /var/www/timeapp

  ii. 将html文件写入index.html： sudo tee /var/www/timeapp/index.html >/dev/null <<'HTML'
```html
<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1"/>
  <title>World Time | Demo</title>
  <style>
    body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif;margin:0;background:#0b1220;color:#e6edf3}
    header,main{max-width:900px;margin:0 auto;padding:24px}
    .card{background:#111827;border:1px solid #1f2937;border-radius:16px;padding:16px;margin:12px 0}
    .grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:12px}
    input,button{padding:10px 12px;border-radius:10px;border:1px solid #334155;background:#0f172a;color:#e6edf3}
    button{cursor:pointer}
    .muted{color:#9ca3af}
    .hidden{display:none}
  </style>
</head>
<body>
<header>
  <h2>World Time（登录后查看）</h2>
  <div id="notice" class="muted"></div>
</header>

<main>
  <section id="login-card" class="card">
    <h3>登录</h3>
    <form id="login-form">
      <div><input id="email" type="email" placeholder="Email" required style="width:100%"></div><br/>
      <div><input id="password" type="password" placeholder="Password" required style="width:100%"></div><br/>
      <button type="submit">登录</button>
      <span class="muted">（当前使用后端 Mock，先搭界面）</span>
    </form>
  </section>

  <section id="dash" class="hidden">
    <div class="card"><b>总浏览量：</b><span id="total">--</span></div>
    <div class="grid" id="times"></div>
    <div class="card">
      <button id="refresh">刷新时间</button>
      <button id="logout" style="margin-left:8px;">退出登录</button>
    </div>
  </section>
</main>

<script>
const zones = [
  {label:'New York', tz:'America/New_York'},
  {label:'Beijing', tz:'Asia/Shanghai'},
  {label:'Sydney', tz:'Australia/Sydney'},
  {label:'Delhi', tz:'Asia/Kolkata'},
];

function fmtNow(tz){
  const d = new Date();
  return new Intl.DateTimeFormat('en-GB',{
    dateStyle:'medium', timeStyle:'medium', timeZone: tz
  }).format(d);
}

async function api(path, opts={}){
  try{
    const r = await fetch(path, {credentials:'include', ...opts});
    if(!r.ok) throw new Error(r.status);
    return await r.json();
  }catch(e){
    return null; // 后端未就绪时返回 null
  }
}

function renderTimes(list){
  const box = document.getElementById('times');
  box.innerHTML = '';
  list.forEach(x=>{
    const el = document.createElement('div');
    el.className = 'card';
    el.innerHTML = `<b>${x.label}</b><div class="muted">${x.tz}</div><div>${x.text}</div>`;
    box.appendChild(el);
  });
}

async function loadTimes(){
  // 优先尝试后端接口
  const data = await api('/api/time/now');
  if(data?.times){
    renderTimes(data.times.map(t=>({label:t.label, tz:t.tz, text:new Date(t.iso).toLocaleString()})));
  }else{
    // 本地计算兜底（便于前端先开发）
    renderTimes(zones.map(z=>({label:z.label, tz:z.tz, text: fmtNow(z.tz)})));
    document.getElementById('notice').textContent = '后端未连接，已使用本地时间兜底';
  }
}

async function loadCounter(){
  const data = await api('/api/metrics/total');
  document.getElementById('total').textContent = (data && typeof data.total==='number') ? data.total : '—';
}

async function postVisit(){
  await api('/api/metrics/visit', {method:'POST'});
}

function showDash(on){
  document.getElementById('login-card').classList.toggle('hidden', on);
  document.getElementById('dash').classList.toggle('hidden', !on);
}

document.getElementById('login-form').addEventListener('submit', async (e)=>{
  e.preventDefault();
  const email = document.getElementById('email').value.trim();
  const password = document.getElementById('password').value;
  const ok = await api('/api/auth/login', {
    method:'POST',
    headers:{'Content-Type':'application/json'},
    body: JSON.stringify({email, password})
  });
  if(ok && ok.ok){
    showDash(true);
    await postVisit();
    await loadTimes();
    await loadCounter();
  }else{
    alert('登录失败（当前为 Mock，返回 200 即可）。');
  }
});

document.getElementById('refresh').onclick = loadTimes;
document.getElementById('logout').onclick = ()=>{ showDash(false); };

</script>
</body>
</html>
HTML
```  
#### 3. 配置Nginx站点(含临时Mock API) /etc/nginx/site-available/timeapp
将timeapp中写入API逻辑：sudo tee /etc/nginx/sites-available/timeapp >/dev/null <<'NGINX'
```nginx
server {
    listen 80;
    server_name _;

    root /var/www/timeapp;
    index index.html;

    # SPA 回退
    location / {
        try_files $uri /index.html;
    }

    # === 临时 Mock 接口：仅用于前端开发联调 ===
    location = /api/auth/login {
        default_type application/json;
        return 200 '{"ok":true}';
    }
    location = /api/metrics/visit {
        default_type application/json;
        return 200 '{"ok":true}';
    }
    location = /api/metrics/total {
        default_type application/json;
        return 200 '{"total":123}';
    }
    location = /api/time/now {
        default_type application/json;
        return 200 '{"times":[
          {"label":"New York","tz":"America/New_York","iso":"2025-08-11T09:00:00-04:00"},
          {"label":"Beijing","tz":"Asia/Shanghai","iso":"2025-08-11T21:00:00+08:00"},
          {"label":"Sydney","tz":"Australia/Sydney","iso":"2025-08-11T23:00:00+10:00"},
          {"label":"Delhi","tz":"Asia/Kolkata","iso":"2025-08-11T18:30:00+05:30"}
        ]}';
    }

    # === 将来接后端时把上面的 return 删掉，改成反代：===
    # location /api/ {
    #     proxy_pass http://10.10.2.4:8000/; # 例：后端 VM 内网地址
    #     proxy_set_header Host $host;
    #     proxy_set_header X-Real-IP $remote_addr;
    #     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    # }
}
NGINX
```

#### 4. 启用站点
  i. sudo rm -f /etc/nginx/sites-enabled/default
  ii. sudo ln -s /etc/nginx/sites-available/timeapp /etc/nginx/sites-enabled/timeapp
  iii. sudo nginx -t && sudo systemctl restart nginx

#### 5. 本机验证
  i. curl -i http://127.0.0.1/
  ii. curl -i http://127.0.0.1/api/time/now


```shell
  # 1) 依赖
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg

# 2) 加 Docker 官方 APT 源
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

# 3) 安装 Docker + Buildx + Compose v2（plugin）
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 4) 处理 docker 组 & 服务
sudo groupadd -f docker
sudo usermod -aG docker $USER
sudo systemctl enable --now docker

# 5) 让当前会话立刻生效（或重新登录）
newgrp docker

# 6) 验证
docker --version
docker compose version
```
