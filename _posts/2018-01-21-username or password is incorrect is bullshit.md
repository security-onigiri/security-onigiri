---
title: 使用者名稱或密碼錯誤根本是鬼扯
layout: post
author: jhe
tags: Web
source-url: https://hackernoon.com/username-or-password-is-incorrect-is-bullshit-89985ca2be48
---

# username or password is incorrect is bullshit

There's a security best practice where sign ins aren't supposed to say "password is incorrect". Instead they're supposed to say the "username or password is incorrect". This "best practice" is bullshit.

>有一個資安最佳實踐表示登入不該回應 "密碼錯誤" 而是應該回應 "使用者名稱或密碼錯誤" 這個"最佳實踐"根本鬼扯。

Strip and GitHub's sign ins for example follow this practice.

> Strip 與 Github 的登入遵守了這個實踐如下所示

![](https://cdn-images-1.medium.com/max/1000/1*hisYwzk7kIhUdfxZ9vwBBA.png)

![](https://cdn-images-1.medium.com/max/1000/1*Nie0O5MurE_fvTuKbYkXzw.png)

The idea is if an attacker knows a username, he or she could concentrate on that account using SQL injection, brute forcing the password, phishing, and so on.

>用意為當一個攻擊者知道一個使用者名稱，他或她可以專注在這個讓帳戶之上，使用如資料隱碼攻擊、暴力嘗試密碼、釣魚等攻擊。

Here's the problem.

>問題在這。

![](https://cdn-images-1.medium.com/max/1000/1*k9s51jl1KGEx59iyiojYPg.png)

![](https://cdn-images-1.medium.com/max/1000/1*XjOkBwmPXh613-nldQlSYQ.png)

All a hacker has to do is sign up to know whether the username is valid or not. Why bother then with obfuscating the sign in ? Only the dumbest, laziest hacker is stopped by the "username or password is incorrect" sign in. You gain no security, yet your customers lose clarity.

>一個攻擊者需要做的就只有註冊，便可以知道這個使用者名稱是否為有效的。為什麼模稜兩可的登入可以擾煩到他們呢 ? 只有最笨、最懶的駭客會被"使用者名稱或密碼錯誤"登入給阻止。你並不會從中得到任何的安全，而是客戶們失去了清晰度。

Stipe has their form submission behind reCAPTCHA to prevent naive scripts attacking their sign up. However this has been broken multiple times (1, 2) and likely won't ever be perfect. Even if reCATCHA was perfect, a hacker could manually validate their usernames of interest by trying to sign up, then automate an attack on the sign in page.

>Strip 的表單提交背後有 reCAPTCHA 來避免天真的腳本攻擊他們的註冊功能。然而這已經被玩壞好多次了([1](https://www.blackhat.com/docs/asia-16/materials/asia-16-Sivakorn-Im-Not-a-Human-Breaking-the-Google-reCAPTCHA-wp.pdf), [2](https://github.com/eastee/rebreakcaptcha))

To prevent attackers from knowing whether an account exists or not your signup must only take an email address and provide no feedback in the UI if the sign up succeeded or not. Instead the user would receive an email saying they're signed up. The only way an attacker would know if an account exists is if they had access to the target's email.

>為了避免攻擊者們得知一個帳戶是否存在，你的註冊必須只透過一個 email 地址而且在 UI 中不提供任何反饋，無論成功與否。取而代之的是使用者將收到一封 email 表示他們已經註冊。攻擊者唯一會知道帳戶存在的方法就是，他們已經可以存取目標的 email。

Barring that, "username or password incorrect" is just bullshit.

>喔還有，"使用者名稱或是密碼錯誤"根本狗屎爛蛋。