---
title: Linux ELF 二進位檔案入門：搞懂兼分析
layout: post
author: jhe
source-url: https://linux-audit.com/elf-binaries-on-linux-understanding-and-analysis/
tags: Linux ELF
---

# The 101 of ELF Binaries on Linux: Understanding and Analysis

## Executable and Linkable Format 可執行檔與可連結格式

An extensive dive into ELF files: for security incident response, development, and better understanding

>廣泛的深入 ELF 檔案: 為了資安事件響應、程式開發與更好的理解

We often don't realize the craftsmanship of others, as we conceive them as normal. One of these things is the usage of common tools, like *ps* and *ls*.Even though the commands might be perceived as simple, under the hood there is more to it: ELF binaries. Let's have an introduction into the world of this common file format for Linux and UNIX-based systems.

>我們通常不理解其他的技術，把他們想的跟喝水一樣普通。其一便是一般工具的使用方法，像是 *ps* 與 *ls*。甚至該指令可能是被認為簡單的，其實還有更多隱藏在 ELF 二進位格式中。讓我們向世界介紹這個在 Linux 與 基於 UNIX 系統上普遍可見的檔案格式。

**Why learn the details of ELF ? 為什麼要了解 ELF 的細節?**

Before diving into more technical details, it might be good to explain why understanding of the ELF format is useful. As a starter, it helps to learn the inner workings of our operating system. When somehing goes wrong, we might better understand what happened (or why). Then there is the value in being able to research ELF files, e.g. after a security breach (incident response, malware research, forencis). Last but not least, for a better understanding while developing. Even if you program in a high-level language like Golang, you still might benefit from knowing what happens behind the scenes.

>在更深入到技術細節之前，最好先解釋一下為什麼了解 ELF 格式是有用的，當作開頭，可以幫助學習我們作業系統裡面的運作原理。當某些東西出錯了，我們或許較能知道發生了什麼事情(或是為什麼)。這就是研究 ELF 檔案的價值所在，例如在一波資安攻擊之後(事件響應，惡意軟體研究，鑑識)。最後而同樣重要的是，能在開發時有更好的理解力。甚至當你在使用高級語言如 Golang，你仍可能受益於知曉該場景背後發生了些什麼事情。

**From source to process 從原始碼到行程**

So whatever operating system we run, it needs to translate common functions to the language of the CPU, also known as machine code. A function could be something basic like opening a file on disk or showing something on the screen. Instead of talking directly to the CPU, we use a programming language, using internal functions. A compiler then translates these functions into object code. This object code is then linked into a full program, by using a linked tool. The result is a binary file, which then can be executed on that specific platform and CPU type.

>所以無論我們運行任何作業系統，它需要將一般功能翻譯成 CPU 的語言，也被稱為機器語言。一個函式可被拆分成基本的指令像是在硬碟上開啟一個檔案或是顯示一些東西在螢幕上。儘管可以直接對 CPU 下達指令，我們使用一種程式語言，使用內部的函式。然後使用編譯器翻譯這些函式成為目的碼(編按: object code)。藉由使用連結工具這個物件碼將被連結成一個完整的程式。結果是一個可以執行在特定平台與 CPU 架構下的二進制檔案。

**Before you start 在開始之前**

This blog post will share a lot of commands. Don't run them on production systems. Better do it on a test machine. If you like to test commands, copy an existing binary and use that. Additionally, we have provided a small C program, which can you compile. After all, trying out is the best way to learn and compare results. 

>這個部落格文章將分享一堆指令。請勿在正式環境執行。最好是在測試環境上。如果你喜歡測試指令，複製一個已存在的二進制檔並使用他們。此外，我們提共了一個小型的 C 語言程式，你可以自行嘗試編譯。總之，嘗試是最好的學習方式與比對結果。

## Not Just Executables 並非只是可執行檔

A common misconception is that ELF files are just for executables. We already have seen they can be used for partial pieces (object code). Another example includes shared libraries, and even core dumps (those core or a.out files). ELF is also used for the kernel and kernel moduels on Linux machines.

