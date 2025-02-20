## OAuth(Open Authorization)
OAuth 是一个开放标准授权协议，最常见版本是OAuth 2.0，它允许用户在不暴露自身凭据（如用户名、密码）的情况下让第三方应用获取对受保护资源的有限访问权限.
#### 使用场景：
**社交登录**：比如你用微信/微博/Google/Facebook账号登录第三方网站，这其中就利用了OAuth授权流程；
**API访问授权**：让第三方应用访问某些REST API（如云端文件、照片等），但不需要用户告诉应用密码；

资源拥有者 用户
授权服务器 微信
资源服务器 第三方网站

## OAuth workflow
访问OAuth的标准接口是'根地址'/oauth/token
1. **Authorization Code Grant**：
   常见于Web应用或服务器端应用，安全性较高，需要你去访问**授权服务器根地址/oauth/authorize/client_id&response_type=code&redirect_url**，先在浏览器获取Authorization Code(**grant_type=authorization_code**)，再由服务器端换取Access Token和Refresh Token。
3. **Implicit Flow(简化模式)**：
   常见于纯前端单页应用（SPA），不需要后端服务器直接参与。需要你去访问**授权服务器根地址/oauth/authorize/client_id&response_type=token&redirect_url**的地址用户登录后直接从授权服务器获取Access Token（通常不返回Refresh Token）， token明文传输，还是不安全。
4. **Resource Owner Password Credentials Grant(password)**：
   在极少数可信场景中使用（比如自家App对自家API），用户直接把用户名密码给客户端，客户端再去发一个**post https**请求，主体包含(**client_id/app_id, client_secret/app_secret,grant_type=password,username, password**)请求授权服务器，这种方式安全风险较高。
6. **Client Credentials Grant(client_credentials)**：
   无用户场景下
   客户端（如后端服务）直接以自身身份发一个**post https**请求，主体包含(**client_id/app_id, client_secret/app_secret,grant_type=client_credentials**)去获取Token，用于调用保护资源，比如微服务之间授权访问。

## 什么是JWT Token
**JWT（JSON Web Token）**：是一种基于JSON的轻量级、安全传输方式的令牌格式，与OAuth/OpenID Connect常配合使用。
主要结构：
1. **Header**（声明类型及签名算法）
   access token
**Payload**（用户信息、权限、过期时间等）
**Signature**（签名，用于验证Token的完整性）
**优点**：体积小、易于跨语言处理、可在前端和后端之间安全传递用户身份信息；通常会进行Base64编码和签名。
