---
layout: post
title:  "Wait For Event"
date:   2015-01-06 14:28:23
categories: UEFI
---
Have you ever met any utilities, that can refresh to show data dynamically, and exit when press some keys. How can this be done?  
With the help of UEFI boot services WaitForEvent() function, you can achieve this.  

###Prototype  

<pre>
typedef
EFI_STATUS
WaitForEvent (
IN UINTN NumberOfEvents,
IN EFI_EVENT *Event,
OUT UINTN *Index
);
</pre>
This function can wait for multi events or just a time event, or a key event, we will make an example to wait time and key event at the same time.  

###Example

<pre>
EFI_STATUS
Test(
)
{  
    EFI_STATUS         Status;
    EFI_EVENT          TimerEvent;
    EFI_EVENT          WaitList[2];
    EFI_INPUT_KEY      Key;
    UINTN              Index;

    do{
      Print(L"Wait...");

      Status = gBS->CreateEvent (EFI_EVENT_TIMER, 0, NULL, NULL, &TimerEvent);

      //    
      // Set a timer event of 1 second expiration    
      //  
      Status = gBS->SetTimer (TimerEvent, TimerRelative, 10000000);

      //
      // Wait for the keystroke event or the timer    
      //  
      WaitList[0] = gST->ConIn->WaitForKey;  
      WaitList[1] = TimerEvent;  

      Status = gBS->WaitForEvent (2, WaitList, &Index);  
      //    
      // Check for the timer expiration    
      //  
      if (!EFI_ERROR (Status) && Index == 1) {    
        Status = EFI_TIMEOUT;     
      }  
      gBS->CloseEvent (TimerEvent); 
      gST->ConIn->ReadKeyStroke(gST->ConIn, &Key);   
      }while(Status == EFI_TIMEOUT||Key.ScanCode!=SCAN_ESC);    

    Print(L"\nDone!\n");

    return EFI_SUCCESS;
 }
</pre>
This little program will print "Wait..." per second, until press "Esc" key.  
After call WaitForEvent() function, program stop and wait for time event or key event, when detect event, this function return Stauts = EFI_SUCCESS, Index = detected event. Index corresponding to WaitList array index, which 0 for key stroke and 1 for time event.  
So when trigger time event(after 1 second and Index = 1), we set Status to EFI_TIMEOUT to indicate 1 second timeout, the 'do{}while' will loop until press 'Esc' key.  
you can replace print "Wait..." code to be what ever you want, such as read some registers or refresh display.  
The program ran output as below pic:  

<img src="/images/2015/01/wait_for_2events.png" style="width: 600px;">  

