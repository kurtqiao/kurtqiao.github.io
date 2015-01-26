--- 
layout: post
title:  "Play Coreboot With AMD SimNow"
date:   2015-01-25 10:31:45
categories: UEFI
--- 
Wanna play coreboot but have no supported physical motherboard? Don't worry! AMD SimNow can help you out!  
The [official website of coreboot][cbsimnLnk] has a tutorial for using AMD SimNow, but it's kind of brief stuff, i'll try to demo here step by step, in windows OS.  

###Goal
Run coreboot on AMD SimNow virtual platform in Windows OS environment.  

###Prepare Environment
I'm use windows OS for this test, so environment as below:  

* OS: Windows8.1 x64, *SimNow not works for 32bit*  
* AMD SimNow v4.6.2 for windows: [->download][simnowLnk]  
* Coreboot v4  
* Coreboot windows build environment: [win-build-env-015.7z][winbdeLnk]  

please notice that the win-build-env included coreboot v4 source code, but it may not be latest one, you can update it by `git pull`, but i got some build error when use default code, so i `git clone http://review.coreboot.org/p/coreboot` and replace this win-build-env coreboot version.   

####Choose SimNow Platform Configuration  
After Check [AMD developer knowledge base][ADKBLnk], SimNow supports platforms with coreboot lists as below:  
 
>  * Cheetah_1p.bsd  
>  * Cheetah_1p_jh.bsd  
>  * Cheetah_2p.bsd  
>  * Family10_1p.bsd  

i've tried `cheetah_*.bsd`, but it takes a long time to boot due to ECC memory supported. So i suggest to use `Family10_1p.bsd`, after open this bsd by `File->Open BSD` in SimNow, you can check devices in menu `View->Show Devices`  

> * AMD-8132 PCI-X controller  
> * AMD-8111 I/O hub  
> * Winbond W83627HF SIO  

####Choose Coreboot Mainboard
Which coreboot mainboard support SimNow Family10_1p.bsd? let's try `coreboot\src\mainboard\amd\serengeti_cheetah_fam10`  
You can found in Kconfig that it supports below list, should works for our chosen Family10_1p board. 
<pre>
 select NORTHBRIDGE_AMD_AMDFAM10
 select SOUTHBRIDGE_AMD_AMD8111
 select SOUTHBRIDGE_AMD_AMD8132
 select SUPERIO_WINBOND_W83627HF
</pre>

####VGA Support
You may found that SimNow system no display without this step, due to lack of onboard VBIOS binary.  if you tried some unsupported VBIOS, you may get below error. check [coreboot VGA_Support website][vgasptLnk] if there's a way to get supported VBIOS.  
<pre>
CBFS: WARNING: 'pci1022,2067.rom' not found.  
CBFS: Could not find file 'pci1022,2067.rom'.  
Option ROM execution disabled for PCI: 01:04.0
</pre>
Luckily, AMD SimNow provided a simulated PCI VGA called **Emerald Graphic Deivce**. Do remember to enable options in coreboot to run VGA option ROMs, coreboot default enable run VGA option roms, so you can leave it as default when setting .config, but if no display, you will need to check these options.    
<pre>
    Chipset  --->
     [*] Setup bridges on path to VGA adapter 
     [*] Run VGA option ROMs
     Option ROM execution type (Native mode)  --->
</pre>

###Build Coreboot ROM for SimNow
please refer to [this website][sbsbuildLnk] for the step-by-step instructions for building a coreboot BIOS in a windows machine.  
my steps as below:  

*1. run go.bat, enter Msys2 coreboot build environment  

*2. setting coreboot options by 
<pre>$ make oldconfig</pre>  

  my configuration as below, others use default settings:  
  
  * select mainboard vendor AMD

<pre>
*  
* Mainboard  
*  
Mainboard vendor  
 5. AMD (VENDOR_AMD) (NEW) 
</pre>
  
  * choose mainboard 'Serengeti Cheetah (Fam10)'

<pre>
Mainboard model  
 10. Serengeti Cheetah (Fam10) (BOARD_AMD_SERENGETI_CHEETAH_FAM10) (NEW)
</pre>

  * choose seabios as a payload, you can also try other payloads, such as FILO which is introduced by the tutorial, but i can not build FILO successful. If you already have a payload ELF, you can select 2 and give the ELF file path.  

<pre>
*  
* Payload  
*  
Add a payload
  2. An ELF executable payload (PAYLOAD_ELF) (NEW)
  4. SeaBIOS (PAYLOAD_SEABIOS) (NEW)
  5. FILO (PAYLOAD_FILO) (NEW)
