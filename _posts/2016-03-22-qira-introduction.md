---
layout: post
title: qira introduction
tags:
  - qira
  - ctf
categories:
  - computer science
date: 2016-03-22 13:42:00
---
![image from qira.me website](http://qira.me/img/first_splash.png)

---

- QIRA is timeless debugger

- Fullname is QEMU Interactive Runtime Analyser

- QIRA was initially developed at Google by George Hotz. Work continues at CMU.

## qira website

http://qira.me/

## qira github repository

https://github.com/BinaryAnalysisPlatform/qira
## Installation

```bash
cd ~/
git clone https://github.com/BinaryAnalysisPlatform/qira.git
cd qira/
./install.sh
```
If you want to run with other architecture, run the following command

It will fetch other architecture's library
```bash
./fetchlib.sh
```

## Usage

![Usage](http://i.imgur.com/N5EpyfB.png)

```bash
cd ~/
wget http://train.cs.nctu.edu.tw/files/magic
chmod +x ./magic
qira  -s ./magic
```
open other terminal and type
```
nc 0 4000
```
use this terminal to interactive with program

You could trace the instructions with web browser on http://localhost:3002/

## Keyboard Shortcuts in web/client/controls.js
```
j -- next invocation of instruction
k -- prev invocation of instruction

shift-j -- next toucher of data
shift-k -- prev toucher of data

m -- go to return from current function
, -- go to start of current function

z -- zoom out max on vtimeline

l -- set iaddr to instruction at current clnum

left  -- -1 fork
right -- +1 fork
up    -- -1 clnum
down  -- +1 clnum

esc -- back

shift-c -- clear all forks

n -- rename instruction
shift-n -- rename data
; -- add comment at instruction
shift-; -- add comment at data

g -- go to change, address, or name
space -- toggle flat/function view

p -- analyze function at iaddr
c -- make code at iaddr, one instruction
a -- make ascii at iaddr
d -- make data at iaddr
u -- make undefined at iaddr
```

## Further

qira is made of following compoments

- qemu
- flask
- python
- qiradb

qemu is used to emulate other architecture

Flask is a microframework for Python based on Werkzeug, Jinja 2 and good intentions

The most code of qira is written by Python

qiradb is a python package deal with the instruction trace

##  Working with ida plugin

### Testing environment

- Windows 10

- Vmware workstation Pro 12 with Ubuntu 15.10

Install qira 1.2 on Ubuntu 15.10 and port-forwarding 3002 port

Copy qira_ida66_windows.p64 and qira_ida66_windows.plw from qira/ida/bin/ to ida pro plugins/ directory

Open Chrome and IDA PRO on windows 10

It should work like this

![ida plugin](http://qira.me/img/ida.png)