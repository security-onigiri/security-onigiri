---
layout: post
title: Virtualization
author: bananaapple
tags:
  - 'virtualization'

categories:
  - computer science
date: 2016-11-18 15:07:00
---
紀錄一下自己最近研讀虛擬化技術的筆記

因為最近要寫有關 qemu 的東西順便學習一下

在介紹之前讓我們先了解一下一些名詞

## Hypervisor ( virtual machine monitor )

用來管理和執行 virtual machine 的軟體

## Host machine 

用來執行 hypervisor 的機器

## Guest machine

被 hypervisor 管理的機器

比如說你在你的電腦上使用 Virtual Box 開了兩個虛擬機，一個是 Windows 10，一個是 Ubuntu

那 Virtual Box 就是 hypervisor，你的電腦就是 Host machine，而 Windows 10 和 Ubuntu 就是 Guest machine

我們通常會將 Guest machine 稱為 instance，instance 可以是不同的作業系統

那跟這個對比的就是 Operating-system-level virtualization，在這通常會將 Guest machine 稱作是 container，container 只能是同一種的作業系統，但是 user space 可以不一樣，像是不同的 Linux distribution 用的是同一個 kernel

那現在正式開始介紹 hypervisor 的類型

## Hypervisor Type

![](https://upload.wikimedia.org/wikipedia/commons/e/e1/Hyperviseur.png)

- Type-1, native or bare-metal hypervisor

這種類型的 hypervisor 可以在硬體上執行

Citrix XenServer, Microsoft Hyper-V and VMware ESX/ESXi 屬於這種

- Type-2 or hosted hypervisors

Hypervisor 被當成 Host machine 的一隻 process 執行

VMware Workstation, VMware Player, VirtualBox, Parallels Desktop for Mac and QEMU 屬於這種

現在 Type-1 和 Type-2 兩者之間的界線越來越模糊，因為原本是 Type-2 的 virtual machine 鑒於效能考量紛紛跨入 Type-1，像是 Linux 的 KVM 就可以被歸類在兩種不同的 hypervisor

## Virtual machine

我們所謂的 virtual machine 主要分為以下三種

## Virtual machine type

- System virtual machines ( Full virtualization )
- Hardware-assisted virtualization
- Operating-system-level virtualization

## System virtual machines ( Full virtualization )

提供了虛擬化整個作業系統的功能

Parallels Workstation, Parallels Desktop for Mac, VirtualBox, Virtual Iron, Oracle VM, Virtual PC, Virtual Server, Hyper-V, VMware Workstation, VMware Server (discontinued, formerly called GSX Server), VMware ESXi, QEMU, Adeos, Mac-on-Linux

## Hardware-assisted virtualization

透過硬體的支援，使得效率提高

KVM, VMware Workstation, VMware Fusion, Hyper-V, Windows Virtual PC, Xen, Parallels Desktop for Mac, Oracle VM Server for SPARC, VirtualBox and Parallels Workstation

## Operating-system-level virtualization

這種技術是指 kernel 作業系統本身提供的虛擬化功能，像是 Linux container 簡稱為 LXC，Docker 在 0.9 版前其實就是 LXC 的前端

# Reference:
- [Virtual machine wiki](https://en.wikipedia.org/wiki/Virtual_machine)
- [Hypervisor wiki](https://en.wikipedia.org/wiki/Hypervisor)