>一種常見的誤解是 ELF 檔案只會是可執行檔。我們已經看到他們可以被用來部份利用(object code). 另外一個例子包含 shared libries，而甚至 core dump (core 或 a.out 檔)。在 Linux 機器上 ELF 也被用在核心與核心模組。

## Structure 結構

Due to the extensible design of ELF files, the structure differs per file. An ELF file consists of:

>因為可擴充設計的緣故，每個檔案的結構不同。一個 ELF 檔案的組成有：

1. ELF header (ELF 標頭)
2. File data (檔案資料)

With the *readelf* command we can look at the structure of a file and it will look something like this:

>可以使用 *readelf* 指令我們可以看到檔案的結構可以看到如下的畫面：

#### ELF header / ELF 標頭

As can be seen in this screenshot, the ELF header starts with some magic. While this might look fuzzy at first, it is a partial representation of the header data itself. The first 4 hexdecimal pieces define that this is an ELF file (45=E,4c=L,46=F), prefixed with the 7f value.

>可由截圖看到，ELF 標頭從一些 magic 開始。或許一開始看起來會有點混論，那是一個表示標頭資料的部份。頭四個 16 進制部份定義了這是一個 ELF 檔(45=E,4c=L,46=F)，並由 7f 做為前置標記。

This ELF header is mandatory and ensures that data is correctly interpreted during linking or execution. To better understand the inner working of an ELF file, it is useful to know the file used. It is actually easier than it looks.

>這個 ELF 標頭是強制的並且可以確保資料正確的在連結或是執行階段被直譯。為了更好的了解 ELF 內部運作，了解使用到的檔案是有幫助的，實際上那比看上去的簡單。

#### Class / 類別

After the ELF type declaration, there is a Class field defined. This value determines if the file is meant for a 32 (=1) or 64 (=2) bit architecture. The magic shows a 2, which is displayed by the readelf command as an ELF64 file. In other words, an ELF file using 64 bit architecture. Not surprising, as this particular machine contains a modern CPU.

>在 ELF 類型宣告之後，有定義一個類別的欄位。這個值決定這個檔案是 32 或是 64 位元架構。magic 顯示一個 2，被 readelf 指令顯示為 ELF64 的檔案。換句話說，一個 ELF 檔案使用 64 位元架構。不意外的，這個特定機器包含一個現代 CPU。

#### Data 資料

Next there is a data field. It knows two options: 01 for LSB (Least Significant Bit), also known as little-endian. The there is the value 02, for MSB (Most Significant Bit, big-endian). This particular value helps to interpret the remaining objects correctly within the file. This is important, as different types of processors deal differently with the incoming instructions and data structures. In this case LSB is used, which is common for AMD64 type processors.

>接下來有一個資料欄位。它有兩個選項： 01 表示 LSB(Least Significant Bit)，也被稱為 little-endian。這個特定值幫助正確的直譯在檔案中剩下的物件。這是非常重要的，不同的處理器使用不同的方式處理接收到的指令與資料結構。這個案例使用 LSB，是普遍 AMD64 處理器的型態。

The effect of LSB becomes visible when using hexdump on a binary file like /bin/ps.

>當對一個二進位檔如 /bin/ps 使用 hexdump 則效果是顯而易見的。

```
$ hexdump -n 16 /bin/ps
```

We can see that the value pairs are different, which is caused by the right interpretation of the byte order.

>我們可以看到一對值是不同的，因為是由右開始解釋的位元組順序。

#### Version 版本

Next in line is another "01" in the magic, which is the version number. Currently, there is only 1 version type: currently, which is the value "01". So nothing interesting to remember.

>下一個要講的是在 magic 裡面的另外一個 "01"，表示的是版本號。目前只有一種版本類型: 就是 "01" 這個值。所以沒啥有趣的東東好記的。

### OS/ABI and ABI version 作業系統/應用二進為介面與應用二進為介面版本

