---
layout: post
title: Concurrency vs parallelism
author: bananaapple
tags:
  - review
categories:
  - computer science
date: 2017-02-01 19:48:00
---
主要記錄一下兩者的差別

有興趣的話可以看一下這個 [talk](https://talks.golang.org/2012/waza.slide#1)

簡單摘錄一下裡面的重點

像是這兩句就道出了主要的差別


> Concurrency is about dealing with lots of things at once.
> Parallelism is about doing lots of things at once.


Concurrency 是一種概念，意思是說你能一次做很多事
Parallelism 則是其中一種實踐這種概念的做法

這個 talk 裡舉的例子很好理解

今天有一群 gopher ( golang 的吉祥物 )，可以想像每隻 gopher 就是一個 task (這裡指的是 Linux 裡的 process 或是 thread 的通稱)，它們要去燒書，書就是我們想要執行的程式。

![](https://talks.golang.org/2012/waza/gophersimple1.jpg)

當然我們會想要程式能夠執行得更快，所以增加了一個 gopher

![](https://talks.golang.org/2012/waza/gophersimple3.jpg)

但是沒有用，gopher 也需要有相對的工具 ( 推車 ) 才能夠改善效率，這裡的推車可以類比為有限的資源，像是 cpu bus

![](https://talks.golang.org/2012/waza/gophersimple2.jpg)

有車了!，但是必須考慮 synchronization 的問題，比如說 A 書必須比 B 書早燒，但是由於有多個 gopher 在燒書，所以有可能發生 B 書比 A 書早燒的情況

好那要是我們把書都分成 independent 的情況那這個問題是不是就解決了

![](https://talks.golang.org/2012/waza/gophersimple4.jpg)

那講到這裡就可以開始解釋，concurrency 和 parallelism 的差異了

# Concurrency

concurrency 是一種概念，是說將一個工作分成很多個獨立不影響的片段並去執行

![](https://talks.golang.org/2012/waza/gophersimple2.jpg)

# Parallelism

parallelism 則是說，現在我的 CPU 核心不只一顆，既然工作是獨立的，那我就可以同時去做這些工作，所以有機會發生，兩堆不同的書，在同一時間被拿去燒

![](https://talks.golang.org/2012/waza/gophersimple4.jpg)