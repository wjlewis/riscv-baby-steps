## Goal

We want to perform a basic context switch between two "processes".
One prints "A" to the console, and the other prints "B".
Each time slice, we should switch to the sleeping process.

From the Ars Technica article [How Linux was born, as told by Linus Torvalds himself](https://arstechnica.com/information-technology/2015/08/how-linux-was-born-as-told-by-linus-torvalds-himself/):

> I was testing the task-switching capabilities, so what I did was I just made
> two processes and made them write to the screen and had a timer that switched
> tasks.
> One process wrote A, the other wrote B, so I saw AAAA BBBB and so on.
> ...
> At some point I just noticed that hey, I almost have this kernel functionality
> because the two original processes that I did to write out A and B, I changed
> those two processes to work like a terminal emulation package.
> You have one process that is reading from the keyboard, and sending to the
> modem, and the other is reading from the modem and sending to the screen.
> I had keyboard drivers because I obviously needed some way to communicate with
> this thing I was writing, and I had driver for text mode VGA and I wrote a
> driver for the serial line so that I could phone up the University and read
> news.
> That was really what I was initially doing, just reading news over a modem.
