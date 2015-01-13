---
layout: post
title:  "UEFI Boot Manager"
date:   2015-01-13 23:13:02
categories: UEFI
---  

###UEFI Spec Chapter 3 Boot Manager  
Let's see how uefi spec define boot manager:  

<img src="/images/2015/01/spec_boot_manager.gif" style="width: 700px;">  

So it seems that uefi boot manager can change boot order by modify some uefi variables.  

###What kind of boot variables  
All of these are efi global NVRAM variables.   
<pre>
#define EFI_GLOBAL_VARIABLE\
{0x8BE4DF61,0x93CA,0x11d2,0xAA,0x0D,0x00,0xE0,0x98,0x03,0x2B,0x8C}
</pre>  
the boot manager can determine the load order of uefi driver, but here let's focus on boot option.  
<img src="/images/2015/01/uefi_boot_variables.gif" style="width: 700px;">  

**Boot####**  
Where #### is using digits 0-9, and upper case of characters A-F.  
Load opion entry resides in this variable, so a Boot#### variable structure would be as below:    
<pre>
EFI_LOAD_OPTION
{
UINT32 Attributes;
UINT16 FilePathListLength;
CHAR16 Description[];
EFI_DEVICE_PATH_PROTOCOL FilePathList[];
UINT8 OptionalData[];
}
</pre>  
If a load option attributes is "LOAD_OPTION_ACTIVE", the boot manager will attempt to boot automatically using the device path information in the load option.  

**BootOrder**  
The BootOrder variable contains an array of UINT16’s that make up an ordered list of the Boot#### options. The first element in the array is the value for the first logical boot option, the second element is the value for the second logical boot option, etc. The BootOrder order list is used by the firmware’s boot manager as the default boot order.  
<pre>
BootOrder: 0003,0002,0000,0004
</pre>
**BootNext**  
The BootNext variable is a single UINT16 that defines the Boot#### option that is to be tried first on the next boot. After the BootNext boot option is tried the normal BootOrder list is used.  

**BootCurrent**  
The BootCurrent variable is a single UINT16 that defines the Boot#### option that was selected on the current boot.  

###Boot Mechanism  
The spec descript that EFI can boot from a device using the EFI_SIMPLE_FILE_SYSTEM_PROTOCOL or the EFI_LOAD_FILE_PROTOCOL. Let's check how EDK2 source code process the variables and boot.  
1. Init global variable L"Timeout" from PCD in [[BdsEntry.c:603]][BdsEntry603Lnk]  
2. Check if have L"BootNext", if yes, clear this variable, add it into boot list and set boot current as boot next, notice that now boot next is the first one in boot list. [[BdsEntry.c:157]][BdsEntry157Lnk]  
3. Parse L"BootOrder" to Boot list [[BdsEntry.c:197]][BdsEntry197Lnk], skip if not LOAD_OPTION_ACTIVE [[BdsEntry.c:258]][BdsEntry258Lnk]  
4. Boot via boot option. [[BdsEntry.c:286]][BdsEntry286Lnk], set L"BootCurrent" [[BdsBoot.c:2270]][BdsBoot2270Lnk]. check device path, if BBS_DEVICE_PATH, then it's a legacy boot. [[BdsBoot.c:2314]][BdsBoot2314Lnk]; boot internal shell [BdsBoot.c:2326][BdsBoot2326Lnk]; boot from OS loader [BdsBoot.c:2361][BdsBoot2361Lnk]; if fail, boot from removable device, which is "\EFI\BOOT\boot{machinename}.EFI" [BdsBoot.c:2385][BdsBoot2385Lnk].  

###Variable Services
Now we know that we can modify uefi boot order by modify EFI global variable L"BootOrder", let's have a simple practice.  
UEFI runtime services->variable services provide SetVariable() and GetVariable() functions to manuplate variables, please notice that because of there're vary size of uefi variables, so we generally need to call GetVariable() twice, first call to return the real size of the VariableName, then call it again to return variable data.  
<pre>
typedef
EFI_STATUS
GetVariable (
IN CHAR16 *VariableName,
IN EFI_GUID *VendorGuid,
OUT UINT32 *Attributes OPTIONAL,
IN OUT UINTN *DataSize,
OUT VOID *Data
);

typedef
EFI_STATUS
SetVariable (
IN CHAR16 *VariableName,
IN EFI_GUID *VendorGuid,
IN UINT32 Attributes,
IN UINTN DataSize,
IN VOID *Data
);
</pre>

##Sample 
My bootmgr [sample code][BootmgrSampleLnk] in github, a little app to show boot variables and set first boot by modify BootOrder first Boot#### to be your setting.  

##Refer
[UEFI Boot How does that actually work][1]  
[The EFI System Partition][2]  
[Linux boot with EFI code review][3]


[1]: https://www.happyassassin.net/2014/01/25/uefi-boot-how-does-that-actually-work-then/  
[2]: http://blog.uncooperative.org/blog/2014/02/06/the-efi-system-partition/  
[3]: http://louis.feuvrier.org/boot.html  
[BootmgrSampleLnk]: https://github.com/kurtqiao/MyPkg/tree/master/Application/bootmgr  
[BdsEntry603Lnk]: https://github.com/tianocore/edk2/blob/master/IntelFrameworkModulePkg/Universal/BdsDxe/BdsEntry.c#L603  
[BdsEntry197Lnk]: https://github.com/tianocore/edk2/blob/master/IntelFrameworkModulePkg/Universal/BdsDxe/BdsEntry.c#L197  
[BdsEntry157Lnk]: https://github.com/tianocore/edk2/blob/master/IntelFrameworkModulePkg/Universal/BdsDxe/BdsEntry.c#L157  
[BdsEntry258Lnk]: https://github.com/tianocore/edk2/blob/master/IntelFrameworkModulePkg/Universal/BdsDxe/BdsEntry.c#L258  
[BdsEntry286Lnk]: https://github.com/tianocore/edk2/blob/master/IntelFrameworkModulePkg/Universal/BdsDxe/BdsEntry.c#L286  
[BdsBoot2270Lnk]: https://github.com/tianocore/edk2/blob/master/IntelFrameworkModulePkg/Library/GenericBdsLib/BdsBoot.c#L2270  
[BdsBoot2314Lnk]: https://github.com/tianocore/edk2/blob/master/IntelFrameworkModulePkg/Library/GenericBdsLib/BdsBoot.c#L2314  
[BdsBoot2326Lnk]: https://github.com/tianocore/edk2/blob/master/IntelFrameworkModulePkg/Library/GenericBdsLib/BdsBoot.c#L2326  
[BdsBoot2361Lnk]: https://github.com/tianocore/edk2/blob/master/IntelFrameworkModulePkg/Library/GenericBdsLib/BdsBoot.c#L2361  
[BdsBoot2385Lnk]: https://github.com/tianocore/edk2/blob/master/IntelFrameworkModulePkg/Library/GenericBdsLib/BdsBoot.c#L2385