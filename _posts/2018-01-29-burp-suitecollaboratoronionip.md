---
title: 使用Burp Suite的Collaborator查找.Onion隱藏服務的真實IP地址
layout: post
author: NotSurprised
source-url: http://digitalforensicstips.com/2017/11/using-burp-suites-collaborator-to-find-the-true-ip-address-for-a-onion-hidden-service/
tags: forensics
---

發佈於2017年11月23日

在屬於感恩節的這一天，我要寫一些與生活息息相關並令人喜愛的東西：填充。我現在可不是在跟你聊今天下午茶的美味麵包還是啥的，我正在說的是將Payloads填充到網站上來尋找漏洞這件事。

我們總是喜歡把奇怪的東西餵進網站。例如我們邊期待能達成SQL injection邊把我們的髒東西： `' or 1-1;` 餵給網站，我們塞了一些 `; cat / etc / passwd` 希望取得Command injection，我們把 `alert(“BEEP!!!”)` 當成萬能鑰匙插入每個鎖孔希望能XXS，我們甚至走火入魔填入我們的信用卡號碼，然後幻想它會有如[1967年星際爭霸戰The Trouble with Tribbles](https://www.youtube.com/watch?v=rQ6LC-olw9Q)情節中的病毒自動蠶食資源充值。

有時我們會立即收到來自我們Payload的即時反饋，並使我們可以在幾秒鐘內確認一個漏洞的存在。例如我們輸入 `' or 1-1;` 並以此繞過登錄畫面，我就可以開啟我的SQL injection花式技巧工具箱對它予取予求。但問題來了，當你注入Payload的地方回應總是高延遲該如何是好？那麼如果我現在對一個網站注入的Payload並不馬上執行，需要等到某個管理員在星期一上午查看日誌才發動該怎麼辦？如果我們希望能夠檢測Payload是否正常工作，那麼我們就需要建立一個每天24小時持續性的監聽系統。

Burp Suite在2015年推出“Burp Collaborator”讓這件事變得更加容易。被免費打包同捆在Burp Suite Professional一起提供的“Burp Collaborator”是一個伺服器，它每年365天、每天24小時監聽您的Payload並進行後續反饋。(如果你沒有間歇性停電問題且有放好乖乖的話)

![](https://i.imgur.com/HCAY8ot.png)

截圖如上所示，我可以點擊“copy to clipboard”來生成一個我可以在任何Payload中使用的唯一的URL。

![](https://i.imgur.com/lndZ8SJ.png)

如果任何人或任何東西查看這個URL或訪問它，我會在我的Burp Suite Collaborator客戶端獲得一個通知。

![](https://i.imgur.com/LsrrUek.png)

這是功能是如此令人驚艷且難以置信的強大。現在我們已經有系統來補完Payload，並且無論我們處理多長時間的延遲，都能聽取它們的反饋。正如早些時候官方的Burp Suite twitter feed所說的，如果你沒有進行[帶外應用安全測試（OAST）](http://blog.portswigger.net/2017/07/oast-out-of-band-application-security.html)，那麼你就做錯了。

![](https://i.imgur.com/5AShOCQ.png)

好的，這個真的非常簡單，也讓我們的更加興奮期待下一步，

![](https://i.imgur.com/qhrynr9.png)

您覺得我們應該從哪裡開始亂塞我們新的Payload？如果你興奮地說“無所不在!!!!”，那麼我喜歡您的風格，並完全同意這個意見！你知道嗎？一位名叫James Kettle的大神也同意了這個觀點，並在今年早些時候寫了一個叫做 [“Collaborator Everywhere”](https://github.com/PortSwigger/collaborator-everywhere) 的Burp Suite Professional插件。作者還寫了一篇名為[“Cracking the Lens: Targeting HTTP’s Hidden Attack-Surface”](http://blog.portswigger.net/2017/07/cracking-lens-targeting-https-hidden.html)的精彩Blog貼文，他在這篇文章裡向全世界介紹了他的插件。我的朋友Kat在Blackhat舉辦期間發給我這個連結，而我當時就坐在拉斯維加斯的一個戶外酒吧裡像個怪人一樣用我的手機把它從頭讀到尾，它好到我媽問我為何跪在電腦前，沒在唬的。

Collaborator Everywhere希望通過Burp Suite自動將這些Collaborator payloads注入到我們所進行的網路瀏覽中來幫助我們識別後端系統和進程。而它究竟做了什麼？看看我剛剛瀏覽我的Blog時它自動插入的一些Header。

![](https://i.imgur.com/SxIX7Wz.png)

它會訪問一個特定的網站，所以我會從我的一個payload injection獲得了相應的DNS查詢：

![](https://i.imgur.com/mzTBKHO.png)

James還釋出了一個[黑帽演講(你可以在這裡看到)](https://www.youtube.com/watch?v=zP4b3pw94s0)，他談論了所有他使用這些技術所完成的偉業。在觀看演講的過程中，我認為這種技術可能可被用來識別TOR .onion所隱藏的服務真實IP地址。

我啟動了我的TOR瀏覽器，並為其配置Burp Suite連接。然後我瀏覽多個.onion隱藏服務，看看他們中的任何一個會給我一個Collaborator的pingback。最後，在我瀏覽到第二十個網站時，它成功了 :P

![](https://i.imgur.com/0TwVi8y.png)

我現在有一個與.onion隱藏服務相關聯的伺服器的真正IP地址，因為它查找了它被提交的含餌Header。

![](https://i.imgur.com/ahfdcGO.png)

我鼓勵您在您擁有或合法擁有測試權限的網站上使用這些技術。他們易於使用、有趣且非常有效。


11/24/2017更新：

我發布的這條推文頗受歡迎，並引發了包括[@cchuatl](https://twitter.com/cchuatl)，[@albinowax](https://twitter.com/albinowax)和[@einaros](https://twitter.com/einaros)在內的好幾個人私訊我有趣的後續意見。該流程的關鍵之一即是該pingback來自很可能非常靠近主機伺服器DNS解析伺服器，但並不一定如此。而這個想法始終存在我的腦海中，這也就是為什麼我使用“關聯”而不是“擁有”的說法，但這方法絕對能夠增加隱藏地址的清晰度。

更多像我此次提出的反饋正是使資安社群成為更為美好聚集地的一部分。我的目標是不公開任何人的.onion服務，這就是為什麼我清理了所有的屏幕截圖，但在上述截圖情況應非實際位址，但根據網站的內容以及解析器分析的IP地址與我預計的託管位置其實是內聯的，所以我相信它非常接近主機伺服器了。