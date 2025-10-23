## chatgpt通用模版
```html
<!DOCTYPE html> <!-- 声明HTML5文档类型 -->
<html lang="en"> <!-- 根HTML标签 -->
<head>
    <meta charset="UTF-8"> <!-- 字符编码 -->
    <title>PLM Sample UI</title>

    <!-- CSS样式区域：负责UI显示与可见性 -->
    <style>
        body {
            background-color: #ffffff;  /* 背景色 */
            color: #333333;             /* 字体颜色 */
            font-size: 16px;            /* 全局字号 */
            font-family: Arial, sans-serif;
        }

        /* 通过权限隐藏常用的样式 */
        .hidden {
            display: none;              /* 完全隐藏，不占位置（权限控制常用） */
        }

        .invisible {
            visibility: hidden;         /* 占位但不可见 */
        }

        .transparent {
            opacity: 0;                 /* 元素存在但透明 */
        }

        /* 正常按钮样式 */
        #approveBtn {
            background-color: #007bff;  /* 按钮背景色 */
            color: white;               /* 文本颜色 */
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;            /* 鼠标悬浮提示可点击 */
        }
    </style>
</head>

<body>
    <!-- 页面结构由HTML控制（是否渲染出来） -->
    <header>
        <h1>PLM Approve Sample Interface</h1>
    </header>

    <main>
        <p>This is a sample workflow action:</p>

        <!-- 按钮结构（HTML决定是否"存在"） -->
        <!-- 如果这个ID找不到 → 逻辑隐藏（JS没渲染） -->
        <button id="approveBtn">Approve</button>
    </main>

    <!-- JavaScript 控制交互（是否能"点" & "发请求"） -->
    <script>
        // 获取DOM中的按钮
        const approveBtn = document.getElementById("approveBtn");

        // 如果approveBtn不存在，说明JS/条件逻辑没有渲染它 → 逻辑隐藏
        // 如果存在但样式是display:none → 权限隐藏

        // 添加点击事件监听
        approveBtn.addEventListener("click", function() {
            console.log("Approve clicked");

            // 发起API请求（Network是否能看到请求很关键）
            fetch("/api/approve", {
                method: "POST"
            })
            .then(response => {
                if (!response.ok) {
                    // HTTP层判断
                    // 401 → 未认证（SSO/登录）
                    // 403 → 无权限
                    // 500 → 后端JAVA异常
                    throw new Error("HTTP error: " + response.status);
                }
                return response.json();
            })
            .then(data => {
                console.log("API Response:", data);
            })
            .catch(error => {
                // 如果走到这里，就说明JS逻辑出错 or API失败
                console.error("JS/Network error:", error);
            });
        });
    </script>
</body>
</html>
```

## html
```html
<!DOCTYPE html>
<html>
<head>
    <title>我的第一个网页</title>
</head>
<body>
    <h1>欢迎来到我的网站！</h1>
    <p>这是一个关于 HTML 的简单段落。</p>
    <img src="cat.jpg" alt="一只可爱的猫">
    <button>点击我！</button>
    <a href="https://www.example.com">访问另一个网站</a>
</body>
</html>
``` 

## css
```css
body {
    background-color: lightblue; /* 整个页面背景设为浅蓝色 */
    font-family: Arial; /* 默认字体设为 Arial */
}
h1 {
    color: navy; /* 标题文字颜色设为海军蓝 */
    text-align: center; /* 标题文字居中 */
}
p {
    font-size: 18px; /* 段落文字大小设为 18 像素 */
    line-height: 1.5; /* 行高设为 1.5 倍 */
}
img {
    width: 300px; /* 图片宽度设为 300 像素 */
    border: 5px solid black; /* 图片加 5 像素宽的黑色实线边框 */
    display: block; /* 让图片独占一行（居中需要） */
    margin: 0 auto; /* 图片水平居中 */
}
button {
    background-color: green; /* 按钮背景设为绿色 */
    color: white; /* 按钮文字设为白色 */
    padding: 10px 20px; /* 按钮内边距 */
    border: none; /* 去掉默认边框 */
    border-radius: 5px; /* 按钮边角变圆滑 */
    cursor: pointer; /* 鼠标悬停时变成手指形状 */
}
```

## javascript
```js
// 1. 找到页面上的按钮元素
const myButton = document.querySelector('button');
// 2. 给按钮添加一个“点击”事件的监听器
myButton.addEventListener('click', function() {
    // 3. 当按钮被点击时，执行这里的代码：
    //    a. 找到页面上的段落元素
    const myParagraph = document.querySelector('p');
    //    b. 改变段落的文字内容
    myParagraph.textContent = "你点击了按钮！";
    //    c. 改变段落的文字颜色 (这里用 JS 直接修改了样式)
    myParagraph.style.color = "red";
    //    d. 弹出一个提示框
    alert("按钮被按下了！");
});
```


