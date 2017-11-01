---
layout: post
title: how python pass argument in function
tags:
  - python
categories: []
date: 2016-03-22 13:47:00
---
網路上看到蠻多說法的像是
call by value vs call by reference
事實上 call by assignment 才是 python 傳遞參數的方式
主要要介紹 python 的 object
像是以下這行程式碼

```python
a = 1
```

a 就是一個 reference 指向數值為 1 的 PyIntObject
就像是 c 裡面的指標指向一個變數一樣
繼續看一段程式碼

```python
def fun(a):
    print id(a)
a = 1
print id(a)
fun(a)
"""
11211096
11211096
"""
```

那這裡實際上內部是怎麼做的呢?
傳進去 fun function 裡的事實上是 copy of reference to PyIntObject
事實上和還沒傳進去的 a 是兩個不同的 reference 指向同一個 object
id 這個函式 return 的是 object 的位置
所以兩個的值才會一樣
要是有興趣可以看 cpython 裡 id function 的實作

```c
static PyObject *
builtin_id(PyModuleDef *self, PyObject *v)
/*[clinic end generated code: output=0aa640785f697f65 input=5a534136419631f4]*/
{
    return PyLong_FromVoidPtr(v);
}
```

我們修改一下程式碼

```python
def fun(a):
    print id(a)
    a += 1
    print id(a)
a = 1
print id(a)
fun(a)
print id(a)
"""
41632088
41632088
41632064
41632088
"""
```

我們會發覺 id(a) 在 fun function 前後都不會變
這是因為傳進去 function 裡的是 copy of reference to object
所以不會影響到原本的 reference
但是在 fun function 裡的 a
經過 +=1 後 id 改變了
這是因為 int 是 immutable type 
當你要嘗試改 immutable type 的 variable 的時候
他會先產生一個新的 object 再將你的 reference 指向那個 object
要是是mutable variable呢?

```python
def fun(a):
    print id(a)
    a.append(1)
a = []
print id(a)
fun(a)
print id(a)
"""
[]
140347177386784
[1]
140347177386784
[1]
140347177386784
"""
```

執行後會發現 id 都不變
這是因為 mutable variable 的處理方式和 immutable 不同
他是將 reference 指到的 object 擴充而不是重新 assign 一個
那 mutable variable 的 assign 呢?

```python
def fun(a):
    print id(a)
    a.append(1)
a = []
print id(a)
fun(a)
print id(a)
"""
[]
140318457238304
[1]
140318457251672
[]
140318457238304
"""
```

這裡 mutable variable 就和 immutable variable 一樣了
直接捨棄了原本的 object 指向一個新的 object
所以原本傳進去的也是 copy of reference to object
原本的 a 不會受到影響

Reference:
- [call by assignment](https://docs.python.org/2/faq/programming.html#how-do-i-write-a-function-with-output-parameters-call-by-reference)
- [cpython](https://github.com/python/cpython/blob/master/Python%2Fbltinmodule.c#L1092)