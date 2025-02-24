## OAuth(Open Authorization)
OAuth 是一个开放标准授权协议，最常见版本是OAuth 2.0，它允许用户在不暴露自身凭据（如用户名、密码）的情况下让第三方应用获取对受保护资源的有限访问权限.
#### 使用场景：
**社交登录**：比如你用微信/微博/Google/Facebook账号登录第三方网站，这其中就利用了OAuth授权流程；
**API访问授权**：让第三方应用访问某些REST API（如云端文件、照片等），但不需要用户告诉应用密码；

资源拥有者 用户
授权服务器 微信
资源服务器 第三方网站

## 什么是JWT Token
**JWT（JSON Web Token）**：是一种基于JSON的轻量级、安全传输方式的令牌格式，与OAuth/OpenID Connect常配合使用。
主要结构：
1. **Header**（声明类型及签名算法）
2. 
   ![image](https://github.com/user-attachments/assets/f54392ce-99b6-4913-9811-7308ec678c7f)

**Payload**（用户信息、权限、过期时间等）

![image](https://github.com/user-attachments/assets/403fbf4b-b9d9-446b-82c4-9c0a6b7d7677)

**Signature**（签名，用于验证Token的完整性）

![image](https://github.com/user-attachments/assets/39f5e895-30a0-4e70-b84d-4f1b38b30c38)

**优点**：体积小、易于跨语言处理、可在前端和后端之间安全传递用户身份信息；通常会进行Base64编码和签名。

## OAuth workflow
访问OAuth的标准接口是'根地址'/oauth/token
1. **Authorization Code Grant**：
   常见于Web应用或服务器端应用，安全性较高。
   1. 用户点击淘宝微信登陆→需要你去访问**授权服务器根地址/oauth/authorize/client_id&response_type=code&redirect_url**

   ![image](https://github.com/user-attachments/assets/3e622a66-45d5-4897-ae65-345990723c4c)

   微信返回一个二维码的页面：

   ![image](https://github.com/user-attachments/assets/a088e2e3-2076-465b-a7c6-f7206f9275e9)

   2. 用户授权登录后，浏览器会给为微信发送一个post请求Authorization Code：

   ![image](https://github.com/user-attachments/assets/71c6c88e-3e1d-4982-bb26-2323dc43eb61)

   3. 微信重倒向淘宝的redirect URL带上302 Found状态码，并且附带上code：
   
   ![image](https://github.com/user-attachments/assets/939b97c9-44e1-46c5-a160-c56a05f2b2d6)

   5. 淘宝得到code后，发送一个post请求(**grant_type=authorization_code**)，再由服务器端换取Access Token和Refresh Token

      ![image](https://github.com/user-attachments/assets/ed1509e9-29b3-4389-8966-ca003b886dd2)

      微信返回access token和refresh token：

      ![image](https://github.com/user-attachments/assets/60ad48dc-b302-4c5c-bd75-7e4504b7d513)


3. **Implicit Flow(简化模式)**：
   常见于纯前端单页应用（SPA），不需要后端服务器直接参与。需要你去访问**授权服务器根地址/oauth/authorize/client_id&response_type=token&redirect_url**的地址用户登录后直接从授权服务器获取Access Token（通常不返回Refresh Token），access token直接在redirect url后面的＃部分接一个access token，浏览器客户端可以直接将javascript解析并提取access token，access token都不需要发送到服务器， token明文传输，还是不安全。比较适合一些没有后台服务的单页面应用。
4. **Resource Owner Password Credentials Grant(password)**：
   在极少数可信场景中使用（比如自家App对自家API），用户直接把用户名密码给客户端，客户端再去发一个**post https**请求，主体包含(**client_id/app_id, client_secret/app_secret,grant_type=password,username, password**)请求授权服务器，这种方式安全风险较高。
6. **Client Credentials Grant(client_credentials)**：
   无用户场景下
   客户端（如后端服务）直接以自身身份发一个**post https**请求，主体包含(**client_id/app_id, client_secret/app_secret,grant_type=client_credentials**)去获取Token，用于调用保护资源，比如微服务之间授权访问。


