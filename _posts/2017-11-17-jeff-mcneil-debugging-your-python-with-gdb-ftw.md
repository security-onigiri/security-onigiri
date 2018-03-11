---
title: 用 GDB 來除錯 Python
layout: post
author: jhe
tags: python gdb
date: 2017/11/17
source-url: http://www.tuicool.com/articles/qYVR7v
---

# Debugging Your Python With GDB (FTW!)
>編按：具體文章已遺失，透過網路找到 cache 文章來翻譯

In this post we'll take a look at how to debug your Python code using GDB. It is a handy thing to understand, especially if you're confronted with an unexpected SEGV or other less than helpful error. I do realize there is some awesome pytohn-gdb.py integration with GDB. I purposefully ignored that.

>在這邊文章中我們將一起探究如何使用 GDB 來為 Python 程式碼除錯。這是一個手工活，特別是你遭遇過一個非預期的 SEGV(SegmentationFault) 或是沒有任何幫助的錯誤訊息。我理解有些像 python-gdb.py 等很讚的 GDB 整合工具，這裡故意忽略不探討之。

As an unfortunate note, I started doing this using Python 3.3, but at some point, I switched 2.6 accidentally. I've migrated the earlier pieces to 2.6. If anyone smarter than I notices an inconsistency, this is why. I'm fairly certian I've cleaned it all up.

>作為一個不幸的紀錄，我剛開始是使用 Python 3.3，但是在某些點上我偶然間換到 2.6。我已經遷移早些的東西到 2.6。如果任何聰明過我的人有注意到矛盾處，這就是原因，我相當的確定已經都處理好了。

Finally, the GDB formatting is mine. I attempted to make it slightly more readable. Hope it helps.

>終於，GDB 格式是我的了。我傾向於讓它更具可讀性，希望這樣有幫助。

### How Does Python Evaluate Code ? / Python 如何解釋程式碼 ？

First, a little bit of background. Python implements a stack-based virtual machine. Python byte code manipulates that stack during normal execution. For example, let's take a look at a small application disassembled into byte code:

>首先，來點背景知識。Python 實做一個基於堆疊的虛擬機 Python byte code 在執行時期操作該堆疊。例如，讓我們觀察一個反組譯成 byte code 的小程式:

```python
a = 1
b = 2
c = a+b
print c
```

This is a fairly trivial example that should show us a good sampling of the "instruction set." We're going to skim over this bit as understanding all of the byte code operations really isn't necessity here. When we use the dis module, we see that the following code is generated:

>這是一個相當顯而易見的例子，應該可以很好的表達指令集的範例。在這裡詳細的了解 byte code 操作並不是很必須的，所以我們將忽略它。當我們使用 dis 模組，我們看到產生的程式碼如下:

```
1    0 LOAD_CONST    0(1)
     3 STORE_NAME    0(a)

2    6 LOAD_CONST    1(2)
     9 STORE_NAME    1(b)

3   12 LOAD_NAME     0(a)
    15 LOAD_NAME     1(b)

4   22 LOAD_NAME     2(c)
    25 PRINT_ITEM
    26 PRINT_NEWLINE
    27 LOAD_CONST    2(None)
    30 RETURN_VALUE
```

This is fairly self explanatory. We see at position 1 that the constants 1 & 2 are placed into a & b. Next, they're placed on the stack and BINARY_ADD is called, which triggers the addition of two number objects. Next, STORE_NAME saves the value of the add operation (from the top of the stack) to the location c. Finally, we load c and call the print operations. In Python 3, this would simply call the print function, via CALL_FUNCTION. For an overview of how Python generates bytecode from Python code, see Python/compile.c. The comment at the top of the file is quite helpful.

>相當不言自明的。我們看到位置 *1* 常數 *1* 與 *2* 被放入 *a* 與 *b*。下一個，他們被放置在堆疊上，而觸發兩個數字物件相加的 BINARY_ADD 則被呼叫了，接下來 STORE_NAME 儲存了加法運算的值 (從堆疊的頂端) 到位置 *c*. 最後，我們載入 *c* 並且呼叫 print 操作。在 Python 3 將簡單透過 CALL_FUNCTION 呼叫 print 函式。為了要知道 Python 如何從 Python 程式碼產生 bytecode ，可以參照 Python/compile.c 。在該檔案頂端的註解非常的有幫助。

