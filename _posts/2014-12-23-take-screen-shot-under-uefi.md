---
layout: post
title:  "Take Screen Shot Under UEFI Shell"
date:   2014-12-23 13:00:04
categories: UEFI
---
How to take screen shot in UEFI shell?  
Basically program steps as below:  
1.  save video frame buffer to get screen pixel bitmap data  
2.  add bmp header to bitmap data, adjust the data to follow bmp spec, save it as bmp file.  

###Save frame buffer

UEFI console support protocol, graphic output protocol have a function Blt() can save frame buffer:

<pre class="prettyPrint">
    //The Blt() function is used to draw the BltBuffer rectangle onto the video screen.
    EFI_GRAPHICS_OUTPUT_PROTOCOL.Blt()
    //save frame buffer by EfiBltVideoToBltBuffer
    typedef enum {
    EfiBltVideoFill,
    EfiBltVideoToBltBuffer,
    EfiBltBufferToVideo,
    EfiBltVideoToVideo,
    EfiGraphicsOutputBltOperationMax
    } EFI_GRAPHICS_OUTPUT_BLT_OPERATION;
    //Blt prototype
    typedef
    EFI_STATUS
    (EFIAPI *EFI_GRAPHICS_OUTPUT_PROTOCOL_BLT) (
    IN EFI_GRAPHICS_OUTPUT_PROTOCOL *This,
    IN OUT EFI_GRAPHICS_OUTPUT_BLT_PIXEL *BltBuffer, OPTIONAL
    IN EFI_GRAPHICS_OUTPUT_BLT_OPERATION BltOperation,
    IN UINTN SourceX,
    IN UINTN SourceY,
    IN UINTN DestinationX,
    IN UINTN DestinationY,
    IN UINTN Width,
    IN UINTN Height,
    IN UINTN Delta OPTIONAL
    );
</pre>

###BMP bitmap

Take 24bit bmp file for an example, the bmp header is 54 bytes(including 14 bytes bitmap file header and 40 bytes bitmap info. header),  google the format of 24bit bmp file for more informations.  
refer to [Tim's UEFI blog][TimUEFIblogLnk], image pixels are organized left-to-right and then top-to-bottom. Each image pixel consists of 32-bits. The first 8-bits in each pixel are the blue (0 = off, 255 = on), the next 8-bits are the green and the next 8-bits are the **RED**.  
<img src="/images/2014/image_pixel.png">

but the bitmap data of bmp file is different: starting in the lower left corner, going from left to right, and then row by row from the bottom to the top of the image.([Wiki][bitmapWikiLnk]).so Do adjust your bitmap pixel data to follow bmp file format before save it as bmp file.  
<img src="/images/2014/bitmapdata.png">

Only in Graphic mode the blt can got video buffer, so you need to switch to graphic mode by use of SetMode() as EfiConsoleControlScreenGraphics. But please aware that setmode() will clear the screen to black.(SetMode will Set the video device into the specified mode and clears the visible portions of the output display to black.)  
  

And you may noticed that ConsoleControl protocol is removed in EDK2, i heard that EDK2 is just the [graphics screen][EDK2GSLnk], but i didn't verify this. 

###Code Sample
[my UEFI Screenshot sample on github][mysssampleLnk]  

###Refer
[Christoph's Projects][ChristophLnk] please refer his [rEFIt project][rEFItLnk]  
[Another sample on github][othersampleLnk]  
[biosengineer blogspot][xiaohuablogLnk]



[TimUEFIblogLnk]: http://uefi.blogspot.com/2010/01/uefi-hii-part-10-images.html
[bitmapWikiLnk]:  http://en.wikipedia.org/wiki/BMP_file_format
[EDK2GSLnk]:      http://feishare.com/efimail/messages/20120413-0156-Re__edk2__How_to_switch_from_GUI_to_text_mode__console_-Andrew_Fish.html
[mysssampleLnk]:  https://github.com/kurtqiao/snapshot
[ChristophLnk]:   http://chrisp.de/en/projects/
[rEFItLnk]:       http://refit.sourceforge.net/
[othersampleLnk]: https://github.com/chengs/UEFI/blob/master/libeg/screen.c
[xiaohuablogLnk]: http://biosengineer.blogspot.com/2011/09/uefi-screenshot-capture-screen.html