```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>前端开发通用模板</title>
    <style>
        /* ===== CSS重置与基础样式 ===== */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        :root {
            /* 颜色变量 */
            --primary-color: #3498db;
            --secondary-color: #2ecc71;
            --danger-color: #e74c3c;
            --text-color: #333;
            --light-gray: #f5f5f5;
            --dark-gray: #7f8c8d;
            
            /* 间距变量 */
            --spacing-xs: 4px;
            --spacing-sm: 8px;
            --spacing-md: 16px;
            --spacing-lg: 24px;
            --spacing-xl: 32px;
            
            /* 边框半径 */
            --border-radius-sm: 4px;
            --border-radius-md: 8px;
            --border-radius-lg: 12px;
            
            /* 阴影 */
            --shadow-sm: 0 2px 4px rgba(0,0,0,0.1);
            --shadow-md: 0 4px 8px rgba(0,0,0,0.15);
            --shadow-lg: 0 8px 16px rgba(0,0,0,0.2);
            
            /* 过渡 */
            --transition-fast: 0.2s;
            --transition-normal: 0.3s;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: var(--text-color);
            background-color: #f9f9f9;
        }
        
        /* ===== 布局系统 ===== */
        .container {
            width: 100%;
            max-width: 1200px;
            margin: 0 auto;
            padding: var(--spacing-md);
        }
        
        .flex {
            display: flex;
        }
        
        .flex-col {
            flex-direction: column;
        }
        
        .flex-center {
            justify-content: center;
            align-items: center;
        }
        
        .grid {
            display: grid;
            gap: var(--spacing-md);
        }
        
        .grid-2 {
            grid-template-columns: repeat(2, 1fr);
        }
        
        .grid-3 {
            grid-template-columns: repeat(3, 1fr);
        }
        
        /* ===== 排版样式 ===== */
        h1, h2, h3, h4, h5, h6 {
            margin-bottom: var(--spacing-md);
            font-weight: 600;
            line-height: 1.2;
        }
        
        h1 {
            font-size: 2.5rem;
        }
        
        h2 {
            font-size: 2rem;
        }
        
        h3 {
            font-size: 1.75rem;
        }
        
        h4 {
            font-size: 1.5rem;
        }
        
        p {
            margin-bottom: var(--spacing-md);
        }
        
        a {
            color: var(--primary-color);
            text-decoration: none;
            transition: color var(--transition-fast);
        }
        
        a:hover {
            color: #2980b9;
            text-decoration: underline;
        }
        
        /* ===== 按钮样式 ===== */
        .btn {
            display: inline-block;
            padding: var(--spacing-sm) var(--spacing-md);
            border: none;
            border-radius: var(--border-radius-sm);
            background-color: var(--primary-color);
            color: white;
            font-size: 1rem;
            font-weight: 500;
            cursor: pointer;
            transition: all var(--transition-fast);
            text-align: center;
        }
        
        .btn:hover {
            background-color: #2980b9;
            transform: translateY(-2px);
            box-shadow: var(--shadow-sm);
        }
        
        .btn:active {
            transform: translateY(0);
        }
        
        .btn-secondary {
            background-color: var(--secondary-color);
        }
        
        .btn-secondary:hover {
            background-color: #27ae60;
        }
        
        .btn-danger {
            background-color: var(--danger-color);
        }
        
        .btn-danger:hover {
            background-color: #c0392b;
        }
        
        .btn-outline {
            background-color: transparent;
            border: 1px solid var(--primary-color);
            color: var(--primary-color);
        }
        
        .btn-outline:hover {
            background-color: var(--primary-color);
            color: white;
        }
        
        /* ===== 表单元素 ===== */
        .form-group {
            margin-bottom: var(--spacing-md);
        }
        
        label {
            display: block;
            margin-bottom: var(--spacing-xs);
            font-weight: 500;
        }
        
        input, textarea, select {
            width: 100%;
            padding: var(--spacing-sm);
            border: 1px solid #ddd;
            border-radius: var(--border-radius-sm);
            font-size: 1rem;
            transition: border-color var(--transition-fast);
        }
        
        input:focus, textarea:focus, select:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 2px rgba(52, 152, 219, 0.2);
        }
        
        .checkbox-group, .radio-group {
            display: flex;
            align-items: center;
            gap: var(--spacing-sm);
        }
        
        /* ===== 卡片组件 ===== */
        .card {
            background-color: white;
            border-radius: var(--border-radius-md);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
            transition: transform var(--transition-normal), box-shadow var(--transition-normal);
        }
        
        .card:hover {
            transform: translateY(-5px);
            box-shadow: var(--shadow-md);
        }
        
        .card-header {
            padding: var(--spacing-md);
            background-color: var(--light-gray);
            border-bottom: 1px solid #eee;
        }
        
        .card-body {
            padding: var(--spacing-md);
        }
        
        .card-footer {
            padding: var(--spacing-md);
            background-color: var(--light-gray);
            border-top: 1px solid #eee;
        }
        
        /* ===== 导航栏 ===== */
        .navbar {
            background-color: white;
            box-shadow: var(--shadow-sm);
            padding: var(--spacing-md) 0;
            position: sticky;
            top: 0;
            z-index: 100;
        }
        
        .nav-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .logo {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--primary-color);
        }
        
        .nav-links {
            display: flex;
            gap: var(--spacing-md);
            list-style: none;
        }
        
        .nav-link a {
            color: var(--text-color);
            font-weight: 500;
        }
        
        .nav-link a:hover {
            color: var(--primary-color);
            text-decoration: none;
        }
        
        /* ===== 响应式设计 ===== */
        @media (max-width: 768px) {
            .grid-3 {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .nav-links {
                display: none;
            }
            
            .mobile-menu-btn {
                display: block;
            }
        }
        
        @media (max-width: 480px) {
            .grid-2, .grid-3 {
                grid-template-columns: 1fr;
            }
            
            h1 {
                font-size: 2rem;
            }
            
            h2 {
                font-size: 1.75rem;
            }
        }
        
        /* ===== 工具类 ===== */
        .text-center {
            text-align: center;
        }
        
        .text-primary {
            color: var(--primary-color);
        }
        
        .mb-sm {
            margin-bottom: var(--spacing-sm);
        }
        
        .mb-md {
            margin-bottom: var(--spacing-md);
        }
        
        .mb-lg {
            margin-bottom: var(--spacing-lg);
        }
        
        .mb-xl {
            margin-bottom: var(--spacing-xl);
        }
        
        .p-sm {
            padding: var(--spacing-sm);
        }
        
        .p-md {
            padding: var(--spacing-md);
        }
        
        .p-lg {
            padding: var(--spacing-lg);
        }
        
        .hidden {
            display: none;
        }
    </style>
</head>
<body>
    <!-- 导航栏 -->
    <nav class="navbar">
        <div class="container nav-container">
            <div class="logo">Logo</div>
            <ul class="nav-links">
                <li class="nav-link"><a href="#home">首页</a></li>
                <li class="nav-link"><a href="#features">功能</a></li>
                <li class="nav-link"><a href="#about">关于</a></li>
                <li class="nav-link"><a href="#contact">联系</a></li>
            </ul>
            <button class="btn">登录</button>
        </div>
    </nav>

    <!-- 主要内容区域 -->
    <main class="container">
        <!-- 英雄区域 -->
        <section id="home" class="mb-xl">
            <div class="flex flex-col flex-center" style="min-height: 70vh;">
                <h1 class="text-center mb-md">欢迎使用前端开发通用模板</h1>
                <p class="text-center mb-lg">这是一个包含HTML、CSS和JavaScript最佳实践的通用模板</p>
                <div class="flex gap-md">
                    <button class="btn">开始使用</button>
                    <button class="btn btn-outline">了解更多</button>
                </div>
            </div>
        </section>

        <!-- 功能区域 -->
        <section id="features" class="mb-xl">
            <h2 class="text-center mb-lg">核心功能</h2>
            <div class="grid grid-3">
                <!-- 卡片1 -->
                <div class="card">
                    <div class="card-header">
                        <h3>响应式设计</h3>
                    </div>
                    <div class="card-body">
                        <p>适配各种屏幕尺寸，从手机到桌面设备</p>
                    </div>
                    <div class="card-footer">
                        <button class="btn btn-outline">查看详情</button>
                    </div>
                </div>
                
                <!-- 卡片2 -->
                <div class="card">
                    <div class="card-header">
                        <h3>现代布局</h3>
                    </div>
                    <div class="card-body">
                        <p>使用Flexbox和Grid实现灵活的布局系统</p>
                    </div>
                    <div class="card-footer">
                        <button class="btn btn-outline">查看详情</button>
                    </div>
                </div>
                
                <!-- 卡片3 -->
                <div class="card">
                    <div class="card-header">
                        <h3>组件化</h3>
                    </div>
                    <div class="card-body">
                        <p>可复用的UI组件，提高开发效率</p>
                    </div>
                    <div class="card-footer">
                        <button class="btn btn-outline">查看详情</button>
                    </div>
                </div>
            </div>
        </section>

        <!-- 表单示例 -->
        <section id="contact" class="mb-xl">
            <h2 class="text-center mb-lg">联系我们</h2>
            <div class="grid grid-2">
                <div>
                    <form id="contactForm">
                        <div class="form-group">
                            <label for="name">姓名</label>
                            <input type="text" id="name" placeholder="请输入您的姓名">
                        </div>
                        
                        <div class="form-group">
                            <label for="email">邮箱</label>
                            <input type="email" id="email" placeholder="请输入您的邮箱">
                        </div>
                        
                        <div class="form-group">
                            <label for="message">留言</label>
                            <textarea id="message" rows="5" placeholder="请输入您的留言"></textarea>
                        </div>
                        
                        <div class="form-group">
                            <div class="checkbox-group">
                                <input type="checkbox" id="subscribe">
                                <label for="subscribe">订阅我们的新闻通讯</label>
                            </div>
                        </div>
                        
                        <button type="submit" class="btn">提交</button>
                    </form>
                </div>
                
                <div>
                    <div class="card">
                        <div class="card-body">
                            <h3 class="mb-md">联系信息</h3>
                            <p class="mb-sm"><strong>地址：</strong>北京市朝阳区某某大厦</p>
                            <p class="mb-sm"><strong>电话：</strong>010-12345678</p>
                            <p class="mb-sm"><strong>邮箱：</strong>contact@example.com</p>
                            <p class="mb-sm"><strong>工作时间：</strong>周一至周五 9:00-18:00</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <!-- 页脚 -->
    <footer style="background-color: #333; color: white; padding: var(--spacing-lg) 0;">
        <div class="container">
            <div class="grid grid-3">
                <div>
                    <h3 class="mb-md">公司名称</h3>
                    <p>提供高质量的前端开发解决方案</p>
                </div>
                
                <div>
                    <h3 class="mb-md">快速链接</h3>
                    <ul style="list-style: none;">
                        <li class="mb-sm"><a href="#home" style="color: white;">首页</a></li>
                        <li class="mb-sm"><a href="#features" style="color: white;">功能</a></li>
                        <li class="mb-sm"><a href="#about" style="color: white;">关于</a></li>
                        <li><a href="#contact" style="color: white;">联系</a></li>
                    </ul>
                </div>
                
                <div>
                    <h3 class="mb-md">关注我们</h3>
                    <div class="flex gap-md">
                        <a href="#" style="color: white;">微博</a>
                        <a href="#" style="color: white;">微信</a>
                        <a href="#" style="color: white;">GitHub</a>
                    </div>
                </div>
            </div>
            <div class="text-center mt-lg">
                <p>&copy; 2023 公司名称. 保留所有权利.</p>
            </div>
        </div>
    </footer>

    <script>
        // ===== DOM操作示例 =====
        document.addEventListener('DOMContentLoaded', function() {
            console.log('DOM已加载完成');
            
            // 获取DOM元素
            const contactForm = document.getElementById('contactForm');
            const nameInput = document.getElementById('name');
            
            // 表单提交事件
            contactForm.addEventListener('submit', function(e) {
                e.preventDefault();
                
                // 表单验证
                if (!nameInput.value.trim()) {
                    alert('请输入您的姓名');
                    nameInput.focus();
                    return;
                }
                
                // 模拟表单提交
                console.log('表单提交:', {
                    name: nameInput.value,
                    email: document.getElementById('email').value,
                    message: document.getElementById('message').value
                });
                
                alert('表单提交成功！');
                contactForm.reset();
            });
            
            // ===== 事件委托示例 =====
            document.addEventListener('click', function(e) {
                if (e.target.matches('.card-footer .btn')) {
                    const card = e.target.closest('.card');
                    const title = card.querySelector('h3').textContent;
                    alert(`您点击了 "${title}" 的按钮`);
                }
            });
            
            // ===== 异步请求示例 =====
            async function fetchData() {
                try {
                    // 实际项目中会调用真实API
                    const response = await fetch('https://jsonplaceholder.typicode.com/todos/1');
                    const data = await response.json();
                    console.log('获取的数据:', data);
                } catch (error) {
                    console.error('请求失败:', error);
                }
            }
            
            // 调用异步函数
            fetchData();
            
            // ===== 操作DOM样式 =====
            const cards = document.querySelectorAll('.card');
            cards.forEach((card, index) => {
                // 添加延迟动画
                card.style.animationDelay = `${index * 0.1}s`;
            });
        });
        
        // ===== 实用函数 =====
        function debounce(func, delay = 300) {
            let timer;
            return function() {
                const context = this;
                const args = arguments;
                clearTimeout(timer);
                timer = setTimeout(() => {
                    func.apply(context, args);
                }, delay);
            };
        }
        
        // 使用防抖函数
        window.addEventListener('resize', debounce(function() {
            console.log('窗口大小改变:', window.innerWidth);
        }, 200));
    </script>
</body>
</html>
```