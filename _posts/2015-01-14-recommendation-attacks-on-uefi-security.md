--- 
layout: post
title:  "Recommendation: Attacks On UEFI Security"
date:   2015-01-14 14:47:43
categories: UEFI
--- 
i recently found a great video on youtube, shows how to attack UEFI firmware with theory explained clearly and show how to attack, every BIOSer should take a look in it.  
Link:[http://youtu.be/ths65a9LH6Y][ytLnk]
 
<a href="http://youtu.be/ths65a9LH6Y"> <img src="\images\2015\01\attacks_uefi_youtube.gif" style="width: 600px;"></a>  

###UEFI Vulnerabilities  
As below picture on website [vulnerability notes database][vndLnk], the video shows below three vulnerabilities: [VU#976132][VU1], [VU#766164][VU2] and [VU#533140][VU3].
<img src="\images\2015\01\vulnerability_notes_20150105.gif" style="width: 600px">  

###Speed Racer
*VU#766164*: Intel BIOS locking mechanism contains race condition that enables write protection bypass.  
Intel PCH LPC interface Brdige(D31:F0) BIOS control register(BIOS_CNTL) and Protected Range register provide the ability to prevent firmware modifications. The BIOS_CNTL register contains the BIOS Lock Enable(BLE) and the BIOS Write Enable(BIOSWE) bits. Setting BLE forces a SMI to execute whenever BIOSWE is set. In this way, the SMI handler can evaluate
if the attempt to write action is legitimate, and if not, unset BIOSWE.  
<img src="\images\2015\01\bios_cntl.gif" style="width: 600px">

but when in muti-core processor platform, this mechanism would be a problem. That's because the CPU cores are not all switch into SMM in the same time immediately. If core1 try to enable BIOSWE bit, and cause SMI switch into SMM, in the same time, core2 try to write firmware, it would be a chance to write success before unset BIOSWE by SMI. As white paper descript this attack was verified to succeed on a single core system with hyper threading enabled.  

Intel New PCH introduced a new bit SMM BIOS Write Protect Disable(SMM_BWP) to prevent this condition.  
<img src="\images\2015\01\SMM_BWP.gif" style="width: 600px">  

###Attacking UEFI S3 Boot Script  

VU#976132: Some UEFI systems do not properly secure the EFI S3 Resume Boot Path boot script.  
Let me cut this in short, because i can not explain this better than the original video and the white paper.  

1. S3 boot script save in unprotected memory: ACPI NVS, that make it can be modify by malwares.    
2. S3 boot script have a EFI_BOOT_SCRIPT_DISPATCH_OPCODE, which let script jump to the entry point to execute the arbitrary code.  
3. Althought EDK2 define S3 boot script should be placed in lock box of SMRAM area, it still be found that some functions call into ACPI NVS, that malwares can hook the dispathed functions.  
<img src="\images\2015\01\attack_boot_script.gif" style="width: 600px">  

4. Modify boot script to set TSEG to a new value, that unlock SMRAM for DMA access, which make SMRAM can be modified by DMA.  
<img src="\images\2015\01\attack_tseg.gif" style="width: 500px">  

When things go to SMM, you should know...  

###Refer
The [video][ytLnk]'s really awesome, and Rafal's sense of humar when he said "i command you, rise!".  
you can also follow [Corey](https://twitter.com/coreykal) on twitter. 

[Speed Racer Whitepaper][1]  
[Attack UEFI Boot Script whitepaper][2]  
[Presentation of this video][3]
[Exploiting UEFI boot script table vulnerability][4]

[ytLnk]:  http://youtu.be/ths65a9LH6Y  
[vndLnk]:  http://www.kb.cert.org/vuls/  
[VU1]:  http://www.kb.cert.org/vuls/id/976132  
[VU2]:  http://www.kb.cert.org/vuls/id/766164  
[VU3]:  http://www.kb.cert.org/vuls/id/533140  
[1]: https://frab.cccv.de/system/attachments/2565/original/speed_racer_whitepaper.pdf  
[2]: https://frab.cccv.de/system/attachments/2566/original/venamis_whitepaper.pdf  
[3]: https://frab.cccv.de/system/attachments/2557/original/AttacksOnUEFI_Slides.pdf
[4]:  http://blog.cr4.sh/2015/02/exploiting-uefi-boot-script-table.html