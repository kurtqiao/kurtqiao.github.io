---
layout: post
title:  "Build UDK2010 in Ubuntu 12.10"
date:   2014-12-23 16:52:52
categories: UEFI
---
UEFI support GCC build, so we can build it under linux system. This post try to show how to build it in Ubuntu12.10(64bit). lastest UDK version by now is UDK2014, it should also work.  

###Prepare
- Install required packages
<pre>sudo apt-get install build-essential git uuid-dev iasl</pre>
- Download UDK2010 unzip to folder such as ~/src/MyWorkSpace  
- Unzip BaseTools(Unix) to this folder  

###GCC47 configuration  
Due to my UDK version don't have GCC47 support, and my Ubuntu12.10 use GCC47, please notice that latest UDK should already fix this, but if you meet upper GCC version lack of support like this, you can refer to this [link][gccsuportLnk] to add support.

###Complie base tools
For MS windows system, prebuilt binaries of the base tools are packaged with the source. In linux, the base tools need to be built first, without this you may meet build FAIL!  
<pre>$make -C BaseTools</pre>  

###Build
- set EDK_TOOLS_PATH and build environment by edksetup.sh, this script will copy template and configuration files to /Conf folder.  
<pre>$. edksetup.sh</pre>  
- build package sample  
<pre>Build -a X64 -p MdeModulePkg\MdeModulePkg.dsc</pre>
After this build success, your files will be in folder “Build\MdeModule\DEBUG_GCC47\X64”

###Set up a Shell Emulator
By use QEMU, a 64bit UEFI shell envrionment can be used to test your UEFI app.  

- install qemu
<pre>$ sudo apt-get install qemu</pre>
- [download bios.bin][biosbinLnk] which include x64 UEFI shell  
- open terminal, switch to folder which contain the bios.bin, and start up qemu by below command.the '-L .' option tells qemu to look for bios.bin in current folder.
<pre>qemu-system-x86_64 -L .</pre>
<img src="/images/2014/qemu_usage.png">  

- notice that the shell emulator don't have any HDD,  you can not run your EFI applications.
<img src="/images/2014/qemu_shell_noFS0.png">  

- create folder as disk, put your uefi app into the folder, load it as fs0: in emulator.below example load folder 'hda1' as hdd, some .efi files are in this folder
<pre>qemu-system-x86_64 -L . -hda fat:hda1</pre>
<img src="/images/2014/enjoy_efi_fs0.png">

- UEFI shell emulator and enjoy yourself  
<img src="/images/2014/enjoy_efi_app.png">  

###Refer
[Ubuntu EDK2 wiki][ubuntuwikiLnk]  
[Ubuntu OVMF wiki][ubuntuwikiovmfLnk]  

[gccsuportLnk]:       http://sourceforge.net/mailarchive/forum.php?thread_name=4FFD3BAD.90904%40redhat.com&forum_name=edk2-devel  
[biosbinLnk]:         http://people.canonical.com/~jk/ovmf/  
[ubuntuwikiLnk]:      https://wiki.ubuntu.com/UEFI/EDK2  
[ubuntuwikiovmfLnk]:  https://wiki.ubuntu.com/UEFI/OVMF
