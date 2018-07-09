---
title: LM, NTLM, Net-NTLMv2 我的天呀！
layout: post
author: jhe
source-url: https://medium.com/@petergombos/lm-ntlm-net-ntlmv2-oh-my-a9b235c58ed4
tags:
- Windows
- NT-Hash
---

# LM, NTLM, Net-NTLMv2, oh my!

When attacking AD, passwords are stored and sent in different ways, dependeing on both where you find it and the age of the domain. Most of these hashes are confusingly named, and both the hash name and the authentication protocol is named almost the same thing. It doesn't help that every tool, post and guide that mentions credentials on Windows manage to add to the confusion. This is my attempt at clearing things up.
>當攻擊 AD 時通行碼被用各種不同的方式儲存與傳送，視你在哪找到跟 domain 的年紀而定。大部分的雜湊的命名都很讓人疑惑，而且雜湊名稱與驗證協議幾乎是一樣的稱呼。在任何工具、文章及指南中提到 Windows 身分驗證資時更增加了困惑度。[弄清楚些事情](https://xkcd.com/927/)，是我的主要目的。

This post is geared towards pentesters in an AD environment, and it favors practical attacks against the different hash formats. A lot of inspiration is taken from byt3bl33der's awesome article, "Practical guide to NTLM Relaying in 2017". If I'm missing something, please hit me up.
>這篇是滲透測試者置身於 AD 環境面向的文章，而且偏向於對於不同雜湊格式的實際攻擊。受到 byt3bl33der 超棒的文章 "[Practical guide to NTLM Relaying in 2017](https://byt3bl33d3r.github.io/practical-guide-to-ntlm-relaying-in-2017-aka-getting-a-foothold-in-under-5-minutes.html)" 超大的啟發，如果我漏了什麼請[讓我知道](https://twitter.com/petergombos)。

All example hashes are from Hashcat's example hashes page. The hashes I'm looking at is LM, NT, and NTLM (version 1 and 2).
>所有的範例雜湊都是從 Hashcat 的[範例雜湊頁面](https://hashcat.net/wiki/doku.php?id=example_hashes)來的。我正在研究的雜湊是 LM, NT 及 NTLM(版本 1 跟 2)。

## LM
About the hash
>關於這個雜湊

LM-hashes is the oldest password storage used by Windows, dating back to OS/2 in the 1980's. Due to the limited charset allowed, they are fairly easy to crack. You can obtain them, if still available, from the SAM database on a Windows system, or the NTDS database on the Domain Controller. LM was turned off by default starting in Windows Vista/Server 2008, but might still linger in a network if there older systems are still used. It is possible to enable it in later versions through a GPO setting (even Windows 2016/10).
>時間回溯到 1980 年代的 OS/2，LM 雜湊是 Windows 所使用最古老的通行碼儲存方式。因為字元集的限制，他們很容易被破解。你可以在 Windows 系統上的 SAM 資料庫或是 Domain 控制伺服器的 NTDS 資料庫輕易地取得。LM 從 Windows Vista/Server 2008 開始預設是關閉的，但還是有可能徘徊一個擁有古老一點的系統網路中。在新一點的版本中可以 [GPO 設定](https://support.microsoft.com/en-us/help/299656/how-to-prevent-windows-from-storing-a-lan-manager-hash-of-your-passwor)開啟(在 Windows 2016/10 也可以)。 

When dumping the SAM/NTDS database, they are shown together with the NTHash, before the colon.

>將 SAM/NTDS 的資料倒出來的時候，你會看到分號前的是 NT 雜湊。

Example
>例如

`299BD128C1101FD6`

The algorithm
>演算法

```
1. Convert all lower case to upper case
2. Pad password to 14 characters with NULL characters
3. Split the password to two 7 character chunks
4. Create two DES keys from each 7 character chunk
5. DES encrypt the string "KGS!@#$%" with these two chunks
6. Concatenate the two DES encrypted strings. This is the LM hash.
```

```
1. 將所有的字元轉成大寫
2. 用 NULL 字元將通行碼補到 14 個字元
3. 將通行碼分成兩堆，一堆 7 個字元
4. 為兩堆通行碼各產生一個 DES 密鑰
5. 兩堆跟字串"KGS!@#$%"一起做 DES 加密
6. 將兩個 DES 加密後的字串串在一起。這就是 LM 雜湊。
```

Cracking it
>破解

```
john --format=lm hash.txt
hashcat -m 3000 -a 3 hash.txt
```

## NTHash (A.K.A NTLM)
About the hash
>關於這個雜湊

This is the way passwords are stored on modern Windows systems, and can be obtained by dumping the SAM database, or using Mimikatz. They are also stored on domain controllers in the NTDS file. These are the hashes you can use to pass-the-hash.
>這是當前流行的 Windows 系統所使用的通行碼儲存方式，可以從 SAM 資料庫倒出來或使用 Mimikatz 來取得。他們也被存在 Domain 控制伺服器上的 NTDS 檔案中。這是你可以用來 [pass-the-hash](https://en.wikipedia.org/wiki/Pass_the_hash) 的雜湊。

Usally pepole call this the NTLM hash (or just NTLM), which is misleading, as Microsoft refers to this as the NTHash (at least in some places). I personally recommend to call it the NTHash, to try to avoid confusion.
>通常人們稱之為 NTLM 雜湊(或就是 NTLM)，當 Miscrosoft 提到這個 NT 雜湊(至少在某些地方)的時候非常的誤導。我個人建議稱它為 NT 雜湊以避免混淆。

Example
>例子

`B4B9B02E6F09A9BD760F388B67351E2B`

The algorithm
>演算法

`MD4(UTF-16-LE(password))`

UTF-16-LE is the little endian UTF-16. Windows used this instead of the standard big endian, because *Microsoft*.
>UTF-16-LE 是 逆序(編按:小頭端)版本的 UTF-16。Windos 使用這個而非順序(編按: 大頭端)，因為它是*微軟*。

Cracking it
>破解它

```
john --format=nt hash.txt
hashcat -m 1000 -a 3 hash.txt
```

## NTLMv1 (A.K.A Net-NTLMv1)
About the hash
>關於這個雜湊

The NTLM protocol uses the NTHash in a challenge/response between a server and a client. The v1 of the protocol uses both the NT and LM hash, depending on configuration and what is available. The Wikipedia page on NT Lan Manager has a good explanation.
>NTLM 協議在伺服器與客戶端挑戰/回應中使用 NT 雜湊。版本1基於設定與可用性來決定是否同時使用了 NT 與 LM 雜湊，維基百科上關於 [NT 內網管理者](https://en.wikipedia.org/wiki/NT_LAN_Manager#NTLMv1)有很好的解釋。

A way of obtaining a response to crack from a client, Responder is a great tool. The value to crack would be the `K1 | K2 | K3` from the algorithm below. Version 1 is deprecated, but might still be used in some old systems on the network.
>一個從客戶端取得回應並破解的方法，[Responder 是一個很好用的工具](https://github.com/lgandx/Responder)。需要破解的值將會是下面演算法提到的 `k1 | k2 | k3`。版本1已經不建議使用了，但仍舊可能會被一些網路上老舊的系統使用。

Example
>例子

```
u4-
netntlm::kNS:338d08f8e26de93300000000000000000000000000000000:9526fb8c23a90751cdd619b6cea564742e1e4bf33006ba41:cb8086049ec4736c
```

The algorithm
>演算法
```
c = 8-byte server challenge, random
K1 | K2 | K3 = LM/NT-hash | 5-bytes-0
response = DES(K1, C) | DES(K2, C) | DES(K3, C)
```

```
c = 8 個位元組的伺服器挑戰，隨機的
K1 | K2 | K3 = LM/NT 雜湊 | 5 位元組個 0
response = DES(K1, C) | DES(K2, C) | DES(K3, C)
```

Cracking it
>打破它

```
john --format=netntlm hash.txt
hashcat -m 5500 -a 3 hash.txt
```

## NTLMv2 (A.K.A Net-NTLMv2)
About the hash
>關於這個雜湊

This is the new and improved version of the NTLM protocol, which makes it a bit harder to crack. The concept is the same as NTLMv1, only different algorithm and responses sent to the server. Also captured through Responder or similar. Defualt in Windows since Windows 2000.
>這是 NTLM 協議最新並且改進過的版本，讓它更難被破解。整個概念跟 NTLMv1 一樣，只有送回伺服器的演算法與回應不同。還是可以用 Responder 或是類似工具擷取到。從 Windows 2000 預設開啟。

Example
>例子

```
admin::N46iSNekpT:08ca45b7d7ea58ee:88dcbe4446168966a153a0064958dac6:5c7830315c7830310000000000000b45c67103d07d7b95acd12ffa11230e0000000052920b85f78d013c31cdb3b92f5d765c783030
```

The algorithm
>演算法

```
SC = 8-byte server challenge, random
CC = 8-byte client challenge, random
CC* = (X, time, CC2, domain name)
v2-Hash = HMAC-MD5(NT-Hash, user name, domain name)
LMv2 = HMAC-MD5(v2-Hash, SC, CC)
NTv2 = HMAC-MD5(v2-Hash, SC, CC*)
response = LMv2 | CC | NTv2 | CC*
```

```
SC = 8 位元組伺服器的挑戰，隨機的
CC = 8 位元組客戶端的挑戰，隨機的
CC* = (X, time, CC2, domain 名稱)
v2-Hash = HMAC-MD5(NT-Hash, 使用者名稱, domain 名稱)
LMv2 = HMAC-MD5(v2-Hash, SC, CC)
NTv2 = HMAC-MD5(v2-Hash, SC, CC*)
response = LMv2 | CC | NTv2 | CC*
```

Cracking it
>搞它

```
john --format=netntlmv2 hash.txt
hashcat -m 5600 -a 3 hash.txt
```

## IN SUMMARY / 總結

LM-and NT-hashes are ways Windows stores passwords. NT is confusingly also known as NTLM. Can be cracked to gain password, or used to pass-the-hash.
>LM 與 NT 雜湊是Windows 不同儲存通行碼的方式。NT 本身是非常令人疑惑的也被當成是 NTLM。可以被破解並取得通行碼，或是用在 pass-the-hash。

NTLM-v1/v2 are challenge response protocols used for authentication in Windows environments. These use the NT-hash in the algorithm, which means it can be used to recover the password through Brute Force/Dictionary attacks. They can also be used in a relay attack, see byt3bl33d3r's article [1].
>NTLM-v1/v2 是挑戰與回應協議，用來在 Windows 環境中認證用的。這些在演算法中用了 NT 雜湊，表示可以用窮舉/字典攻擊來取得通行碼。也可以被用在轉傳攻擊，可以看看 byt3bl33d3r 的文章[1]。

If you're still confused, I would recommend reading the Wikipedia articls. I do hope this intro clears up the confusing language and can somehow help you.
>如果你還是很疑惑，我推薦你讀維基百科的文章。我希望這個簡介解開了一些疑惑，並可以幫助到你們。

### Sources / 資料來源

[1] https://byt3bl33d3r.github.io/practical-guide-to-ntlm-relaying-in-2017-aka-getting-a-foothold-in-under-5-minutes.html

[2] https://technet.microsoft.com/en-us/library/dd277300.aspx#ECAA

[3] https://en.wikipedia.org/wiki/LAN_Manager

[4] https://en.wikipedia.org/wiki/NT_LAN_Manager

[5] https://en.wikipedia.org/wiki/Security_Account_Manager

[6] https://hashcat.net/wiki/doku.php?id=example_hashes