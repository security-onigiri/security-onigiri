---
layout: post
title: Rails on Ubuntu qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
author: bananaappletw
source-url: https://www.phusionpassenger.com/library/indepth/integration_modes.html 
tags:
  - ruby on rails
  - nginx
  - deploy 
date: 2017-06-22 12:39:00
---
# 分析惡意 PowerShell 腳本 - 發現並解碼篇



![](https://i.imgur.com/i5Je5MA.png)

PowerShell 無處不在，現在的環境中我遇到越來越多的惡意 PowerShell 腳本 為什麼黑客那麼愛用 PowerShell 呢? 因為它原生內建於許多不同版本的Windows，並且有完整的權限可以操作 WMI 與 .Net Framework 並進一步的在記憶體去執行惡意程式碼從而避開防毒。對了，我有提到這樣同時也常遇到缺乏可用的日誌記錄?

在我的分析過程中呢，其中有幾個跡象表示 PowerShell 已經被黑客利用了，其中包括在硬碟上安裝服務、寫入註冊表或是 PowerShell 腳本。如果這時候有啟用日誌收集，可以提供許多有用的分析資訊。 
這篇文章適合你是分析人員但並不熟悉 PowerShell，我會討論一些在我的分析過程中我如何找出惡意的 PowerShell 並且運用一些方法解碼混淆過的 PowerShell 腳本。
這系列文章將會有三篇，這只是第一篇。

第一部分: PowerShell 腳本以服務形式安裝
Part 1: PowerShell Scripts Installed as Services 

我在系統事件紀錄檔裡面找到了 PowerShell 腳本被當作服務安裝在系統上。
怎麼找到這些呢? 第一步就是尋找事件辨識碼 (Event ID) 7045. 當系統安裝服務時會有此事件紀錄，如下方圖片範例：
![](https://4.bp.blogspot.com/-GrbYtDNRv6M/WeOOlB5H-rI/AAAAAAAAD9Y/Bp-wKs0dre8Um5tVVaHHpMbnvyCjWFXTwCLcBGAs/s1600/base64_encoded_powershell.png)

值得注意的是：

1) 隨機的服務名稱
2) 服務檔名包含 "%COMSPEC%"，這是 CMD 所用到的系統環境變數
3) 引用 PowerShell 的執行檔案
4) 類似 Base64 編碼後的資料

