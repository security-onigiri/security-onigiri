---
title: 你不算個資安專家，如果你只是...
layout: post
author: jhe
source-url: https://www.linkedin.com/pulse/well-you-security-specialist-alex-yang
---

# Well, you are not a "Security Specialist" if you ...

Starting this thread is easy ...

I spotted many of people nowadays claimed that they are an "InfoSec Specialist" on their resume, Linkedin profile, etc. This will eventually makes life a bit more difficult for the HR personnel or inexperience hiring managers that are genuinely looking for a real-deal InfoSec Specialist to fill certain specifi job roles.

>用講的很簡單 ...
>
>我發現現在很多人在他們的履歷、Linkedin 專頁等等，宣稱自己是"資安專家"。這只是在為難想找真正的專家來填補工作空缺的那些 HR 或人事經理人們而已。

So, here are things that separate them from the real specialists and experts out there. See if you may be considered into one of them (inadvertently or deliberately):

>所以，這裡是一些可以用來區分他們是否為真正的專家，或是熟捻相關事務的從業人員，或許你會想考慮其中一個職業（不小心或蓄意的）。

* You are not a Pentesting/Ethical Hacking Specialist if your day to day job just utilzing some tools to look for vulnerability such as Qualys, Nessus, OpenVAS, Nikto, Acunetix, and alike. We called these tools: Automated Vulnerability Scanners and using one of them does not makes you a Hacker or Pentester Specialist. To makes you a real Pentester, you need to be able to break into the systems manually and be able to gain root/administrator privileges on that system you are breaking (in which pratically allowed you to do anything you wanted with that compromised system). Alternatively you should be able to demonstrate the capability to ex-filtrate any sensitive information out from its protected repositories even if you only given a standard user privilege access to that system.

>你不算是一個專業**滲透測試/道德駭客**，如果你每天的工作內容都是，使用類似 Qualys、Nessus、OpenVAS、Nikto、Acunetix 之類的工具尋找弱點。我們稱這些工具為：自動化弱點掃描器，使用其中一個工具並不會讓你變成駭客或是滲透測試專家。想當一個真正的滲透測試者，你需要要能手動侵入一個系統並且獲得該系統的管理員權限（表示在那被攻陷的系統上你可以為所欲為）。或是你應該能展示出從一個被保護的存放處洩漏出敏感資訊的能力，甚至你只有被給予一個該系統上一般的使用者權限。

* You are not a Malware Reverse Engineering Specialist if what you are doing simply googling the executable filenames or its MD5 hashes and look it up at VirusTotal or take that executables and run it into the Automated Malware Sandbox Analyzer such as Cuckoo, VT, Malwr, GFI, etc. to be called a real Malware Revese Engineering Specialist, you should be able to perform surgical of the malicious binary files using Hex Editor, Debugger and Disassembler and MOST IMPORTANTLY to be able to decode, de-obfuscate and probaly decrypt the codes and login behind the binary file and locate in which part of the code's sub-routine that is/are doing evil as to validate if the binary is truly malicious.

>你不算是一個專業**惡意程式逆向工程師**，如果你只是簡單的 google 執行檔的名稱或是他的 MD5 雜湊並在 VirusTotal 搜尋它，或是丟到 Cuckoo、VT、Malwr、GFI 等等的自動化惡意程式沙盒分析工具。要想成為一個真正的惡意程式逆向工程專家，你應該要能使用*十六進位編輯器*、*除錯器*、*反組譯器*剖析惡意程式二進位檔案，還有**最重要的是**可以解碼、解混淆並正確的解密程式碼，並且定位到執行惡意行為的程式區段，如果它是真的惡意程式的話。

* You are not a Cyber Threat Intelligent Specialist if what you do is just to read and forward InfoSec news to your bosses/IT Team without having a proper method on how to dissect, filter and process that information into a valuable intelligence that are useful for your organization in term of how to provide early detection, prevent and deter the cyber attack or casualties from arising or happening to your ogranization.

>你不算是一個**網路威脅情資專家**，如果你只是純粹讀一讀資安新聞，或是轉發資安新聞給你老闆/IT 團隊。在危害發生前，你需要提供一個適切的方法來處理該資訊成為對你的組織有價值的情資，以達到早先偵測、避免與阻斷網路攻擊的目的。

* You are not a Network Attack/DDoS Mitigator Specialist if what you do is merely to have your inbound internet link traffics routed behind a DDoS Scrubbing Provider (like Prolexic/Akamai, Verisign, Incapsula, etc) and you were involved to any DDoS attack events just because you were being called /paged-out by oyur DDoS cloud provider to joined their bridgeline and listening to what they are doing over the phone. To be called a specialist in this field, you need to know how exactly the Network/DDoS attacks coming to your network: the attack vectors, methods, protocols being abused, types of attacks, what is the mitigation control you have in-premise and on-the-cloud, when and what mitigations to activate, etc. You need to be proficient in reading and understand the underlying of packet captures and you also need to know how to build and enhance your defense posture to adapt with the ever increasing attack methods being launch and seen to-date.

