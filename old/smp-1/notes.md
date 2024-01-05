We'll use `-smp 2` to get 2 harts.

In `gdb` we use `info thread` to examine our CPUs:

```
(gdb) info thread
  Id   Target Id                    Frame
  1    Thread 1.1 (CPU#0 [running]) spin () at main.s:4
* 2    Thread 1.2 (CPU#1 [running]) spin () at main.s:4
```

We can switch to hart 1 using `thread 1`.
Running `info register mhartid` confirms the switch.

How do we step harts independently?
