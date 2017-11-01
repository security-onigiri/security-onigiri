---
layout: post
title: "I don't know c language"
tags:
  - c
categories:
  - computer science
date: 2016-04-21 21:12:00
---
## allocate string by array or pointer

What's difference between them?

```c
#include<stdio.h>

int main()
{
    char a[] = "apple";
    char *b = "apple";
}
```

## Answer

```c
    char a[] = "apple";
```

When string is allocated by array, all the characters are saved in the stack.

```c
    char *b = "apple";
```

When string is allocated by pointer, only pointer is saved in the stack, and it points to the string, which is saved in the read-only section.

## function argument array or pointer 

What's difference between them?

```c
#include<stdio.h>

void func1(char * s)
{
	printf("%s",s);
}
void func2(char s[])
{
	printf("%s",s);
}
int main()
{
	func1("apple");
	func2("apple");
    return 0;
}
```

In book "The c programming language 2nd"

```
As formal parameters in a function definition,
	char s[];
and
	char *s;
are equivalent; we prefer the latter because it says more explicitly that the
parameter is a pointer
```

But in which situation, we prefer to use array argument?
In one mail to linux kernel mentioned that

https://lkml.org/lkml/2015/9/3/499

```
The "array as function argument" syntax is occasionally useful
(particularly for the multi-dimensional array case), so I very much
understand why it exists, I just think that in the kernel we'd be
better off with the rule that it's against our coding practices.
```

## sizeof is an operator 

sizeof value is determined in compile time.

sizeof is only correctly used in two places.

### array

```c
char s[10];
printf("%zu",sizeof(s));
// 10
```

### type

```c
char* s="hello";
printf("%zu",sizeof(s));
printf("%zu",sizeof(char *));
/*
8
8
*/
// sizeof(variable) == sizeof(variable type)
```

https://en.wikipedia.org/wiki/Sizeof