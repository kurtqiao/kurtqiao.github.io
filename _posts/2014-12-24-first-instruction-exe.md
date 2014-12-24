---
layout: post
title:  "First Instrcution Executed"
date:   2014-12-24 18:11:52
categories: UEFI
---
About processor first instruction fetched and executed, lots of blogs and articles already talked about, I also got interesting about this topic.  

As we know, after hardware reset or cold boot, intel CPU will be start operating in real mode, address ability limited to 1MB. But intel x64/ia32 architechtures software developer manual volume 3 chapter 9 shows that the first instruction is located at physical address 0xFFFFFFF0. Why CPU can access such a high 4G-top memory when in real mode?

###Address Translation 
Intel x86 architecture CPU translate a logical address into a linear address to arrive at a physical address. as we can see: base address + offset = linear address.  
<img src="/images/2014/cpu_logicaddr_to_linearaddr.gif" style="width: 400px;">  

In real-address mode, It shifts the segment selector left by 4 bits to form a 20-bit base address.
<img src="/images/2014/real_mode_addressing.gif" style="width: 500px;">  

Every segment register has a "visible" part and a "hidden" part. CPU will auto load hidden part which including the base address.  
<img src="/images/2014/segment_reg_hidden_part.gif" style="width: 500px;">  

###Processor Built-in Self-Test(BIST)
After system power-up, reset or INIT, processor BIST and registers set as below default value: 
<img src="/images/2014/after_cpu_bist.png">

check CS:IP for where to fetch instructions, CS selector is 0xF000, EIP is 0xFFF0, why the first instruction is not at address 0xFFFF0 ?

###First Instruction

<img src="/images/2014/first_instruction_exe.gif">

so we should look for the first instruction by CS hidden Base address and EIP, for IA32 processor:  
0xFFFF0000+0xFFF0 = 0xFFFFFFF0    
after CS register is loaded with a new value, processor start to follow real address mode address translation rule. 

###Refer
[Intel® 64 and IA-32 Architectures Software Developer’s Manual][intelmLnk] Volume 3 Chapter 9  
[Lightseed CSDN blog about first instruction][lsLnk]  
[BIOS engineer blogspot about first instruciton][bebsLnk]  
[programmer-club discussion][pcdsLnk] 

[lsLnk]:      http://blog.csdn.net/lightseed/article/details/4735101  
[bebsLnk]: http://biosengineer.blogspot.com/2007/04/x86-intel-cpu.html  
[pcdsLnk]:  http://www.programmer-club.com.tw/ShowSameTitleN/assembly/5747.html  
[intelmLnk]:  http://www.intel.com/content/www/us/en/architecture-and-technology/64-ia-32-architectures-software-developer-manual-325462.html
