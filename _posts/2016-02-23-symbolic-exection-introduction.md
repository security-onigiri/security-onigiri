---
layout: post
title: symbolic exection introduction
tags: []
categories: []
date: 2016-02-23 09:19:00
---
# Symbolic execution
---
# Defenition

Symbolic execution (also symbolic evaluation) is a means of analyzing a program to determine what inputs cause each part of a program to execute.

An interpreter follows the program, assuming symbolic values for inputs rather than obtaining actual inputs as normal execution of the program would, a case of abstract interpretation.

It thus arrives at expressions in terms of those symbols for expressions and variables in the program, and constraints in terms of those symbols for the possible outcomes of each conditional branch.
# Example
```c
int f() {
  ...
  y = read();
  z = y * 2;
  if (z == 12) {
    fail();
  } else {
    printf("OK");
  }
}
```
During "concrete" execution, the program would read a concrete input value (e.g., 5) and assign it to y.

During symbolic execution, the program reads a symbolic value (e.g., λ) and assigns it to y.

The program would then proceed with the multiplication and assign λ * 2 to z. When reaching the if statement, it would evaluate λ * 2 == 12. 

At this point of the program, λ could take any value, and symbolic execution can therefore proceed along both branches, by "forking" two paths. 

Each path get assigned a copy of the program state at the branch instruction as well as a path constraint.

When paths terminate (e.g., as a result of executing fail() or simply exiting), symbolic execution computes a concrete value for λ by solving the accumulated path constraints on each path.
# Limitations

## Path Explosion

Symbolically executing all feasible program paths does not scale to large programs.

## Program-Dependent Efficacy

Symbolic execution is used to reason about a program path-by-path which is an advantage over reasoning about a program input-by-input as other testing paradigms use (e.g. Dynamic program analysis). 

However, if few inputs take the same path through the program, there is little savings over testing each of the inputs separately.

## Environment Interactions

Programs interact with their environment by performing system calls, receiving signals, etc. 
Consistency problems may arise when execution reaches components that are not under control of the symbolic execution tool (e.g., kernel or libraries). 

```c
int main()
 {
   FILE *fp = fopen("doc.txt");
   ...
   if (condition) {
     fputs("some data", fp);
   } else {
     fputs("some other data", fp);
   }
   ...
   data = fgets(..., fp);
 }
```
This program opens a file and, based on some condition, writes different kind of data to the file. It then later reads back the written data. In theory, symbolic execution would fork two paths at line 5 and each path from there on would have its own copy of the file. The statement at line 11 would therefore return data that is consistent with the value of "condition" at line 5. In practice, file operations are implemented as system calls in the kernel, and are outside the control of the symbolic execution tool. The main approaches to address this challenge are:

Executing calls to the environment directly. The advantage of this approach is that it is simple to implement. The disadvantage is that the side effects of such calls will clobber all states managed by the symbolic execution engine. In the example above, the instruction at line 11 would return "some datasome other data" or "some other datasomedata" depending on the sequential ordering of the states.

Modeling the environment. In this case, the engine instruments the system calls with a model that simulates their effects and that keeps all the side effects in per-state storage. The advantage is that one would get correct results when symbolically executing programs that interact with the environment. The disadvantage is that one needs to implement and maintain many potentially complex models of system calls. Tools such as KLEE[5] and Cloud9 take this approach by implementing models for file system operations, sockets, IPC, etc.

Forking the entire system state. Symbolic execution tools based on virtual machines solve the environment problem by forking the entire VM state. For example, in S2E[6] each state is an independent VM snapshot that can be executed separately. This approach alleviates the need for writing and maintaining complex models and allows virtually any program binary to be executed symbolically. However, it has higher memory usage overheads (VM snapshots may be large).

# Tools
| Tool   | It can analyze Arch/Lang                         | url                         |
| ------ | ------------------------------------------------ | --------------------------- |
| KLEE   | LLVM                                             | http://klee.github.io/      |
| S2E	 | x86, x86-64, ARM / User and kernel-mode binaries	| http://s2e.epfl.ch          |
| Triton | x86 and x86-64                                   | http://triton.quarkslab.com |
| angr   | libVEX based                                     | http://angr.io/             |

# Reference
- https://en.wikipedia.org/wiki/Symbolic_execution
- http://www.tutorialspoint.com/software_testing_dictionary/symbolic_execution.htm
