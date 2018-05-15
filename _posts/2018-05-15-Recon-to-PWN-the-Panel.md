---
title: 用偵查來PWN解後端控制台
layout: post
author: NotSurprised
source-url: https://ifc0nf1g.xyz/blog/post/pwning-admin-panel-with-recon/
tags:
- Web
- API
- Mobile APP
---

偵察是滲透測試中有趣且最重要的部分。良好的使用偵察，可以有效的查找到 API 端口、相關敏感文件或文件夾、鮮嫩多汁的子網域 (編註:原文如此) 等等。在我最近一次的研究中發現了一個由於缺少授權管理甚至敏感文件還設為公開的目標，這使我能夠輕易進入其管理控制台。

讓我首先從靜態分析 iOS 應用程式開始。在瀏覽[Info.plist](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/iPhoneOSKeys.html#//apple_ref/doc/uid/TP40009252-SW1)時，我們可以看到裡面有一個寫死的 URL。

```
[nishaanthguna:~/pentest]$ cat Info.plist | grep -i "http"
<!DOCTYPE plist PUBLIC .. "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<string>https://admin.company.com/xyz/api</string>
```
以此為憑依繼續追查這個URL下去，我們得到一個連結到 Swagger UI 的頁面。

![](https://i.imgur.com/gxdQJhr.png)

然後我們粗略的翻一翻[官方文件](https://swagger.io/swagger-ui/)，我們可以看到 Swagger UI 是個用於可視化處理和與 API 互動的資源，它會自動根據載明之規範產生交互。以下是在檢查上一個 UI 頁面時找到的 URL。

![](https://i.imgur.com/mfUxtoy.png)

這裡令人奇怪的是，不僅只在於它行動裝置應用程序的 API 呼叫方式，它甚至還有管理員可以用來管理用戶、管理廣播的內容、管理自定義應用程式使用的聊天機器人端口等等。深入研究額外端口的資訊後，我啟動了 Burp 來查看網路流量。起初，我的想法是用 Swagger UI 中的管理端口來替換行動裝置應用程序的端口，用這方法來檢查 Swagger UI 中的管理端口該程式是否有針對這點設置合適的權限管理來區分普通用戶和管理員帳戶。

從“管理員帳戶”API文檔中，我們可以看到有一個端口使用`/admin/users/count`打印出管理員用戶數。這看起來很有**前途**，因為它不需要任何請求主體(Request body)，而且非常簡單。

以普通用戶身份登入到行動裝置應用程序，我將其中一個 API 呼叫從`/xyz /api/users/account/preferences`更換為`/xyz/api/admin/users/count`並轉發請求。

![](https://i.imgur.com/dLiDWpv.png)

成功了！
這意味著這伺服器沒有任何授權管理。基本上，我們可以向包括`/admin`、`/chatbot`、`/moderate`的任何 API 端口發出任何請求，因為我們知道請求主體(Request body) 的結構和相關的標頭(Header)。現在讓我們嘗試使用 Swagger UI 的端口進行更多暴力窮舉並擴大這個漏洞利用。

從 Swagger UI 附件中，我們可以看到有另一個端口藉由向`/admin/users/{id}`發送請求來查找有關管理員帳戶的訊息。

```
GET /xyz/api/admin/users/1 HTTP/1.1
Host: https://admin.company.com
User Agent: MS-RELEASE/1.0.32 (iPhone; iOS 10.1.1; Scale/2.00)
Authorization: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkdldCB5b3VyIG93biB0b2tlbiEiLCJpYXQiOjE1MTYyMzkwMjJ9.12neWKBPl2q0alhnEiJ_g018_0YHtZMaFzCjsWs0VE

{
  "ID": 1,
  "Name": "Admin User",
  "Username": "XYZ",
  "EMail": "dev@nonexistingdomain.com",
  "Roles": [
    {
      "ID": 1,
      "Name": "Admin",
      "Menu":[
        {
          "Path": "#/admin",
          "Icon": "fa-user",
          "Order": "1",
          "Roles": "READ,WRITE",
        }
      ]
    }  
}     
```

真的很棒！使用 Burp 的 Intruder 功能，我們可以通過暴力窮舉`{id}`參數來取得所有(共8位)管理員的用戶名與電子郵件。

![](https://i.imgur.com/iluoWSf.png)

現在我們已取得管理員帳戶名可以嘗試登入。讓我們使用從[Seclists](https://github.com/danielmiessler/SecLists/tree/master/Passwords/Common-Credentials)中獲取通用密碼列表在觸動警報之前運行一個快速暴力破解程式。

幸運的是，其中一位管理員帳戶的密碼強度較弱，並且該應用程式在登入頁面中沒有任何速率限制。通過取得的管理員權限，我們可以做任何事情，從添加或刪除用戶，修改移動應用程序中顯示的內容，向終端用戶發送通知以及做許多更多很多有趣的事情。

![](https://i.imgur.com/jZQDhGv.png)

將各個思路組合在一起，以便在 Web應用程式上取得管理員權限實在十分有趣。我還在[SecDevOps](https://secdevops.ai/ios-static-analysis-and-recon-c611eaa6d108)上撰寫了關於iOS應用程式靜態分析的[入門](https://secdevops.ai/ios-static-analysis-and-recon-c611eaa6d108)。懇請撥冗參閱 ;）

不要猶豫，歡迎發表並回饋些意見或評論。如果願意的話，你也可以在[Twitter](https://twitter.com/67616d654661636)上直接私訊我。