>你不算是一個**網路攻擊/分散式阻絕緩解專家**，如果你只是修改路由將網際網路的輸入流量轉接到 DDoS 流量清洗商(例:Prolexic/Akamai, Verisign, Incapsula…)或只從鍵盤參與或是與你的 DDoS 流量清洗商用電話溝通加入他們的實況轉播。
這方面的專業人士必須真正了解網路與 DDoS 攻擊 是如何進入你的網路，例如: 清楚攻擊向量、方式、使用的通訊協定、攻擊類型，地端與雲端可用的緩解方案，緩解方案的啟動時機。
舉例來說，你必須熟悉如何獲取封包並且能夠閱讀內容，同時你必須能夠建立並加強自己的防禦機制去解決與日俱增的攻擊方式和現今正在發生的攻擊。

* You are not Security Event Management Specialist if what you do is just to received event alerts from your IDSes or Log alerting/correclation tools (such as Splunk, ArcSight ESM, etc) and escalate this alerts to your security vendor whom job function is simply doing Level-1 of event forwarding blindly to the proper team. In order to makes you a real Security Event Management Specialist, you need to be able to do some basic analysis of the events and to determine which ones are real events and which ones are false positive. You also needs to have capability to filter out and reduced any false positives by tuning the SIEM system you have access to.

>你不算是一個**資安事件管理專家**，如果你只是從你的入侵偵測系統(IDS)收警告或日誌告警/關聯工具 (諸如：Splunk、ArcSight ESM 等)並將告警呈報給你的資安供應商，這種初級且簡單到可以矇眼轉送的工作。為了成為一個正港的資安事件管理職人，你需要能實作初步的分析判斷哪些是誤報，哪些是真正的告警。你也需要會調校你的 SIEM 系統以達到過濾及減少誤報。

* You are not Security Intrusion Analyst/Specialist if you are simply doing the above job roles of Security Event Management Specialist. To makes you a real deal Seucrity Intrusion Analyst/Specialist, you need to be able to read inside packet capture and tell us on the spot of what is it raelly happening on any particular events. You also will need to be able to perform a holistic analysis even in the case where full packet capture is not available and you need to rely on other means likes system/proxy/firewall/network logs etc.

>你不能算是正港的**資安入侵分析師/專家**，如果你只是做一些上面提到資安事件管理專家做的事情。要想當個真真正正的資安入侵分析師/專家，你需要有透過封包分析並告訴我們目前到底發生了什麼事情。同時也要在封包收錄不足的情況下，佐以系統/代理伺服器/防火牆/網路日誌等等，做到一個完整的解析說明。

* You are not a Computer Forensic Specialist if what you konw is just to check the system logs from any error message and to run anti-virus software to find out whether or not the system is infected by viruses. To be called a Computer Forensics Specialist, you need to be able to perform proper data acquisition of the evidence from HDD or any other storage, to preserve it well and ensure it is adminssible to the court during trials, to be able to dig deeper down to the file system level of different OSes to find out artifacts of events being investigate, detecting and recovering deleted files from slack spaces and even to recover evidence from volume shadow copies, registry entries, prefetch data, etc. You also need to be proficient with handling volatile memory, know how to acquire them as well as to find malicious code could possibly hiding into other legitimate process(es) via process hollowing, etc.

>你不能算是一個**計算機鑑識專家**，如果你只是看看系統日誌的錯誤訊息，並運行防毒軟體來確認是否有感染跡象。要想當個 real 的計算機鑑識專家，你要會從 HDD 或其他存儲裝置獲取恰當的跡證資料，並將之保存得當並確定這是可以在審訊中做為依據的。要能深入不同作業系統上的檔案系統層級，去找尋正在調查的人為事件、偵測並從殘餘空間復原被刪除的檔案，甚至從 volume shadow 拷貝、註冊表、prefetch file 等等來復原證據，你也需要專業到可以處理揮發性記憶體，知道如何從中取得可能存在合法形成中的惡意程式碼。

Hope this article could provide some insight to any HR practitioner specializing in InfoSec recruitment or to any hiring managers that are truly looking for a better (if not one of the best) InfoSec Specilists out there to perform a real challenging jobs that required their true expertise of their respective fields.

>希望這個文章可以讓與資安相關的 HR 從業人員或人事經理多了解一點，在資安相關工作雇用上可以找到好一點的(如果不是要最好的)資安專家，來實踐一些真正需要他們專業及屌炸天的技能來應付的挑戰。