相似点：
都涉及身份/访问控制，令牌或断言的概念；
都旨在降低用户密码暴露、增强安全性，让多个系统/应用间认证或授权流程自动化；
都可以通过重定向（redirect）方式在不同实体之间传递身份或授权信息。
区别：
目标不同：SSO着重于“跨系统的单点登录”，关注的是“认证”（Authentication）层面；OAuth则更多关注“授权”（Authorization），控制第三方应用对资源的访问权限；
协议栈不同：SSO常基于SAML、OpenID Connect；OAuth常指OAuth 2.0标准本身。
令牌格式：SSO在SAML场景下更多是SAML Assertion(基于XML)；OAuth更多使用JWT(基于JSON)，也可多种格式。
