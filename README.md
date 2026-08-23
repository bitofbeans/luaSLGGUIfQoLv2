# About
I wanted to add a note to read before reading the code, so here it is:

First off, the main file is SLNight.lua, the other ones are mostly irrevelant.

This code is no longer functional at all, since the game devs did a complete remaster. Truthfully, that's for the better. Regardless, what I learned is not lost. (The game is now called Street Life Remastered)

The code quality is not necessarily amazing. The main reason for this is because most of the decisions and writing was made on the fly. Whatever worked first was what stayed since it worked, and my attention shifted to either using what I just wrote, or finding new, cooler stuff. The secondary reason is that I wrote this code long ago, so it's naturally not as good.

As for specific details:

- The mystery arguments in line 135+ are not my fault, but simply a result of weird server code I had to conform to; I made a seperate functions to build the arguments for this reason.
- The 1000 lines of spawn function -- why not use a for loop? In my testing, it literally didn't work unless I wrote it like this. I'm not sure why, but must have something to do with the client sending all the proximity prompt packets virtually at once, which is how it bypassed the cooldown.
- The Crypto Trader code is the least useful, wasn't nearly as efficient as the other methods, and therefore was always pretty unused. Left in because why not
- My favorite function in here is the Car Mod. Not much to say, just fun to make and to use
- The very first vulnerability I found was sending negative money amounts to people using remotes, sending them into irrecoverable debt but giving you essentially infinite money. It was fixed within a day of finding and isn't functional in the GUI
- Second most effective was unfortunately StudioFarm, since it undetectably gave infinte money
