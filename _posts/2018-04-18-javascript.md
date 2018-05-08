---
title: 挖礦JavaScript代碼的感染趨勢
layout: post
author: NotSurprised
source-url: https://blog.fortinet.com/2018/02/07/the-growing-trend-of-coin-miner-javascript-infection
tags:
- Web
- Coin Miner
- Obfuscation Technique
---

威脅研究

作者 [Eric Chong](https://www.fortinet.com/blog/search.html?author=Eric+Chong) | 2018年2月8日

## 1. CharCode JavaScript 
2017年12月6日，FortiGuard實驗室發現了一個被入侵的網站 - acenespargc.com。查看源碼，我們注意到一個可疑的加密腳本，它使用eval（）函數將所有字符轉換為數字。我們使用了一個名為[CharCode Translator](http://jdstiles.com/java/cct.html)的工具將這些數字轉換  回程式碼。然後我們就可以反查到將使用者轉址到詐騙網頁或釣魚網站的鏈接。

![](https://i.imgur.com/p2wS40L.png)
`第1部分`

![](https://i.imgur.com/emTmBaL.png)
`第2部分`

以上只是一個簡單的例子。犯罪者實際上可以根據地理位置自定義釣魚的內容，為了更好地避開檢測機制，它會在檢測到您之前曾訪問過釣魚頁面時消失。

使用這種技術，犯罪者可以隱藏惡意/網路釣魚/廣告URL，以免被肉眼看到。 

正如你將在下面看到的，犯罪者現在已經採用這種技術來隱藏在受感染的網站中挖掘加密貨幣的JavaScript，這樣任何訪問該網站的人都將“受到感染”，並且他們的電腦將持續為犯罪者提供加密演算資源。我們將此類活動歸類為惡意行為，因為它未經其許可使用其他人的資源。

## 2.使用打包工具隱藏CoinHive腳本  

在12月28日，FortiGuard實驗室通過一位客戶的關係發現了另一個惡意網站正使用我們上面介紹的混淆技巧 - romance-fire[.]com。該網站包含用於加密貨幣挖掘的混淆惡意代碼。

我們發現了編碼腳本，並使用[ packer tool ](http://matthewfl.com/unPacker.html)來解壓縮腳本，發現該腳本與CoinHive有連接。

![](https://i.imgur.com/jyV0AJw.png)
`來自源代碼的JavaScript`

![](https://i.imgur.com/IjGjCUr.png)
`解壓縮JavaScript - 第1部分`

我們注意到URL（hxxp：//3117488091/lib/jquery-3.2.1.min.js？v=3.2.11）似乎不是有效的IP或網域。於是我們做了一些研究，我們在[KLOTH.NET](http://www.kloth.net/services/iplocate.php)上轉換它後，發現'3117488091'是185.209.23.219的十進制IP。以下是結果：

![](https://i.imgur.com/jO6HlvS.png)
該網站將URL轉換為`hxxp：//185.209.23.219/lib/jquery-3.2.1.min.js？v=3.2.11)`。我們從該URL中查到相同的JavaScript模式，因此我們再次解壓縮腳本。

![](https://i.imgur.com/Z32sbbB.png)
`解壓縮JavaScript - 第2部分`

在最後一輪解包之後，我們終於能夠查看包含CoinHive URL的完整程式碼：

![](https://i.imgur.com/TU9SUa0.png)
`解壓縮JavaScript - 第3部分`

## 3.來自GitHub的Coin礦工 

2018年1月26日，我們發現了另一個網站 - sorteosrd[。]com，它也通過劫持訪問者的CPU來挖掘加密貨幣。這種加密惡意軟體再次允許劫持者在未經該電腦用戶許可的情況下藉由挖掘數位貨幣受益。我們相信這個網站可能已被挾持或網站管理員自己本身如此使用。

![](https://i.imgur.com/QNmQTW1.png)

`hxxp：//sorteosrd.com網站的源代碼：`
![](https://i.imgur.com/RSEb8qr.png)
`暗中加密對用戶設備的影響`

正如我們從上面的截圖中可以看到的那樣，加密貨幣挖礦機在訪問該網站後充分利用其CPU時會大大降低PC的速度。

## 4.被挾持的網站 - 感染CryptoCoin挖礦的黑莓 
CoinHive腳本的另一個被挾持的例子是一個絕對會令人驚訝的網站 - blackberrymobile[.]com上發現的。
![](https://i.imgur.com/wjclu4E.png)
`即使是黑莓網站也在短時間內被盜用在挖掘Monero加密貨幣。`

## 5.被挾持的網站 - Milk New Zealand 感染 deepMiner 工具
此外，我們還發現New Zealand最大的日記農場集團之一──Milk New Zealand也遭到了破壞。我們的AntiVirus實驗室檢測到來自該網站的惡意活動，所以我們查看他的源碼，發現其有使用github上的deepMiner工具，其中發現了一個用於挖掘Monero、Electroneum、Sumokoin等的腳本。請參見下面的截圖： 

![](https://i.imgur.com/QXgfpMu.png)
`使用deepMiner的JavaScript`

根據上面屏幕截圖中的數據，我們了解到，這種腳本在其網域中使用DDNS，並且只會將CPU使用率增加50％，以使終端用戶受害者的負面使用者體驗不太明顯。

## 6.甚至YouTube也會通過投放挖礦廣告

加密貨幣挖掘惡意軟體的問題越來越嚴重。隨著希望通過劫持CPU以從加密貨幣獲得收益的犯罪者數量不斷增加，加密技術越來越多地出現在惡意軟體中。一周前，一位犯罪者設法將挖礦腳本注入到線上廣告中後，幾個惡意廣告隨即在YouTube上彈出。幸運的是，YouTube迅速發現了該問題，並在兩小時內刪除了受影響的廣告。

![](https://i.imgur.com/CO4RnSz.png)
`惡意加密YouTube廣告`

## 你能做些什麼來防止或避免Coin Miner劫持？

清除瀏覽器緩存，或安裝ccleaner軟體，從電腦中查找並刪除不需要的文件和無效的Windows註冊表項。
在瀏覽器中禁用JavaScript或運行腳本攔截工具或附加元件。
安裝防病毒軟體，如FortiClient。
安裝並運行AdBlocker或類似的工具，例如Ghostery。
FortiGuard已將此Blog中列出的所有URL列進黑名單。 

## IOCs:

被挾持的網站：

* acenespargc[.]com
* www[.]romance-fire[.]com
* milknewzealand[.]com

已觀察到的虛擬貨幣挖掘網址：

* hxxp://coinhive[.]com
* hxxp://minerhills[.]com
* hxxp://crypto-webminer[.]com
* hxxp://sorteosrd[.]com
* hxxp://greenindex[.]dynamic-dns[.]net
* hxxps://github[.]com/deepwn/deepMiner