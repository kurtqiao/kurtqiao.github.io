---
layout: post
title:  "GUID Partition Table Disk"
date:   2014-12-31 10:42:00
categories: UEFI
---
About what is GPT and the differences between MBR please check on wikipedia and UEFI spec chapter 5 GUID Partition Table(GPT) Disk Layout for detail.

###What does GPT look like
HDD with GPT layout looks like below picture, the protetive MBR is contained in LBA0 and GPT header is contained in LBA1. Start from LBA2, there's a partition entry array, which is 128 bytes per partition entry, so a 512 bytes LBA could contain 4 partition entries; Max support 128 partition entries will need 32 LBAs, which make LBA34 be the first usable sector on the disk.  

Last LBA of the device is contained the backup GPT header, and between the last usable LBA is backup GPT partition entry array. Software must update the backup GPT before the primary GPT, and keep them as the same.  
 
<img src="/images/2014/gpt/gpt_layout.gif" style="width: 500px;">  

###How to get GPT information
We know GPT header is contained in LBA1, but how can we read this information?  
After google, found something as below:  
<img src="/images/2014/gpt/how_to_handle_gpt.gif" style="width: 600px;">  

Base on this message, got two key words: device path and block IO protocol.  
**Device Path**  
You can consider device path as a strings, contained some device path nodes.  
<img src="/images/2014/device_path_instance.png">  
Example:  
<pre>
PciRoot(0x0)/Pci(0x1F,0x2)/Sata(0x0,0x0,0x0)
PciRoot(0x0)/Pci(0x1F,0x2)/Sata(0x1,0x0,0x0)/HD(1,GPT,3AD2E169-B634-4EE7-9592-FB95EA422E53,\  
0x800,0x2CBA800)
</pre>
The first device path is contained 3 device path nodes, it represents a SATA device.  
And the second device path is contained 4 device path nodes, the last one “HD(1,GPT,...)” is media device path node which is type 4. it represents a partition.  

**Hard Drive Media Device Path**  
if you check the spec, you will find that media device path node can help to detect a partition is MBR or GPT, but can not help to dump GPT header from LBA1.  

| Mnemonic  | Byte Offset  | Byte Length  |  Description  |  
| :-------- | :----------- | :----------- |  :----------- |  
| Type      | 0            | 1            | Type 4 - Media Device Path |  
| Sub-Type  | 1            | 1            | Sub-Type 1 - Hard Drive    |  
| Partition Number | 4     | 4            | starting with entry 1 |  
| Partition Start  | 8       | 8            | start LBA of the partition |  
| Partition Signature | 24  | 16          | diff sign type with diff signature |  
| Partition Format | 40    | 1            | 0x01 = PC-AT legacy MBR, 0x02 = GPT |  
| Signature Type   | 41    | 1            | 0x00 = no disk, 0x01 = MBR, 0x02 = GPT |  


**Block IO Protocol**  
UEFI spec chapter 12 media access protocols, EFI block IO protocol can be used to read HDD blocks.   
<pre>
EFI_BLOCK_IO_PROTOCOL.ReadBlocks()  
typedef  
EFI_STATUS  
(EFIAPI *EFI_BLOCK_READ) (  
IN EFI_BLOCK_IO_PROTOCOL *This,  
IN UINT32 MediaId,  
IN EFI_LBA LBA,  
IN UINTN BufferSize,  
OUT VOID *Buffer  
);  
</pre>  

But block IO protocol can be installed in partition, not just physical mass storage devices.  
So if you try to read LBA by a partition block IO protocol, you would probably get wrong data.  
 
###So What should we do  
1. get all block IO protocol handles;
2. skip if LogicalPartition is true, for we don't need block io protocol for a partition; this step, you can search all device path from block IO protocol, check if contain a media device path node, if true, then skip this block IO protocol;
3. get physical device block IO protocol, then ReadBlocks() for LBA1
4. check GPT signature, if is GPT, you can get all GPT layout data now
5. read LBA0, check if have protetive MBR 

###Example  
[simple example to check GPT app][mygptLnk] 

###Refer  
[UEFI mail about how to handle GPT disk][efimailLnk]  
[Wikipedia: GUI Partition Table][wikigptLnk]  
[UEFI protocol, sample code check GPT][cppLnk]  


[mygptLnk]:    https://github.com/kurtqiao/MyPkg/tree/master/Application/GPT
[efimailLnk]:    http://feishare.com/efimail/messages/20101023-0655-Re__edk2__Need_pointers_on_how_to_handle_GPT_disk_in_EDK2-_Gambhir__Yatin_.html  
[wikigptLnk]:    https://en.wikipedia.org/wiki/GUID_Partition_Table
[cppLnk]:    http://www.cppblog.com/djxzh/archive/2012/03/06/167106.html