</pre>

the configuration will be written to `.config` file   

*3. build out coreboot.rom by 
<pre>$ make </pre>
if build success, you can check rom information as below, and coreboot.rom will be in `build` folder
<pre>
coreboot.rom: 1024 kB, bootblocksize 2544, romsize 1048576, offset 0x0
alignment: 64 bytes, architecture: x86

Name                           Offset     Type         Size
cmos_layout.bin                0x0        cmos_layout  1776
fallback/romstage              0x740      stage        75709
fallback/ramstage              0x12f40    stage        70619
fallback/payload               0x24380    payload      56085
config                         0x31f00    raw          4321
revision                       0x33040    raw          700
(empty)                        0x33340    null         836184
    HOSTCC     cbfstool/rmodtool.o
    HOSTCC     cbfstool/rmodule.o
    HOSTCC     cbfstool/rmodtool (link)
</pre>

###Running Coreboot on SimNow
*1. run simnow.exe, and open Family10h_1p.bsd by `File->Open BSD`  
*2. copy `build/coreboot.rom` to `simnow_dir/Images`  

<pre>
$ cp build/coreboot.rom /c/SimNow/images/
</pre>

*3. Open SimNow Device Window by `View->Show Devices`  

<img src="\images\2015\01\simnow\simnow_show_devices.gif">

Double click the `Memory Device` to change bios rom to coreboot, change base address to `fff00000` and size to `32` for 1MB BIOS ROM. notice that if you don't change base address, you will not able to change size.    
<img src="\images\2015\01\simnow\simnow_change_bios_rom.gif" style="width: 500px;">

(Optional)Double click the `AMD 8111 I/O Hub` to add CD-ROM boot image, a windows XP CD-ROM in my case.  
<img src="\images\2015\01\simnow\simnow_odd_iso.gif" style="width: 500px;">

*4. Execute following commmands on 'simnow>' promt to open com port debug, coreboot will throw out debug messages, and then you can get these messages by Putty.exe in windows.
<pre>
1 simnow> serial.SetCommPort pipe
</pre>
<img src="\images\2015\01\simnow\simnow_open_com_pipe.gif">

*5. Start the SimNow simulator by click the `Run Simulation' button on main window  
<img src="\images\2015\01\simnow\simnow_run_simulation.gif">

*6. Run Putty.exe in a new command prompt to capture debug messages, please notice that you must run simulation before this step, or putty will unable to open serial port. command as below, you can make a bat file for this command.  
<pre>
start putty -serial \\.\pipe\SimNow.Com1
</pre>

*7. After a few seconds, run emerald graphic VBIOS and video will appear, notice that `Diagnostic Ports` will show debug numbers on 80 port.  
<img src="\images\2015\01\simnow\simnow_boot_emerald_vbios.gif">

*8. Boot to load Seabios payload, and try to boot CD/DVD.  
<img src="\images\2015\01\simnow\simnow_seabios.gif">

*9. Opps! windows BSOD... need some ACPI debugging or disable ACPI support here.  
<img src="\images\2015\01\simnow\simnow_opps.gif">

###Others
**How to change size of coreboot.rom?**  
the build out rom size is 1MB in this example, you can change to 512KB when setting .config.
<pre>
ROM Chip Size
 4. 512 KB (COREBOOT_ROMSIZE_KB_512) (NEW)
</pre>

**How to re-config coreboot settings?**  
If you want to change some settings in .config file, just re-run `make oldconfig` will not work, you can modify settings in .config, then run `make clean` before `make oldconfig`. But if you delete the `.config` and `.config.old` files, you have to re-config all settings.  

**.config sample file**  
<a href="\images\2015\01\simnow\config.txt" target="_blank">my .config content</a>

**Coreboot post log**  
<a href="\images\2015\01\simnow\putty.log" target="_blank">my putty log</a>

[cbsimnLnk]:  http://www.coreboot.org/AMD_SimNow  
[simnowLnk]:  http://developer.amd.com/tools-and-sdks/cpu-development/simnow-simulator/  
[winbdeLnk]:  http://sourceforge.net/projects/coreboot-tools-for-windows/  
[ADKBLnk]:  http://developer.amd.com/knowledge-base/  
[vgasptLnk]: http://www.coreboot.org/VGA_support  
[sbsbuildLnk]: http://notabs.org/coreboot/corebootWindowsBuild.htm