Each operating system has a big overlap in common functions. In addition, each of them has specific ones, or at least minor differences between them. To ensure the right functions are used, an application binary interface (ABI), is defined. This way the operating system and applications both know what to expect and functions are correctly forwarded. These two fields describe what ABI is used and the related version. For Linux systems this is the SystemV.

>每個作業系統在常見的函式上常有重疊。另外，他們每一個都有一個特例，或是之間存在微小的差異。為了確保使用正確的函式，才定義了一個應用二進位介面 (ABI)。如此一來作業系統與應用程式便可以預期甚麼樣的事情及功能會被傳遞過來。這兩個欄位描述了 ABI 被使用及其相關的版本。對 Linux 系統來說就是 SystemV。

### Machine 機器

In the header we can also find the expected machine type(AMD64)

>在標頭我們也可以找到預期的機器類型 (AMD64)

#### Type 型態

The **type** field tells us what the purpose of the file is.

>類型欄位這個檔案的用途為何

Usually it is:

>它通常是:

* DYN(Shared object file), for libraries
* EXEC (Executable file), for binaries
* REL(Relocatable file), before linked into an executable file

* DYN (共享物件檔)，函式庫
* EXEC (可執行檔)，二進位檔案
* REL (可重定位檔)，連結進一個執行檔前的檔案

#### Machine / 機器

While some of the fields could already be displayed via the magic value of the readelf output, there is more. For example for waht specific processor type the file is. Using hexdump we can see the real values.

>某些欄位可以透過 readelf 輸出顯示其魔術值，但其實還有更多。舉例來說: 該檔案的指定處理器類型是哪一個。使用 hexdump 我們可以看到真實的資料。

>>7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00 |.ELF............|
02 00 **3e** 00 01 00 00 00 a8 2b 40 00 00 00 00 00 |..>......+@.....|
40 00 00 00 00 00 00 00 30 65 01 00 00 00 00 00 |@.......0e......|
00 00 00 00 40 00 38 00 09 00 40 00 1c 00 1b 00 |....@.8...@.....|

*(Output created with hexdump -C -n 64 /bin/ps)*
*(透過 hexdump -C -n 64 /bin/ps 製造的輸出)*

The highlighted field above is what defines the machine type. The value 3e is 62 in decimal, which equals to AMD64. To get an idea of all machine types, have a look at this *ELF header file*.

