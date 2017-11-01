---
layout: post
title: 'alignment and round number using & and ~'
tags:
  - linux kernel
categories:
  - computer science
date: 2016-03-31 02:02:00
---
While tracing malloc.c code, I found some interesting bitwise operation.


```c
#define MALLOC_ALIGN_MASK      (MALLOC_ALIGNMENT - 1)
#define MINSIZE  
  (unsigned long)(((MIN_CHUNK_SIZE+MALLOC_ALIGN_MASK) & ~MALLOC_ALIGN_MASK))

```

I found the answer in the stackoverflow.

http://stackoverflow.com/questions/14561402/how-is-this-size-alignment-working

```
All powers of two (1, 2, 4, 8, 16, 32...) can be aligned by simple a and operation.

This gives the size rounded down:

size &= ~(alignment - 1); 

or if you want to round up:

size = (size + alignment-1) & ~(alignment-1);
```

**MINSIZE** macro trying to find largest number alignment to **MALLOC_ALIGNMENT**

For example

```c
MIN_CHUNK_SIZE = 25;
MALLOC_ALIGNMENT = 8
MALLOC_ALIGN_MASK = 8-1 = 7;
MINSIZE = (25+7) & ~7 = 32;
```

# More
https://graphics.stanford.edu/~seander/bithacks.html