Using Python 2.6 as a reference point, all of this happens at Python/ceval.c. The function handling byte code execution is named PyEval_EvalFrameEx. Generally, this is a big switch statement. I use the term switch loosely as it is actually a collection of computed goto labels on both Mac OS and Linux (Visual Studio doesn't allow that).

>使用 Python 2.6 作為一個參考點，所有的這些流程都發生在 Python/ceval.c。處理執行 bytecode 的函式名為 *PyEval_EvalFrameEx*。大致上，這是一個大型的 switch 陳述語句。在 Mac OS 與 Linux 上我使用 switch 這個詞泛指實際上是一個計算過後的 *goto* 標籤集合 (在 Visual Studio 上不允許)。

Looking at this function, you'll see various entries such as this;
>看這個函釋，你將看到各種類似這樣的進入點

```clike
case POP_TOP:
    v = POP();
    Py_DECREF(v);
    goto fast_next_opcode;
```

This is the implementation for the POP_TOP instuction. The POP macro returns the top value of the stack and the subsequent Py_DECREF(v) decrements the reference count. At this point, that could trigger execution of v->ob_type->tp_del & v->ob_type->tp_dealloc, if the reference count of v (v->ob_refcnt) has reached zero. As an aside, note that Python checks for events/thread switches every sys.getcheckinterval() instuctions. If the corresponding implementation of an instruction is complex (and doesn't release the GIL), we can be left waiting here.

>這是 *POP_TOP* 指令的實作。*POP* 巨集返回堆疊頂端上的值，隨後的 *Py_DECREF(v)* 減少參考計量。在此，如果 v (v->ob_refcnt) 的參考計量為 *0* 則會觸發 *v->ob_type->tp_del* 與 *v->ob_type->tp_dealloc* 的執行。另外，Python 會在每個 *sys.getcheckinterval()* 指令檢查事件與執行緒的切換。我們將需要等待，如果對應的指令實作是複雜的 (而且不釋放 GIL)。

Now, we come to the function we're interested in:
>現在來到我們的目標函式:

```clike
PyObject * PyEvalCodeEx(PyObject *co, PyObject *globals, PyObject *locals, PyObject **args, int argcount, PyObject **kws, int kwcount, PyObject **defs, int defcount, PyObject *closure);
```
Essentially this fucntion builds a frame from the code object being executed and relies on PyEval_PyEvalFrameEx to handle bytecode instruction evaluation. The code object contains references to globals, locals, nested scopes (free vars/cell vars, depending on the angle), etc. PyEvalCodeEx "transforms" that into a PyFrameObject.

>本質上這個函式從被執行的程式碼物件建立一個 *frame* 並依靠 *PyEval_PyEvalFrameEx* 來處理 bytecode 指令的解釋。程式碼物件包含對 *globals*、*locals*、巢狀作用域(free vars/cell vars, 視角度而定) 等的參考。 *Py_EvalCodeEx* 將之轉換成一個 PyFrameObject。

It is this code object evalution function we're interested in as functions and methods are generally boiled down to code objects.

>我們感興趣的程式碼解釋物件作為函式與方法通常歸根究柢都是程式碼物件。

### Python Data Structure Data Structures / Python 資料結構資料結構

Now that we've covered where to look, we need to take a look at what to look for. This means building a bit of an understanding around a few data structures.

>我們已經過了要看哪裡的部分，我們需要看一下我們在尋找什麼。這代表建立一些資料結構的背景知識。

#### Type Objects / 型態物件

All of Python's classes (well, almost) are represented by PyTypeObject objects, which is defined in Python/Include/Object.h. This structure contains a whole lot of fields. Most of these fields will be pretty familiar looking as this is generally how "dunder", or \_\_methods\_\_, are implemented. Standard, generic values are used(see PyType_Ready) if you don't setup your own. This is a long structure, but including it here is relevant:

>所有的 Python 類別(幾乎啦) 是用 PyTypeObject 物件來表示，定義在 *Python/Include/Object.h*。這個結構包含一脫拉庫的欄位。大部分的欄位大概就是 "dunder" (編按：dunder 為 python 用來表示被雙底線夾住的目標，如 dunder getitem 就是 \_\_getitem\_\_)或 *\_\_methods\_\_* 如何被實作的。使用標準的值(參照 PyType_Ready) 如果你不自己設定。這是一個落落長的資料結構，但在這裡提到是有意義的。

```clike
typedef struct _typeobject {
    PyObject_VAR_HEAD
    const char *tp_name; /* For printing, in format " */
    Py_ssize_t tp_basicsize, tp_itemsize; /* For allocation */
    /* Methods to implement standard operations */
    destructor tp_dealloc;
    printfunc tp_print;
    getattrfunc tp_getattr;
    setattrfunc tp_setattr;
    comfunc tp_compare;
    reprfunc tp_repr;
    
    /* Method suites for standard classes */
    PyNumberMethods *tp_as_number;
    PySequenceMethods *tp_as_sequence;
    PyMappingMethods *tp_as_mapping;
    /* More standard operations (here for binary compatiblility) */
    hashfunc tp_hash;
    ternaryfunc tp_call;
    reprfunc tp_str;
    getattrofunc tp_getattro;
    setattrofunc tp_setattro;
    
    /* Functions to access object as input/output buffer */
    PyBufferProcs *tp_as_buffer;
    
    /* Flags to define presence of optional/expanded features */
    long tp_flags;
                            
    const char *tp_doc; /* Docuemntatioin string */
    
    /* Assigned meaning in release 2.0 */
    /* call function for all accessible objects */
    traverseproc tp_traverse;
                            
    /* delete refereces to contained objects */
    inquiry tp_clear;
    
    /* Assigned meaning in release 2.1 */
    /* rich comparisions */
    richcmpfunc tp_richcompare;
    
    /* weak reference enabler */
    Py_ssize_t tp_weaklistoffset;
                            
    /* Added in release 2.2 */
    /* Iterators */
    getiterfunc tp_iter;
    iternextfunc tp_iternext;

    /* Attribute descriptor and subclassing stuff */
    struct PyMethodDef *tp_methods;
    struct PyMemberDef *tp_members;
    struct PyGetSetDef *tp_getset;
    struct _typeobject *tp_base;
    PyObject *tp_dict;
    descrgetfunc tp_descr_get;
    descrsetfunc tp_descr_set;
    Py_ssize_t tp_dictoffset;
    initproc tp_init;
    allocfunc tp_alloc;
    newfunc tp_new;
    freefunc tp_free; /* Low-level free-memory routine */
    inquiry tp_is_gc; /* For PyObject_IS_GC */
    PyObject *tp_bases;
    PyObject *tp_mro; /* method resolution order */
    PyObject *tp_cache;
    PyObject *tp_subclasses;
    PyObject *tp_weaklist;
    destructor tp_del;

    /* Type attribute cache version tag. Added in version 2.6 */
    unsigned int tp_version_tag;

#ifdef COUNT_ALLOCS
    /* these must be last and never explicitly initialized */
    Py_ssize_t tp_allocs;
    Py_ssize_t tp_frees;
    Py_ssize_t tp_maxalloc;
    struct _typeobject *tp_prev;
    struct _typeobject *tp_next;
#endif                            
} PyTypeObject;
```

The typedef (typedefs? Anyone know the plural of #typedef?) above (i.e. PyNumberMethods) are the C-level equivalent of the double underscore methods required to implement a certain protocol (programmatic interface). They expand into method collections:

>*typedef* (typedefs? 有任何人知道這個 typedef 的複數嗎?) 之上 (如 PyNumberMethods) 是 C 層級等同於雙底線方法，是實作一個特定協定必須的 (計畫性的介面)。他們擴展成方法的集合:

```
typedef struct {
    lenfunc mp_length;
    binaryfunc mp_subscript;
    objobjargproc mp_ass_subscript;
} PyMappingMethods;
```

These translate into len, subscript, and subscript assignment.
>這些翻譯成 *len*、*subscript*與 *subscript 賦值*。

### Instances / 實例

All Python instances are all implemented as pointers to PyObject values, which is defined as:
>所有的 Python 實例都是實作成指標指向 PyObject，定義如

```
typedef struct _object {
    PyObject_HEAD
} PyObject;
```

PyObject_HEAD, by default, expands to include only a pointer to the object’s type (type objects have a type of type!) and the reference count.
>預設為 PyObject_HEAD，擴展包括只有一個指標指向物件的型態(type 物件有一個型態的型態!) 與 參考計量。

```
/* PyObject_HEAD defines the initial segment of every PyObject. */
#define PyObject_HEAD                   \
    _PyObject_HEAD_EXTRA                \
    Py_ssize_t ob_refcnt;               \
    struct _typeobject *ob_type;
```

Wait! Where is all of the per-instance data you say? For classes that do not define \_\_slots\_\_, there is a dictoffset member of the corresponding PyTypeObject structure. This provides the address, via offset from the end of the PyObject structure, that contains a Python dictionary. This is the \_\_dict\_\_ used to store per instance information.  If \_\_slots\_\_ is defined, then dictoffset is NULL and the slot values are stored at the end of the PyObject structure and accessed via descriptors. Generic structures are passed around via casting (and turned back into concrete values via the same method).

>等等! 你說的每個實例的資料在哪裡 ? 對於沒有定義 *\_\_slots\_\_* 的類別來說，有一個對應的 PyTypeObject 結構 *dictoffset* 成員。透過從 PyObject 結構底部位移包含一個 Python 字典。這是 *\_\_dict\_\_* 用來儲存每個實例的資訊。倘若有定義 *\_\_slots\_\_*，則 dictoffset 為 *NULL* 且位置值被存放在 PyObject 結構底部並透過描述子存取。一般的結構透過轉型到處傳遞(而且透過一樣的方法轉變回具體的值)

Somewhat related bonus Python trivia: The class dictionary is actually a PyDictProxy_Type that refers to the type’s tp_dict field.  You can’t edit it directly.
>一點相關的額外 Python 瑣事: 字典類別實際上是一個 PyDictProxy_Type 參考自 type 的 tp_dict 欄位。你不能直接修改他。

To clarify, assuming we have a type NinjaTurtle that is represented by PyTypeObject *ninja, then for an instance donatello, the following is true: (PyObject \*)donatello->ob\_type = ninja; Good. So, naturally, to perform an init call, the corresponding code would like like the following:

>為了闡明一點，假設我們有一個型別 *NinjaTurtle* 是用 *PyTypeObject \*ninja* 來表示，那麼有一個實例 *donatello*(編按:其中一隻忍者龜的名字)，則下列為真: *(PyOject \*)donatello->ob\_type = ninja;* 很好。所以，自然地，為了表現一個初始化呼叫，對應的程式碼可能看起來(編按: 原文為 like like 應為打錯，故翻為 look like)如下:

`donatello->ob_type->tp_init((PyObject *)donatello);`

In fact, this is almost exactly what happens when a type is called directly (ala class instantiation: MyClass()).
>事實上，這是當一個類型被直接呼叫的時候幾乎會發生的事情(也稱為類別實例化: MyClass()，編按:原文又把 aka 打成 ala 了...)。

### Code Objects / 程式碼物件

Let’s look at one final object, the code object. This is represented by a structure defined in code.h.  It is rather simple object (though note the first member).
>讓我們來看最後一個物件，程式碼物件。在 *code.h* 使用一個結構來定義。這是一個相當簡單的物件 (不過請注意第一個成員)。

```
/* Bytecode object */
typedef struct {
    PyObject_HEAD
    int co_argcount;    /* #arguments, except *args */
    int co_nlocals;   /* #local variables */
    int co_stacksize;   /* #entries needed for evaluation stack */
    int co_flags;   /* CO_..., see below */
    PyObject *co_code;    /* instruction opcodes */
    PyObject *co_consts;  /* list (constants used) */
    PyObject *co_names;   /* list of strings (names used) */
    PyObject *co_varnames;  /* tuple of strings (local variable names) */
    PyObject *co_freevars;  /* tuple of strings (free variable names) */
    PyObject *co_cellvars;      /* tuple of strings (cell variable names) */
    /* The rest doesn't count for hash/cmp */
    PyObject *co_filename;  /* string (where it was loaded from) */
    PyObject *co_name;    /* string (name, for reference) */
    int co_firstlineno;   /* first source line number */
    PyObject *co_lnotab;  /* string (encoding addr<->lineno mapping) See
           Objects/lnotab_notes.txt for details. */
    void *co_zombieframe;     /* for optimization only (see frameobject.c) */
    PyObject *co_weakreflist;   /* to support weakrefs to code objects */
} PyCodeObject;
```

From here, we can switch into Python. Note the above fields and then have a peek at a function’s func_code attribute (\_\_code\_\_ in 3.x):

>從這裡，我們可以切換到 Python。注意上面的欄位並且看一下函式的 *func_code* 屬性 (在 py3 為 *\_\_code\_\_*)

```
>>>
>>> def f(): pass
...
[66987 refs]
>>> import pprint
[67863 refs]
>>> pprint.pprint(dir(f.func_code))
['__class__',
'__delattr__',
'__dir__',
'__doc__',
'__eq__',
'__format__',
'__ge__',
'__getattribute__',
'__gt__',
'__hash__',
'__init__',
'__le__',
'__lt__',
'__ne__',
'__new__',
'__reduce__',
'__reduce_ex__',
'__repr__',
'__setattr__',
'__sizeof__',
'__str__',
'__subclasshook__',
'co_argcount',
'co_cellvars',
'co_code',
'co_consts',
'co_filename',
'co_firstlineno',
'co_flags',
'co_freevars',
'co_kwonlyargcount',
'co_lnotab',
'co_name',
'co_names',
'co_nlocals',
'co_stacksize',
'co_varnames']
[67870 refs]
>>>
```

Perfect. Now we've made the connection between Python and C. Now we can take a look at the actual debugging process.

>完美。現在我們將 Python 與 C 連接起來了。我們可以來瞧瞧真正的除錯行程了。


### GDB'ing the Py. / 來 GDB Py 吧

We’ll use the same small bit of code we used above as our test script. We’re referencing /usr/bin/python here, which may vary on your system.

>我們將使用同上面一樣的小程式來當測試程式。我們這裡參考到 /usr/bin/python，在你系統上可能不同。

First, we’ll start the interpreter. Note that we’re debugging Python itself, not the script passed to it. GDB will not start if we pass in the Python script as the executable.

>首先我們開啟直譯器。注意我們是要除錯 python 而非被傳進去腳本程式。如果我們傳入 python 腳本當作執行檔 GDB 將不會啟動。

```
jeff@martian:~/cpython$ gdb /usr/bin/python
GNU gdb (GDB) 7.4-gg1
Copyright (C) 2012 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-linux".

Reading symbols from /usr/bin/python...
Reading symbols from /usr/lib/debug/usr/bin/python...done.
done.
```

Now we’ll set the appropriate args for the execution of Python — our script. Note that nothing is running at this point.

>現在我們要設定 python 執行參數 - 我們的腳本。
請注意現在是沒有任何東西在執行的。

```
(gdb) set args add.py
```

Now, since we want to see how to pick apart the location of our Python code from the C level, we’ll set a breakpoint at PyEval_EvalCodeEx. This forces GDB to up and stop when it gets to our function.

>現在，由於我們要觀察如何對我們的 python 程式碼在 C 語言層級吹毛求疵，我們將設下一個斷點在 *PyEval_EvalCodeEx*。強迫 GDB 執行到我們的函式時停下來。

```
(gdb) break PyEval_EvalCodeEx
Breakpoint 1 at 0x80e1f53: file ../../../Python/ceval.c, line 2767.
(gdb)
```

Note that if the correct source is available, this gets much easier as there is Python+GDB integration available via python-gdb.py. Now, we can run the executable:

>如果正確的原始碼是可取得的，這將會容易很多如同那些 Python+GDB 整合工具一樣。現在我們可以執行可執行檔：

```
(gdb) run
Starting program: /usr/bin/python add.py

Breakpoint 1, PyEval_EvalCodeEx (co=0xf7de7338, globals=0xf7df313c,
   locals=0xf7df313c, args=0x0, argcount=0, kws=0x0, kwcount=0,
   defs=0x0, defcount=0, closure=0x0)
at ../../../Python/ceval.c:2767
2767 ../../../Python/ceval.c: No such file or directory.
```
### Understanding the Object Representation / 理解物件表示法

From here, we can examine the code in question. First, let’s print the value of the first argument to PyEval_EvalCodeEx. From our prototype above, we know this is a code object:

>從這裡開始，我們可以檢查程式碼裡的問題了。首先，讓我們印出 *PyEval_EvalCodeEx* 的第一個參數。根據我們上面的原型，我們知道這是一個程式碼物件：

```
(gdb) p *co
$1 = {ob_refcnt = 1, ob_type = 0x81a1e60, co_argcount = 0,
  co_nlocals = 0, co_stacksize = 1, co_flags = 64,
  co_code = 0xf7dedd40, co_consts = 0xf7dedd0c,
  co_names = 0xf7dc102c, co_varnames = 0xf7dc102c,
  co_freevars = 0xf7dc102c, co_cellvars = 0xf7dc102c,
  co_filename = 0xf7de4200, co_name = 0xf7dedd60,
  co_firstlineno = 1, co_lnotab = 0xf7dc10b0, co_zombieframe = 0x0}
(gdb)
```

Here, we see the ob_refcnt and the ob_type. If we cast this to a PyObject \*, you’ll see that it only prints that information.
>這裡，我們看到 *ob_refcnt* 與 *ob_type*。如果我們把它轉型成一個 _PyObject \*_(編按：表示為 PyObject 指標)，你將會看到它唯一印出的資訊。

```
(gdb) p *(PyObject *)co
$4 = {ob_refcnt = 1, ob_type = 0x81a1e60}
(gdb)
```

Ok, let’s step ahead until we see something interesting. We’ll “GDB continue” until we have an args=\<value\> which is not 0×0, or NULL.  We’ll look at the following frame:

>好的，讓我們前進一步直到我們看到一些某些有去的東西。我們將 "GDB continue" 到我們有一個 args=\<value\> 不是 0x0 或是 NULL 為止。我們將看到如下的 frame：

```
Breakpoint 1, PyEval_EvalCodeEx (co=0xf7d8cc80, globals=0xf7d8a35c, locals=0x0,
  args=0x81bfe7c, argcount=0, kws=0x81bfe7c, kwcount=0, defs=0x0,
   defcount=0, closure=0x0)
at ../../../Python/ceval.c:2767
2767 in ../../../Python/ceval.c
(gdb) info frame
Stack level 0, frame at 0xfffec7a0:
eip = 0x80e1f53 in PyEval_EvalCodeEx (../../../Python/ceval.c:2767);
  saved eip 0x80e0cd2
called by frame at 0xfffec890
source language c.
Arglist at 0xfffec798, args: co=0xf7d8cc80, globals=0xf7d8a35c,
  locals=0x0, args=0x81bfe7c,
  argcount=0, kws=0x81bfe7c, kwcount=0, defs=0x0, defcount=0, closure=0x0
Locals at 0xfffec798, Previous frame's sp is 0xfffec7a0
Saved registers:
ebx at 0xfffec78c, ebp at 0xfffec798, esi at 0xfffec790,
  edi at 0xfffec794, eip at 0xfffec79c
(gdb)
```

First, let’s have a look at the co value again:
>首先，讓我們再看一下 *co* 的值：

```
(gdb) p *co
$10 = {ob_refcnt = 2, ob_type = 0x81a1e60, co_argcount = 0,
       co_nlocals = 0, co_stacksize = 1,
       co_flags = 99, co_code = 0xf7d8e688,
       co_consts = 0xf7d8ddac, co_names = 0xf7dc102c,
       co_varnames = 0xf7dc102c, co_freevars = 0xf7dc102c,
       co_cellvars = 0xf7dc102c,
       co_filename = 0xf7d8cc38, co_name = 0xf7d8ddc0,
       co_firstlineno = 51, co_lnotab = 0xf7d8dde0,
       co_zombieframe = 0x0}
```

### Building a Python Friendly Backtrace / 建立一個 Python 友善的回溯

Now we can deduce where exactly this code comes from. We can pull the line number, the function name, and the file!
>現在我們可以推斷至這個程式碼確切是從哪來的。我們可以調出程式碼的行號、函式名稱及檔案位置。

```
(gdb) p co->co_firstlineno
$16 = 51
(gdb) x/s ((PyStringObject)*co->co_name)->ob_sval
0xf7d8ddd4: "_g"
(gdb) x/s ((PyStringObject)*co->co_filename)->ob_sval
0xf7d8cc4c: "/usr/lib/python2.6/types.py"
(gdb)
```

So, types.py, line 51, function \_g. Let’s take a look:
>所以，type.py, 行 51, 函數 \_g。讓我們看一下：

```
jeff@martian:~$ head /usr/lib/python2.6/types.py -n 51 | tail -n 1
def _g():
```

Excellent. This is where our Python function lives! There’s no point in going into it, however, this gives us a starting point to determine where a problem lives.
>棒棒。這就是我們 Python 函式的所在！已經沒有理由再這個點深入了，然而這給了我們一個起始點去確定哪裡有問題。

### Looking up Argument Types and Values / 查找參數、型態與值

Furthermore, we can pull out information about the arguments passed as well.  Let’s go back and determine what the type is. Remember our ‘info frame’ gave us an args parameter?

>此外，我們也可以調出有關傳入參數的資訊。讓我們回到確定型態的那裡。記得我們 'info frame' 給我們一個 args 參數嘛？

```
(gdb) p *args
$21 = (PyObject *) 0x0
```

Drat! Null. This function takes no arguments.  Let’s jump down a few more frames until we find a function that includes an argument.
>該死！ Null. 這個函式沒有函數。讓我們往下跳一些 frame 直到我們找到一個有參數的函式。

```
Breakpoint 1, PyEval_EvalCodeEx (co=0xf7d9f8d8, globals=0xf7d8a9bc, locals=0x0,
  args=0xf7d9e1c8, argcount=4, kws=0x0, kwcount=0, defs=0x0, defcount=0, closure=0x0)
at ../../../Python/ceval.c:2767
2767 in ../../../Python/ceval.c
(gdb) info frame
Stack level 0, frame at 0xfffefa50:
eip = 0x80e1f53 in PyEval_EvalCodeEx (../../../Python/ceval.c:2767);
  saved eip 0x813e70e
called by frame at 0xfffefac0
source language c.
Arglist at 0xfffefa48, args: co=0xf7d9f8d8, globals=0xf7d8a9bc, locals=0x0,
  args=0xf7d9e1c8, argcount=4, kws=0x0, kwcount=0, defs=0x0, defcount=0, closure=0x0
Locals at 0xfffefa48, Previous frame's sp is 0xfffefa50
Saved registers:
ebx at 0xfffefa3c, ebp at 0xfffefa48, esi at 0xfffefa40, edi at 0xfffefa44,
  eip at 0xfffefa4c
(gdb)
```

Here we go. Now, using the above “trick”, we learn that this is line 78 in method \_\_new\_\_ in abc.py:
>有啦。現在使用在上面的 "小技巧"，我們知道這是在 abc.py 第 78 行的 \_\_new\_\_ 方法。

```
(gdb)p co->co_firstlineno
$24 = 78
(gdb) x/s ((PyStringObject)*co->co_name)->ob_sval
0xf7dc4694: "__new__"
(gdb) x/s ((PyStringObject)*co->co_filename)->ob_sval
0xf7d9f8a4: "/usr/lib/python2.6/abc.py"
(gdb)
```

Perfect. Now, since \_\_new\_\_ is (sometimes) indicative of a metaclass — and we’re looking at code from the Abstract Base Class module which I happen to know goes metaclass crazy — we should have a class, a name, a bases tuple, and an object dictionary. Let’s look at the object types:

>水喔。由於 \_\_new\_\_ (有時候)表示一個元類別 - 而且我們正看著 Abstract Base Class 模組的程式碼，我剛好知道那個鬼元類別 - 我們應該要有一個類別、一個名字、一的基礎元組和一個物件字典。讓我們看一下這個物件型態：

```
(gdb) x/s args[0]->ob_type.tp_name
0x81590e5 <.LC33+5012>: "type"
(gdb) x/s args[1]->ob_type.tp_name
0x8158d74 <.LC33+4131>: "str"
(gdb) x/s args[2]->ob_type.tp_name
0x8158f43 <.LC33+4594>: "tuple"
(gdb) x/s args[3]->ob_type.tp_name
0x8156ea5 <.LC16+1319>: "dict"
(gdb)
```

Perfect! We’ve found the location of the code executing and the types of arguments that it takes.  What if we wanted to see, for example, the actual name passed in instead of the “str” type? Simple. We just repeat what we’ve already learned:

讚啦！我們找到了程式碼執行與參數型態用到的位置了。舉例來說，如果我們要看確切傳入的名字而非 "str" 型態？簡單。我們只要重複我們已經學到的：

```
(gdb) x/s (*(PyStringObject *)args[1]).ob_sval
0xf7d96054: "Hashable"
(gdb) p (*(PyStringObject *)args[1]).ob_refcnt
$38 = 8
(gdb)
```

Now we know, without looking at a line of Python, that this is the \_\_new\_\_ method of the metaclass for the Hashable ABC and the name of the class has a reference count of 8.

>現在我們知道，不用看一行 Python 程式碼，這是一個 \_\_new\_\_ 元類別的方法用來可雜湊的 ABC 與類別名跟參考計量為 8。

### Accessing Dictionaries / 存取字典

Finally, what about something more detailed? Let’s look at the dictionary passed here.
>最終，那更詳細的呢。讓我們看一下這裡的字典傳遞。

```
(gdb) p *((PyDictObject*)args[3])
$51 = {ob_refcnt = 3, ob_type = 0x81854a0, ma_fill = 4, ma_used = 4, ma_mask = 7,
  ma_table = 0xf7d8aa60, ma_lookup = 0x808c70c , ma_smalltable = {
   {me_hash = 435549560, me_key = 0xf7dc44e0, me_value = 0xf7d9b4fc},
   {me_hash = 0, me_key = 0x0, me_value = 0x0},
   {me_hash = 1333480578, me_key = 0xf7dc2a20, me_value = 0xf7d9d5a0},
   {me_hash = -1120181165,me_key = 0xf7dc2688, me_value = 0xf7dc132c},
   {me_hash = 1733367940, me_key = 0xf7d942f0, me_value = 0x81c3e64},
   {me_hash = 0, me_key = 0x0, me_value = 0x0},
   {me_hash = 0, me_key = 0x0, me_value = 0x0},
   {me_hash = 0, me_key = 0x0, me_value = 0x0}}}
(gdb)
```

What’s all of this me business? Let’s look at one of the items in the hash table representing the dictionary.
>這一團 me 是怎麼回事？讓我們看一下用雜湊表來表示的字典中的其中一個項目。

```
(gdb) p *((PyTypeObject*)((PyDictObject*)args[3])->ma_smalltable[2].me_key.ob_type)
$64 = {ob_refcnt = 71, ob_type = 0x818a940, ob_size = 0, tp_name = 0x8158d74 "str",
  tp_basicsize = 24, tp_itemsize = 1, tp_dealloc = 0x809d982 ,
  tp_print = 0x809d74c , tp_getattr = 0, tp_setattr = 0, tp_compare = 0,
  tp_repr = 0x809ec77 , tp_as_number = 0x8187fe0, tp_as_sequence = 0x8188080,
  tp_as_mapping = 0x81880a8, tp_hash = 0x809c5a9 , tp_call = 0, tp_str = 0x809e602 ,
  tp_getattro = 0x8091091 ,
  tp_setattro = 0x8090e1a , tp_as_buffer = 0x81880b4, tp_flags = 136713723,
  tp_doc = 0x81880e0
   "str(object) -> string\n\nReturn a nice string representation of the object.\n
        If the argument is a string, the return value is the same object.",
  tp_traverse = 0,
  tp_clear = 0, tp_richcompare = 0x809cd84 , tp_weaklistoffset = 0, tp_iter = 0,
  tp_iternext = 0, tp_methods = 0x8188180, tp_members = 0x0, tp_getset = 0x0,
  tp_base = 0x8187c00, tp_dict = 0xf7dc34f4, tp_descr_get = 0, tp_descr_set = 0,
  tp_dictoffset = 0, tp_init = 0x80ac582 , tp_alloc = 0x80ad345 ,
  tp_new = 0x80a2fcc , tp_free = 0x8094510 , tp_is_gc = 0, tp_bases = 0xf7dc4f0c,
  tp_mro = 0xf7dc7fa4, tp_cache = 0x0, tp_subclasses = 0x0,
  tp_weaklist = 0xf7dc7fcc, tp_del = 0, tp_version_tag = 0}
(gdb)
```

Excellent. The key type is a string. What’s the value?
>不錯喔。主要的型態是一個字串。那值是什麼？

```
(gdb) x/s ((PyStringObject *)((PyTypeObject*)((
    PyDictObject*)args[3])->ma_smalltable[2].me_value)).ob_sval
0xf7d9d5b4: "_abcoll"
(gdb)
```

The value of this entry is the string “\_abcoll.” Note that the key type doesn’t reference the value type. I left out the step in which I looked up the value’s type.
>這個項目的值是字串 "\_abcoll." 注意這個主要型態沒有參考值型態。我忽略的搜尋值得型態的步驟。

### Closing Notes / 結語

The most important step in understanding how to do this is having Python source available. You’re debugging a C program here; you want to access structure members and fields.  Given the above knowledge, you should be able to walk through and display information about almost any Python object in memory. A big help.

>了解如何做這些事情最重要的步驟是擁有一份 Python 原始碼。你在這裡除錯 C 程式語言;你想要存取結構成員與欄位。考慮到上述的知識，你應當可以檢視並顯示有關幾乎任何在記憶體中的 Python 物件。一個大大的幫助。

### What about the shared libraries ? / 那有關分享函式庫呢 ?

If you’re referencing shared object files that aren’t in standard library paths, you can add them to your GDB shared object search path from your local directory as follows:

>如果你正參考到不在標準函式路徑中的分享函式庫目的檔，你可以將他們從本地目錄加到你的 GDB shared object search path 如下:

```shell
for i in $(find . -name *.so)
  do
    dirname $i;
  done | sort | uniq | tr \\n : | sed -e 's#\./#'$PWD'#g'
```

And then ...
>然後 ...

```
(gdb) set solib-search-path <the above output>
```

As always, you should ensure these are the same versions that you’re running or that may be referenced in a core.
>如同平常一樣，你需要確定這些正在執行的版本與產生的版本一致。

### What if I Have a Core File? / 如果我有一個 core 檔 ?

You’ll use it like you would with any other debug session:
> 你可以如同使用其他 debug session 一樣：

```
gdb -c <core> /usr/bin/python
```

All of the standard commands should work at that point: up, down, select, frame, etc...
>所有的標準命令應該正常運作: up, down, select, frame 等等

### How do I Get a Core File ? / 我要怎麼得到一個 core 檔案 ?

You can force a binary to drop a core by ensuring that the ulimit is set appropriately via ulimit -Sc unlimited. If your core files aren’t where you expect, see man core.

>只要將 ulimit 設定得當，透過 `ulimit -Sc unlimited`，就可以強迫一個二進制檔案生成一個 core。如果你的 core 檔案不是你所預期的，請參照 man core(編按: man 是Linux 下的 mannual)。