>上面粗體的欄位就是定義了機器類型。3e 就是十進位的 62，表示的是 AMD64。若想知道更多機器類型，瞧一瞧這個吧[ELF header file](http://www.opensource.apple.com/source/dtrace/dtrace-90/sys/elf.h)。

With all these fields clarified, it is time to look at where the real magic happens and move into the next headers!

>透過這幾個欄位的闡述，該是時候看看真正魔法並進到後面的標頭了!

#### File data / 檔案資料

Besides the ELF header, ELF files consist of:

>除了 ELF 標頭之外，ELF 檔案的組成為:

- Program Headers or Segments(9) (程式標頭 或 區段)
- Section Headers or Sections(28) (節區標頭 或 節區)
- Data (資料)

Before we dive into these headers, it is good to know that ELF has two complementary "views". One for used for the linker to allow execution (segments), one for categorizing instructins and data (sections). So depending on the goal, the related header types are used. Let's start with program headers, which we find on ELF binaries.

>在我們深入這些標頭之前，了解到 ELF 有兩個互補的"視圖"是再好不過了。一個是為了可以讓連結器執行 (區段)，一個用來分類指令(編按: 原文typo，應為 instruction)與資料 (節區)，基於這個目標，相關的標頭類型將被使用到。讓我們從 ELF 二進位檔中找到的程式標頭們開始吧。

### Program headers / 程式標頭

An ELF file consists of zero or more segments, and describe how to create a process/memory image for runtime execution. When the kernel sees these segments, it uses them to map them into virtual address space, using the mmap(2) system call. In other words, it converts predefined instructions into a memory image. If your ELF file is a normal binary, it requires these program headrs, otherwise it won't run. And it uses these headers, with the underlying data structure, to form a process. This process is similar for shared libraries.

>一個 ELF 檔案由零個或更多區段組成，並且描述如何創造一個執行時期的行程/記憶體映像。當核心看到這些區段，它使用系統呼叫 mmap(2) 將他們映射到虛擬位址空間，換句話來說，它轉換預先定義的指令到記憶體映像中。如果你的 ELF 檔案是一個普通的二進位檔，它將需求這些程式標頭，否則無法運行。並且它使用這些標頭，與底層資料結構來形成一個程序。這個程序與共享函式庫類似。


![](https://assets.linux-audit.com/wp-content/uploads/2015/08/elf-program-headers-segments.png)

An overview of program heders in an ELF binary

>一個 ELF 二進位檔中的程式標頭概觀

We see in this example that there are 9 program headers. When looking at it for the first time, it hard to understand what happens here. So let's go into a few details.

>我們看到這個範例有 9 個程式標頭。當第一次看到的時候，它(編按: 原文應該少了 is)讓人難以理解這在搞啥。所以讓我進入到一點細節部分。

**GNU_EH_FRAME**

This is a sorted queue, used by the GNU C (gcc), to store exeception handlers. So when something goes wrong, it can use this part to deal correctly with it.

>被 GNU C (gcc) 所使用的是一個排序過的佇列，來存放意外處理器。所以當某東西出錯了，它可以使用這個部分來處理修正錯誤。

**GNU_STACK**

This header is used to sotre stack information. The stack is a buffer, or scratch place, where items are stored, like local variables. This will occur with LIFO(Last In, First Out), similar to putting boxes on top of each other. When a process function is started a block is reserved. When the funtion is finished, it will be marked as free again. Now the interesting part is that a stack shouldn't be executable, as this might introduce security vulnerabilities. By manipulation of memory, one could refer to this executable stack and run intended instructions.

>這個標頭被用來存放堆疊資訊。堆疊是一個緩衝區，或是一個存放龐雜物品的地方，像是區域變數。這裡的運作是 LIFO(後進先出)，類似於把一個盒子放置於其他盒子之上。當一個程序函式開始執行，就會有一個區塊被保留。當函式結束該區塊將再次被標記為自由。如今有趣的部分是，堆疊不該為可執行，當作是介紹安全弱點。透過操作記憶體，其他地方可能參考到這個可執行的堆疊並故意運行一些指令。

If the GNU_STACK segment is not available, then usasally an executable stack is used. The scanelf and execstack tools are two examples to show the stack details.

>如果 GNU_STACK 區段並非可用的，則通常可執行的堆疊會被使用。 `scanelf` 與 `execstack` 是兩個可以呈現堆疊詳細資訊的工具。

```shell
# scanelf -e /bin/ps
 TYPE   STK/REL/PTL FILE 
ET_EXEC RW- R-- RW- /bin/ps

# execstack -q /bin/ps
- /bin/ps
```

*Commands to see program headers*

>*可以看程式標頭的指令*

- dumpelf (pax-utils)
- elfls -S /bin/ps
- eu-readelf -program-headers /bin/ps

### Sections / 節區

#### Section headers / 節區標頭

The section headres define all the sections in the file. As said, this "view" is used for linking and relocation.

>節區標頭定義了在檔案中的所有節區。就像前面提到的，這個"視圖"視被用來連結與重定位的。

Sections can be found in an ELF binary after the GNU C compiler transformed C code into assembly, followed by the GNU assembler, which creates objects of it.

>節區可以在 GNU C 編譯器將 C 程式碼轉換成組合語言且被後面的 GNU 組譯器，在 ELF 二進位檔中發現，

As the image above shows, a segment can have 0 or more sections. For executable files there are four main sections: **.text**, **.data**, **.rodata**, and **.bss**. Each of these sections are loaded with different access rights, which can be seen with **readelf -S**.

>如上面的圖所示，一個區段可以擁有 0 或更多個節區。以可執行檔來說有主要四個節區: **.text**、**.data**、**.rodata**與 **.bss**。這每一個節區都被載入且擁有不同的存取權限，可以用 **readelf -S** 來查看。

#### .text / 程式碼區段

Contains executable code. It will be packed into a segment with read and execute access rights. It is only loaded once, as the contents will not change. This can be seen with the **objdump** utility.

>包含可執行程式碼。程式碼將被包裝到一個區段中，有可讀可執行的權限並且它只會被載入一次，因為程式碼內容不會改變。可以使用 **objdump** 工具查看。

>>12 **.text** 0000a3e9 0000000000402120 0000000000402120 00002120 2**4  
CONTENTS, ALLOC, LOAD, **READONLY**, **CODE**

#### .data / 資料區段

Initialized data, with read/write access rights.

初始化後的資料，有可讀可寫的權限。

#### .rodata / 唯讀資料區段

Initialized data, with read access rights only (=A).

初始化後的資料，只有可讀的權限。

#### .bss / 位初始化資料區段

Uninitialized data, with read/write access rights (=WA)

未初始化的資料，有可讀可寫的權限

>>\[24\] .data PROGBITS 00000000006172e0 000172e0  
0000000000000100 0000000000000000 **WA** 0 0 8  
\[25\] .bss NOBITS 00000000006173e0 000173e0  
0000000000021110 0000000000000000 **WA** 0 0 32

*Commands to see section and headers*

>*用來看節區與標頭的指令*

 - dumpelf
 - elfls -p /bin/ps
 - eu-readelf -section-headers /bin/ps
 - rreadelf -S /bin/ps
 - objudmp -h /bin/ps

#### Section groups / 節區群組

Some sections can be grouped, as they form a whole, or in other words be a dependency. Newer linkers support this functionality. Still this is not common to find that often:

>某一些節區可以被群組起來成為一個整體，換句話說成為從屬關係，新一點的連結器才有支援這個功能。這仍然不是這麼常見:

>>\# readelf -g /bin/ps
>>
>>There are no section groups in this file.

While this might not be looking very interesting, it shows a clear benefit of reasearching the ELF toolkits which are available, for analysis. For this reason, an overview of tools and their primary goal have been included at the end of this article.

>這看起或許並不有趣，可用的 ELF 工具組在研究與分析方面有顯著的益處，基於這個原因，一些工具與他們主要的用途概述將會在文末附上。

### Static VS Dynamic / 靜態 VS 動態

Another thing to mention before closing an introduction on the subject of ELF is static and dynamic binaries. For optimization purposes we often see that binaries are "dynamic", which means it needs external components to run correctly. Often these external components are normal libraries, which contain common functions, like opening files or createing a network socket. Static binaries on the other hand have all libraries included, which make them bigger, yet more portable (e.g. using them on another system).

>另外一個在結束介紹 ELF 是靜態和動態二進位的主題前要提及的，為了最佳化的目的，我們通常將二進位檔視為"動態"，代表的是它需要額外的部件來正確運行。

If you want to check if a file is statically or dynamically compiled, use the file command. If it shows something like:

>如果你要確認一個檔案是否為動態或是靜態編譯的，使用 `file` 命令。如果它顯示如:

>>$ file /bin/ps  
/bin/ps: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), **dynamically linked (uses shared libs)**, for GNU/Linux 2.6.24, BuildID\[sha1\]=2053194ca4ee8754c695f5a7a7cff2fb8fdd297e, stripped

To determine what external libraries are being used, simply use the ldd on the same binary:

>要確認額外函式庫有那些被使用到，簡單的使用 `ldd` 在同一個二進位檔上:

>>$ ldd /bin/ps  
linux-vdso.so.1 => (0x00007ffe5ef0d000)  
libprocps.so.3 => /lib/x86_64-linux-gnu/libprocps.so.3 (0x00007f8959711000)  
libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f895934c000)  
/lib64/ld-linux-x86-64.so.2 (0x00007f8959935000)

