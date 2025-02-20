## What is SSO
**SSO(Single Sign-on)**:即单点登录，指在分布式应用系统中，用户在一次身份认证后就可以访问所有**相互信任**的应用系统，而无需再次输入凭据。
SSO底层常见的由**SAML**,**OAuth**或者**OpenID Connect**实现。

## What is SAML(Security Assertion Markup Language)
**SAML 协议**：SSO 常见实现方式之一是基于SAML（Security Assertion Markup Language）协议，也有基于OAuth/OpenID Connect的实现。
**SAML Assertion**：SAMLAssertion是SAML协议中的一种**安全断言**，包含用户身份信息、认证信息、授权信息等。
当用户向**Idp(Identity proviedr)**（身份提供商）发起登录请求成功后，**IdP**会返回一个**SAML Assertion（XML格式）**，其中**声明（Assertion**了该用户已通过认证并**可访问指定的Service Provider (SP)**。
**SP**会验证**SAML Assertion是否有效**（签名、时间戳、主体等），SP会将Assertion里面的用户信息与自己的用户信息库作对比，能成功map到就验证成功就认为用户已登录，无需再进行二次认证。

## SAML example
以**Entra ID & SAML SSO为例**（与其他SAML SSO流程类似，重点是如何在Azure门户中配置）

**使用者的角度(IDP-initiate)：**
1. 在**Entra ID**中注册应用：管理员在Azure门户(portal.azure.com)给某个**SaaS**或自有应用配置 **“企业应用”(Enterprise Applications)**，并开启SAML SSO。
2. 用户访问**应用(SP)**：当用户初次访问该应用时，应用构建一个SAML AuthnRequest将用户**重定向到Entra ID**的SSO接口进行身份验证:

   ![image](https://github.com/user-attachments/assets/8ac0ca5d-4eb3-4807-b6d6-096248c094ce)

4. **Entra ID认证**：如果用户已在该浏览器中登录**Azure AD**，会自动完成**SSO**；如果没有，则用户**输入Entra ID账户**（如用户名@contoso.onmicrosoft.com）和密码或者通过Windows Hello、MFA等方式验证。
5. Entra ID返回**SAML Assertion**：Entra ID会生成一份**签名的SAML断言**，包含**用户身份、组信息等**，根据管理员在**Entra ID中的配置**(Attributes & Claims)：

   ![image](https://github.com/user-attachments/assets/b3c90239-fcf1-4eef-89ec-ee16f947fa25)

6. 用户浏览器通过**post method**将SAML Assertion发给SP的ACS(Assertion Consumer Service) URL:

   ![image](https://github.com/user-attachments/assets/e050b6ad-9b14-4b58-8635-a942dc10de18)

8. 应用(SP)验证Assertion：**验证签名、时效等后**，创建本地会话(session)，用户即完成单点登录。
9. 或者是SP-initiate：用户先访问SP-initiate，SP **redirect**用户到IDP，后面的步骤相同。


**管理者的角度：**
1. 在 **Entra ID** 中创建 **Enterprise Application**
2. 在 Single Sign-On 中**选择 SAML 方式**,并且在entra ID中将**Fedration Metadata XML**下载下来
3. **建立信任关系:** 将 Entra ID 下载的 **Fedration Metadata XML**(IDP XML, configurations and certificate) 并将其上传至目标应用（SP），同时将目标应用的Metadata(SP XML, configurations and certificate)传至 Entra ID

   **Metadata**：
   1. **name ID format**：

   ![image](https://github.com/user-attachments/assets/39f6fbf5-6cd1-43b9-b608-a288656bb091)

   需要确保两边的name ID format都是一样的

   2. **sender certificate**:
   receiver可以通过certificate判断assertion中signing是来自trusted party。

   ![image](https://github.com/user-attachments/assets/ddedfcd5-364c-4db5-883c-0d96419548b0)

   3. **entity identifier**:
   unique identify 是sender还是receiver

   ![image](https://github.com/user-attachments/assets/eb32bf69-14e7-48db-ab66-801384f815b9)

   4. **agreement of how to exchange data between SP and IDP**:

   ![image](https://github.com/user-attachments/assets/392bdf12-157a-458d-b7ab-073c11992d01)

8. 在 Azure AD 的 User Attributes & Claims 中映射所需用户属性
9. 为该应用分配需要访问的用户或用户组
10. 测试并验证单点登录是否成功

**How assertions is sent**：
SAML 2.0 BINDINGS:

![image](https://github.com/user-attachments/assets/c727db15-6ed5-4f52-987f-b6eada17bad4)

**SAML Artifact:**
SAML Artifact contain a unique identifier. SP send a artifact resolve message to IDP.

![image](https://github.com/user-attachments/assets/c8aa814a-629a-4fb0-8c45-5be30767a489)

**what is in Assertion:**
1. Name ID
2. Method to authenticate:

![image](https://github.com/user-attachments/assets/6eda089b-6f5b-44a9-87a3-ccd3e1a6199c)

You can make your own authentication.

3. Attributes: provifed more details of user.

Format of Attributes:

![image](https://github.com/user-attachments/assets/d19bbea6-06e1-4fd9-9313-7921b28a47d3)

4. Conditions:
   valid time for assertion(prevent replay attack), who is this assetion is sent

5. issuer ID:
   who generate this assertion

6. Signiture:
   Hashed and signed to provide protection.

