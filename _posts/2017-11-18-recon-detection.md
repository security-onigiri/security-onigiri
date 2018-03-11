---
title: Blue Team：檢測偵察活動
layout: post
author: NotSurprised
tags: recon
source-url: http://forensicmethods.com/recon-detection
---

# **Blue Team：檢測偵察活動**

附註：本文最初出現在 CrowdStrike 部落格上。

少數blue team會願意花費時間在檢測偵察活動這件事上。網路受到近乎連續掃描的流量衝擊，然後在其中分辨可疑目標活動與網路雜訊可能非常困難。但是，在攻擊的早期階段，您仍然可以採取一些措施來對抗偵察活動。

## 最好的偵查方式是自己做偵查
我們都知道偵察活動是無所不在的，而最好的防守就是藉由掃描您自己的網路來在這場攻防遊戲中保持領先。規劃定期的資產識別和漏洞掃描，並以最優先級考慮漏洞更新。如果您團隊中的某人正在定期測試關鍵網頁應用程序中的 SQL injection 漏洞，那您則不必在某個周末花費時間來修復新的 sqlmap pwnage。同樣的預先籌備行動可以幫助緩解主動和被動的偵察活動帶來的壓力。我們的團隊經常幫助客戶進行開源數據收集，藉以識別公司或員工資產是否有不必要的訊息洩漏。這本該是 red team 應該做的─幫助組織預見攻擊並限制其攻擊面。

## 檢測 - 深入查看
掃描偵查活動通常不難自己檢測。例如，以下的Log難道像是正常Googlebot的活動？

 ![](https://i.imgur.com/OxFusYv.png)

圖1：在部落格中所見的 Nikto 的掃描內容

我們甚至可以通過頻率分析來識別並迴避探測，例如監視每個 IP 地址的故障次數或堆疊用戶代理字串，藉以發現異常。偵查對手在偽造用戶代理中出現錯誤或者無法更改掃描儀提供的默認值的數量是極其驚人的。

```
Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; WOW64; Trident/6.0)
Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0)
mozilla/5.0(compatible; MSIE 10.0; Windows NT 6.1; Trident/6.0)
Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)
Mozilla/5.0 (Windows; U; Windows NT 6.1; ru; rv:2.2.0.3) Gecko/20100101 Firefox/37.0
Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10; rv:33.0) Gecko/20100101 Firefox/33.0
Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2224.3 Safari/537.36
Mozilla/5.0 (Android 4.4; Mobile; rv:41.0) Gecko/41.0 Firefox/41.0
```

圖2：用戶的堆疊分析。你可以發現異常值嗎？

雖然這看起來很簡單容易，但導致檢測無效的其實是當您面向網路服務器的巨量的偵察活動，會有杯水車薪之感。所以相反的，應該將您的努力集中在您的內部網絡上。許多組織都過度資源傾斜在防衛面向公網路的資源層面，但內部伺服器卻在很大程度上被忽視。這是極其危險的，因為攻擊者一旦在內部網路中獲取立足之地，他們通常會掃描內部網頁應用程序來幫助轉發，藉以提升權限並收集敏感數據。
在檢查內部伺服器 Log 時，偵測活動檢測則更為可行。您應該可以看到企業中存在的設備的用戶代理字符串相對較小─因此查詢內部資源的 Googlebot 將非常可疑。特別是一旦過濾掉自己組織的內部漏洞掃描器活動，掃描偵查活動也應更易於識別。想像一下在內部應用伺服器 Log 中看到類似圖3的異常情況。

 ![](https://i.imgur.com/H2DuQKz.png)

圖3：識別Sqlmap掃描的Web日誌

## 自動檢測
通過對內部 Log 的間歇性手動審查，能自動檢測常見的偵察活動則更為理想。監控模式下的 Web 應用程序防火牆等工具可以可靠地檢測常見的偵察活動，如 SQL injection，當僅針對內部請求時，警報應更為準確。然而，也許最具有效的偵察能力是網路安全監控（NSM）。雖然它需要內部傳感器布署和可見性，但可以在整個攻擊週期中分配資源。一個針對“出色的新興威脅公開規則”快速總結則顯示了各種可用於在偵察階段檢測惡意行為的特徵。圖4中顯示了兩個例子。

```
| alert tcp $EXTERNAL_NET any -> $HTTP_SERVERS $HTTP_PORTS (msg:”ET SCAN Possible SQLMAP Scan”; flow:established,to_server; content:” AND “; http_uri; content:”AND (“; http_uri; pcre:”/\x20AND\x20[0-9]{6}\x3D[0-9]{4}/U”; detection_filter:track by_dst, count 4, seconds 20; reference:url,sqlmap.sourceforge.net; reference:url,www.darknet.org.uk/2011/04/sqlmap-0-9-released-automatic-blind-sql-injection-tool/; classtype:attempted-recon; sid:2012755; rev:3;) alert http $EXTERNAL_NET any -> $HTTP_SERVERS any (msg:”GPL EXPLOIT unicode directory traversal attempt”; flow:to_server,established; content:”/..%c1%9c../”; http_raw_uri; reference:bugtraq,1806; reference:cve,2000-0884; reference:nessus,10537; classtype:web-application-attack; sid:2100983; rev:19;) | 
| -------- | 
```

圖4：偵察活動的示例新興威脅簽名

一旦監控到位並且傳感器已被調整至最佳，NSM 警報就會像圖5中的那樣，可以很容易地進行偵察檢測。



```
| {“timestamp”:”2016-02-10T09:50:04.005484+0000″,”flow_id”:140389013543568,”event_type”:”alert”, “src_ip”:”172.16.30.149″,”src_port”:56173,”dest_ip”:”172.16.10.70″,”dest_port”:80,”proto”:”TCP”,”alert”:{“action”:”allowed”,”gid”:1,”signature_id”:2100983,”rev”:19,”signature”:”GPL EXPLOIT unicode directory traversal attempt”,”category”:”Web Application Attack”,”severity”:1,”tx_id”:0}, “payload_printable”:”0mk………….GET /scripts/..%c1%9c../winnt/system32/cmd.exe?/c+dir HTTP/1.1\r\nHost: 172.16.10.70\r\nConnection: Keep-Alive\r\nQua”,”stream”:1} | 
| -------- | 
```

圖5：應用服務器掃描觸發的Suricata警報示例

另一個NSM選項越來越受歡迎則是 Bro IDS。Bro 的事件引擎和策略腳本給予非常好的異常檢測。更幸運的是，已經有腳本可用於在 SQL injection 之類的事件上進行警報，例如 detect-sqli.bro。為了使檢測成為可能，您將需要擴展您的工作並將警報導入分析工具。我們的團隊使用 Splunk，圖6顯示了用於分析的 Bro SQL injection 警報的集合。

 ![](https://i.imgur.com/vB2K20C.png)

圖6：Bro SQL注入警報導入Splunk

## 結論

雖然在殺戮鏈 (kill chain）中有更多收益較高的機會可以進一步檢測攻擊者的活動，但我們認為檢測偵察活動不應該被忽視。偵察自己的網路，並由攻擊者觀點來獲得潛在弱點。網路結構本該規劃成可監控關鍵的內部網路和系統，並將偵查工作集中在那裡。從自我偵查開始，並以此持續優化您個人的高保真度特徵值。