**Tip:** To see underlying dependencie, it might be better to use the lddtree utility instead.

>**小技巧:** 要看到底層依賴關係，使用 lddtree 工具來代替。

## What Did We Learn ? / 我們學到了什麼 ?

ELF files are for execution, or for linking. Depending on one of these goals, it contains the required segemnts or sections. Segments are viewed by the kernel and mapped into memory (using mmap). Sections are viewed by the linker to create executable code or shared objects.

>ELF 檔案是用來執行或是連結的。基於其中一個目標，而包含要求的區段或是節區。區段是核心的觀點並映射到記憶體中(使用 mmap)。節區是連結器的觀點用來創造可執行程式碼或是分享物件。

The ELF file type is very flexible and provides support for multiple CPU types, machine architectures, and operating systems. It is also very extensible: each file is differently constructed, depending on the required parts.

>ELF 檔案類型是非常彈性且提供許多支援的 CPU 類型、機器架構與作業系統。同時它具有可擴展性: 基於不同的要求，每個檔案有不同的構造。

Headers form an important part of the file, describing exactly the contents of and ELF file. By using the right tools, you can gain a basic understanding on the purpose of the file. From there on, you can further "interrogate" the binaries by determining the related functions it uses, or strings stored in the file. A great start for those who are into malware research, or want to know better how processes behave (or not behave!).