那麼這一筆資料是怎麼被記錄系統事件裡面的呢? 其實有許多不同的方法可以達到，其中一個方法就是利用 Windows Service Control Manager 去建立一個服務，如下圖 :
![](https://4.bp.blogspot.com/-RcuVJ4ehqtM/WeP3_9GW6YI/AAAAAAAAEA8/4h0XeOkt9NsM8M3hTjOWXHdkYB66pgzLQCLcBGAs/s1600/virtual_machines.png)

下方是兩個相應的系統事件辨識碼 7000 和 7009(如下圖)。
雖然 7009 顯示"The FakeDriver service failed to start.."，但不真的代表指令中的 binpath 執行失敗了。
**請注意!不要將這樣的錯誤訊息認為是 PowerShell 並沒有成功執行。**

![](https://2.bp.blogspot.com/-0V82eDvjXgc/WeP0Z4bSuFI/AAAAAAAAEAs/hH1tjOAfxhQ7AWqDqXUf_mZeWGz9U0SFwCLcBGAs/s1600/7009Error.PNG)
![](https://3.bp.blogspot.com/-nK5UxD9YcTQ/WeP0dttjOkI/AAAAAAAAEAw/LTO3BUtzzJ8m5ESyx8EiqJzcvn_UNYu9ACLcBGAs/s1600/7000_error.PNG)

先前的系統事件 7045 中 PowerShell 腳本是以 Base64 編碼儲存，這邊我們利用Python 去解碼腳本。
這邊有個有趣的地方需要注意，這 Base64 的資料必須以 Unicode 顯示，所以我們必須而外指定解碼。(為了方便顯示，已經將原始的 Base64 資料截斷)

```
import base64
code="JABjACAAPQAgAEAAIgAKAFsARABsAGwASQBtAHAA...."
base64.b64decode(code).decode('UTF16')
```

下方是解碼出來的指令，快速地檢視了一下內容，似乎包含了一個反連 TCP Socket的 IP。

![](https://2.bp.blogspot.com/-9WCaI6omZJg/WeOWxQd6aVI/AAAAAAAAD9k/s4oF-2Ze4t01JEWPVz7YHRFPxUldq3lwwCLcBGAs/s1600/decoded_powershell_b64_notes.PNG)

這類型的程式碼很像是利用 Meterpreter 去設定的反向 Shell. 這類型的 PowerShell 程式碼十分容易去解碼，但真實的情況我們會需要更多的分析。

接下來是另外一個範例，這次是常規的 Base64 編碼。
**注意: %COMSPEC% ，又再次出現並呼叫 PowerShell**

![](https://4.bp.blogspot.com/-CKTEpPrBR2I/WeOe6BSpjUI/AAAAAAAAD90/anLTRSMimCEY6Hn-nHVReZ48YVH1opw6gCLcBGAs/s1600/base64_encoded_example2.PNG)

再次的我們使用 Python 去解碼 PowerShell裡面的 Base64 內容 :
![](https://1.bp.blogspot.com/-ooCoUv0J_M0/WeOf2k9hMqI/AAAAAAAAD98/TQgqdlcR9JIbw6MdYW6G1OWARY4t13A4wCLcBGAs/s640/base64_decoded_2.PNG)

這次拿到的輸出看起來不太有用，但如果我們回去看原本的程式碼，我們可以看見有使用到"Gzip" 和 "Decompress": 

![](https://3.bp.blogspot.com/-OWxmchai4OI/WeOgaDpRZ1I/AAAAAAAAD-I/A3d0qOgWufYuf2-zOqcHJrudn3eCVhHRACLcBGAs/s1600/base64_encoded_example2_b.png)

反向思考一下，這個資料應該是被壓縮並用 Base64 編碼，我們利用 Python 解碼後存成一個檔案並且去試著解壓縮 :


```
import base64
code="H4sICCSPh1kCADEAT..."
decoded=base64.b64decode(code)
f=open("decoded.gzip",'wb')
f.write(decoded)
f.close
```

我使用 7zip 成功的解壓縮了 gzip 檔案，並且沒有得到任何錯誤訊息。
![](https://4.bp.blogspot.com/-0scCvXXxyqM/WePmQuzXjKI/AAAAAAAAEAM/YICKCQd0YPkJFXjwipIXXI5X5c6jwUPHACLcBGAs/s640/zip1.PNG)

現在我試著用文字編輯器打開解壓縮的檔案，希望我能看到一些 PowerShell的程式碼:
![](https://4.bp.blogspot.com/-UlxfDPj865g/WeOjmLv1thI/AAAAAAAAD-c/hMRt6JuGGGsrbUotVJga_VHHYpCvkzgzACLcBGAs/s640/1.PNG)

什麼! 好吧，讓我們用 Hex editor 來看一下:
![](https://3.bp.blogspot.com/-8Js_m556nTA/WeOkIQikXfI/AAAAAAAAD-k/RuvgnLvW4KQmzng-1Ywu1sg-ZwVR7r5cgCLcBGAs/s640/1_in_hex.PNG)

看起來沒甚麼用，所以我開始想這或許是 shellcode。
下一步我試著用 PDF Stream Dumper's shellcode 分析工具，scdbg.exe:

![](https://4.bp.blogspot.com/-GJdfn-h3LVg/WeOk1zaP1UI/AAAAAAAAD-s/ELeodDcIaMcbR1rXgFKYjQqa_JD2MuhEwCLcBGAs/s1600/shellcode.png)

果然! scdbg.exe 可以成功從 shellcode 中提取 IOCs(入侵指標)給我做參考。

先總結一下我在這個 PowerShell 範例中做的事情:
* 解碼 Base64的 PowerShell 字串
* 將解碼內容輸出成 zip 檔案
* 用 7zip 解壓縮 zip 檔案
* 用 scdbg.exe 執行解壓縮出來的檔案

如上所述，我們需要完成解開數個不同的內容才能達到我們要的目標

最後一個範例 : 
![](https://1.bp.blogspot.com/-XWqqzs0Ocs4/WeOmRGRpD9I/AAAAAAAAD-8/fgSrCEDBLu4LTw6icggEmEXe7hqKvDNOACLcBGAs/s1600/base64_3.PNG)

看上去很眼熟，第一步，解碼 UTF-16 Base64 的值，解開後會發現裡面還包含了一個 Base64 :

![](https://4.bp.blogspot.com/-WCQVDNfKOMc/WeOpGnApsaI/AAAAAAAAD_M/jIHTl_Y0sCQ37Rs9-8ka2nkXhP4YKuyRgCLcBGAs/s1600/example_3_b64_decoded.PNG)

看上去還是有混淆的，裡面還在包了一層，非常常見的手法。這次因為沒有引用到 "gzip" 在這個腳本中，所以我將輸出的內容先存檔後使用 7zip 打開試試 :
```
decoded2="nVPvT9swEP2ev+IUR...."
f=open("decoded2.zip,"wb")
f.write(base64.b64decode(decoded2)
f.close()

```

當我試著用 7zip 打開檔案時顯示錯誤:
![](https://3.bp.blogspot.com/-7D53A33kTuU/WeOrYHcJXnI/AAAAAAAAD_Y/zuZBCp0F24ozTIm2kbNT892QCWnsVBntwCLcBGAs/s640/zip_error.PNG)
換成 Windows 的工具也是一樣
![](https://3.bp.blogspot.com/-i1s_585KQgI/WeOsV1c2VJI/AAAAAAAAD_g/siPJKWFK7AEjvqji2ApO6VjccWkH_PQGACLcBGAs/s640/zip_error_windows.PNG)

經過一些研究後，我發現這壓縮檔與 .Net libraries 有關連。身為 Python 愛好者，我想利用 Python 去解決這問題。 Python 是跨平台的但 .net 並不是本身核心元件，所以我使用 Iron Python 去解決這件事 (當然你也可以使用 PowerShell 去解析，但我就是想用 Python)

根據 Iron Python 的官方網站所寫 "IronPython 是一個開源並實現將 Python 和.NET Framework 緊密的結合在一起，IronPython 可以輕易地使用 .NET Framwork 與 Python 函式庫"。使用起來也很簡單，它就是一個 MSI 檔案，你可以安裝後呼叫 ipy.exe (我稍後會做示範)。

根據下方的範例程式碼，我總算能用 Python 去解壓縮我們先前的壓縮內容了 :

```
#import required .Net libraries 

from System.IO import BinaryReader, StreamReader, MemoryStream
from System.IO.Compression import CompressionMode, DeflateStream
from System import Array, Byte
from System.IO import FileStream, FileMode
from System.Text import Encoding
from System.IO import File

#functions to decompress the data 
def decompress(data):
    io_zip = DeflateStream(MemoryStream(data), CompressionMode.Decompress)
    str = StreamReader(io_zip).ReadToEnd()
    io_zip.Close()
    return str

print "Decompressing stream..."
compressedBytes = File.ReadAllBytes("decoded2.zip")
decompressedString = decompress(compressedBytes)

f = open("decompressed.txt", "wb")
f.write(decompressedString)
f.close()
```

用 IronPython 執行這個十分簡單， ipy.exe io_decompress.py:
![](https://1.bp.blogspot.com/-TQoJoIR_GlQ/WePjZlEgP_I/AAAAAAAAEAA/BKkG8z7sASAW-LGX4couXdSq2WeQUHoTACLcBGAs/s640/iron_python.PNG)

我現在可以打開 decompressed.txt 也就是我們剛剛解壓縮出來的內容，裡面是純 PowerShell 腳本，這邊我們又可以看到一組 IP:
![](https://1.bp.blogspot.com/-RVBFU8wPE_k/WeOxrCFKZ2I/AAAAAAAAD_w/4Tx9x2DvoPMbOFlMyrA9t8BvKrryhDd7QCLcBGAs/s640/decompressed_text.png)

整理一下我們在這個範例做了哪些步驟 : 
* 解碼 Unicode Base64
* 解碼嵌入在裡面的 Base64
* 解壓縮解碼過後的 Base64的內容

正如我們看到的這三個例子，黑客可能會用許多技術來混淆他們的 PowerShell 內容。
他們有許多的組合技，我們上面已經展示了一些。
所採取的步驟會因案例而變化，我常看到一個案例中會有 2-3 種不同的變化，數個月內可能有上百個系統都有不同的變化。有時候步驟可能是: base64, base64,decompress, shellcode 又或著是 base64, decompress, base64, code, base64, shellcode。


![](https://3.bp.blogspot.com/-uax5xoPOVw4/WeOlX2CeR7I/AAAAAAAAD-4/F-DMtK9DKSwfbkg_cZbHvcM20zVGr3bHQCEwYBhgL/s200/russion_stacking_dolls.png) 是不是很像俄羅斯娃娃呢? 

當我在撰寫這系列的時候我也會講如何自動化這些過程。 如果你有用 Harlan Carvy的 Timeline 工具去獲得文字輸出，這些事情會變得更加簡單。

那麼在實際案例中如何找到這些內容並解碼呢?
* 找看看系統事件 ID 為 7045 內容包括 "%COMSPEC%, powershell.exe, -encodedcommand, -w hidden , "From Base64String" 這類訊息的內容
* 尋找 "Gzipstream" or "[IO.Compression.CompressionMode]::Decompress" 作為線索讓你知道該採取甚麼動作
* 試著利用 scdbg.exe 執行得到的結果或是用 shellcode2exe 或是其他的惡意程式分析工具

下一篇 Part2 會介紹如何在註冊表中找到 PowerShell，接下來 Part3 會介紹 PowerShell 記錄檔與從記憶體中提取相關資訊。


