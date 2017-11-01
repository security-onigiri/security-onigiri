---
layout: post
title: Javascript function paramter default  value
author: bananaapple
tags:
  - javascript
categories:
  - computer science
date: 2016-11-16 22:56:00
---
```js
function f(s)
{
	var a = (s == undefined) ? 'qq' : s;
}
```

Can be rewrited as following code

```js
function f(s)
{
	var a = s || 'qq';
}
```

First statement will evaluate value of s is true or not.

If true, s is assigned to a.

Else, statement will find next value a.k.a. 'qq'.

'qq' will be assigned to a.


For further, you could directly write code like this in ES6.

```js
function f(s = 'qq')
{
}
```