>標頭形成一個檔案重要的部分，精確的描述 ELF 檔案的內容。透過使用對的工具你可以獲得對檔案的目的有一個基本的了解。從現在開始，你可以進一步的"質問"二進位檔取決於，它使用的相關函式或是儲存在檔案你的字串。對於惡意軟體研究有興趣的人是一個好的開始，或是想要對程序行為有更好的了解 (或是程序不乖!)。(編按: behave 有乖巧的意味，這裡作者玩了個雙關)

### Packages / 套裝軟體

Most Linux systems will already have the the binutils package installed. Other packages might help with showing much more details. Having the right toolkit might simplify your work, especially when doing analysis or learning more about ELF files. So we have collected a list of packages and the related utilities in it.

>多數的 Linux 系統將已經安裝了 `binutils` 套裝軟體(編按: 原文多打一個 the)。其他套裝軟體對顯示更多詳細資訊可能會有幫助，擁有隊的工具箱可以簡化你做的工。特別是在分析或是學習更多有關 ELF 檔案的時候。所以我們蒐集了一個套裝軟體清單與其相關的工具。

#### elfutils

- /usr/bin/eu-addr2line
- /usr/bin/eu-ar – alternative to ar, to create, manipulate archive files
- /usr/bin/eu-elfcmp
- /usr/bin/eu-elflint – compliance check against gABI and psABI specifications
- /usr/bin/eu-findtextrel – find text relocations
- /usr/bin/eu-ld – combining object and archive files
- /usr/bin/eu-make-debug-archive
- /usr/bin/eu-nm – display symbols from object/executable files
- /usr/bin/eu-objdump – show information of object files
- /usr/bin/eu-ranlib – create index for archives for performance
- /usr/bin/eu-readelf – human-readable display of ELF files
- /usr/bin/eu-size – display size of each section (text, data, bss, etc)
- /usr/bin/eu-stack – show the stack of a running process, or coredump
- /usr/bin/eu-strings – display textual strings (similar to strings utility)
- /usr/bin/eu-strip – strip ELF file from symbol tables
- /usr/bin/eu-unstrip – add symbols and debug information to stripped binary

*Notes: the elfutils package is a great start, as it contains most utilities to perform analysis.*

*註: elfutils 包是一個好的開始，因為它包含了最多用來執行分析的功能*

#### elfkickers

- /usr/bin/ebfc – compiler for [Brainfuck](https://en.wikipedia.org/wiki/Brainfuck) programming language
- /usr/bin/elfls – shows program headers and section headers with flags
- /usr/bin/elftoc – converts a binary into a C program
- /usr/bin/infect – tool to inject a dropper, which creates setuid file in /tmp
- /usr/bin/objres – creates an object from ordinary or binary data
- /usr/bin/rebind – changes bindings/visibility of symbols in ELF file
- /usr/bin/sstrip – strips unneeded components from ELF file

*Notes: the author of the ELFKickers package focuses on mainipulation of ELF files, which might be great to learn more when you find malformed ELF binaries.*

*註: ELFKickers 的作者專注在操作 ELF 檔岸上，或許對想要學習畸形 ELF 二進位檔有幫助*

#### pax-utils
- /usr/bin/dumpelf – dump internal ELF structure
- /usr/bin/lddtree – like ldd, with levels to show dependencies
- /usr/bin/pspax – list ELF/PaX information about running processes
- /usr/bin/scanelf – wide range of information, including PaX details
- /usr/bin/scanmacho – shows details for Mach-O binaries (Mac OS X)
- /usr/bin/symtree – displays a leveled output for symbols

*Notes: Several of the utilities in this package can scan recursively in a whole directory. Ideal for mass-analysis of a directory. The forcus of the tools is to gather PaX details. Besides ELF support, some details regarding Mach-O binaries can be extracted as well.*

*註: 在這個套裝軟體中數個功能可以遞迴的掃描一整個目錄。用於對一個目錄的大量分析。這個工具聚焦的點在於集合 PaX 細節。除了 ELF 的支援，一些關於 Mach-O 二進位的細節也可以被萃取。*

Example outputs

>範例輸出

```
scanelf -a /bin/ps
 TYPE    PAX   PERM ENDIAN STK/REL/PTL TEXTREL RPATH BIND FILE 
ET_EXEC PeMRxS 0755 LE RW- R-- RW-    -      -   LAZY /bin/ps
```

#### prelink

- /usr/bin/execstack – display or change if stack is executable
- /usr/bin/prelink – remaps/relocates calls in ELF files, to speed up process

## Example / 範例

If you want to create a binary yourself, simply create a small C program, and compile it. Here is an example, which opens /tmp/test.txt, reads the contents into a buffer and displays it. Make usre to create the related /tmp/test.txt file.

>如果你想要自己創造一個二進位檔，簡單的創建一個小型的 C 程式，並編譯它。這裡是一個範例，可以打開 /tmp/test.txt，將內容讀進一個緩衝區並顯示。記得要確認創建 /tmp/test.txt 檔案。

```clike
#include <stdio.h>

int main(int argc, char **argv)
{
   FILE *fp;
   char buff\[255\];

   fp = fopen("/tmp/test.txt", "r");
   fgets(buff, 255, fp);
   printf("%s\\n", buff);
   fclose(fp);

   return 0;
}
```

This program can be compiled with: gcc -o test test.c

>這個程式用 `gcc -o test test.c` 來編譯

## More sources / 更多資料來源

If you like to know more, a good source would be to follow WikiPedias Executable and Linkable Format(ELF) page. Another good in-depth document: ELF_Format and the document authored by Brian Raiter (ELFkikers). For those who love to read sources, have a look at documented ELF structure header file from Apple. And them finally, if you really wnat to know how a binary works, test it with a disassembler tool like Hopper for Linux.

>如果你傾向於知道更多，一個好的來源包括維基百科 [Executable and Linkable Format (ELF)](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format)頁面。另外一個詳盡的文件:作者與 ELFkickers 相同的著作 [ELF Format](http://www.skyfree.org/linux/references/ELF_Format.pdf)。對那些愛上閱讀原始資料，看一看這個從 Apple 的文件 [ELF structure header file](http://www.opensource.apple.com/source/dtrace/dtrace-90/sys/elf.h)。最後，如果你真的想要知道一個二進位檔案是如何運作的，使用像是 [Hopper for Linux](https://www.hopperapp.com/) 的反組譯工具來做測試。