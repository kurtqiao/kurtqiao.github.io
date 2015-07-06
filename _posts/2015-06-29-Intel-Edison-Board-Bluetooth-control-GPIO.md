--- 
layout: post
title:  "Intel Edison Board Bluetooth control GPIO"
date:   2015-06-29 14:14:53
categories: IoT
--- 

###Introduce  
Got a chance to play intel edison board recently, have some fun and made a little andriod app to control a GPIO LED through bluetooth. i'm not going to introduce basic knowledge about intel edison, everything how to set up your edison board can be found in [Intel Edison Development Board Getting Started Guide](http://maker.intel.com). In this tutorial, i'm going to talk about how to configure edison GPIO pin to light on/off LED, and stick to #IoT spirit, we will try to control by an andriod application.   

<img src="\images\2015\06\edison_bt_gpio_led.jpg" style="width: 300px;">

###Prepare
1. assume you already follow the [Intel Edison getting started guide][startedgdLnk] and setting up a serial terminal, on windows os for this tutorial.  
2. for making andriod app, download [andriod SDK][andriodsdkLnk]  

###Edison Board GPIO Control
As we know, GPIO pin offen offer multi-funtion abilities, [emutexlabs][emutexlabsLnk] make a great example of how to setup GPIO as input or output. you can also refer to [Intel Edison Kit for Arduino][edisonarduinohgLnk] chapter 2 and chapter 11. check [GPIO on Edison][edisongpioLnk] to have some ideas why need to control by this way. i just list two examples as below, be aware of that you may operate this by connect your edison through putty.exe, as serial terminal.       

####Setting Arduino Expansion Board Pin8 as GPIO Output  

>1- plug in LED in Pin8(J2B1) and GND  

<img src="\images\2015\06\edison_gpio_pin8.jpg" style="width: 300px;">

>2- setting pin8 as GPIO output by script, write and run gpio8.sh as below:  

<pre class="prettyPrint">
#!/bin/sh

echo 49 > /sys/class/gpio/export
echo 214 > /sys/class/gpio/export
echo 256 > /sys/class/gpio/export

echo low > /sys/class/gpio/gpio214/direction
echo high > /sys/class/gpio/gpio256/direction
echo out > /sys/class/gpio/gpio49/direction
echo high > /sys/class/gpio/gpio214/direction 
</pre>

to test if pin8 setting work, you can simply write 1 to gpio49 value to light on LED. write 0 to light off.  

<pre>
root@edison:~# echo 1 > /sys/class/gpio/gpio49/value
</pre>

>3- how this work  

check Intel Edison kit for Arduino Hardware Guide, chapter2.2 table3.  
notice that setting Pin8 releated with linux GPIO 49, 256, 214. as an output pin, don't care about 224 pullup enable.  
<img src="\images\2015\06\edison_gpio_table.jpg" style="width: 600px;">

**Note: Before setting up any muxing, set pin 214 (TRI_STATE_ALL) to HIGH, make all of your changes, then set pin 214 to LOW.**	  

####Setting Arduino Expansion Board Pin10 as GPIO Output  
This is another example to setting a multi function pin as GPIO output, to show you how to set SoC pin modes.  

>1- plug in LED in Pin~10(J2B1) and GND  
>2- setting pin~10 as GPIO output by script, source as below:  

<pre>
#!/bin/sh

echo 41 > /sys/class/gpio/export
echo 258 > /sys/class/gpio/export
echo 226 > /sys/class/gpio/export
echo 240 > /sys/class/gpio/export
echo 263 > /sys/class/gpio/export
echo 214 > /sys/class/gpio/export

echo low > /sys/class/gpio/gpio214/direction
echo high > /sys/class/gpio/gpio263/direction
echo low > /sys/class/gpio/gpio240/direction

echo mode0 > /sys/kernel/debug/gpio_debug_gpio41/current_pinmux

echo high > /sys/class/gpio/gpio258/direction
echo out > /sys/class/gpio/gpio41/direction
echo high > /sys/class/gpio/gpio214/direction 
</pre>

after setting, you can also write 1 to gpio41 to pull high and write 0 to pull low.  
by now, you should know how to manipulate Arduino expansion board GPIO pins, and enjoy to light on/off a LED.  
**Note: default voltage of GPIO pin should be 5V, you can change to 3.3V by jumper J9**  

###Edison Bluetooth Serial Port Profile(SPP)
Intel Edison board integrated wifi and bluetooth, this is a great feature for IoT.  
let's focus on [Intel Edison Bluetooth Guide][edisonbtLnk] chapter6.7 Serial Port Profile(SPP), you can also try chapter3 for bluetooth basic operation.  
To enable Edison bluetooth by below command:  
<pre>rfkill unblock bluetooth</pre>  
Check bluetooth is 'UP RUNNING PSCAN' by
<pre>hciconfig hci0</pre>

If not UP RUNNING PSCAN, run  
<pre>
hciconfig hci0 up  
hciconfig hci0 piscan  
</pre>

now run bluetoothctl and show, you should see below  

<img src="\images\2015\06\edison_bluetoothctl.jpg" style="width: 600px;">

check the UUID section, why there is no Serial Port UUID?  
check Edison bluetooth guide chapter6.7.1 you could find the answer.  
after you download and run **SPP-loopback.py**, you should see below:  

<img src="\images\2015\06\edison_bluetoothctl_spp.jpg" style="width: 600px;">

this took me some times due to i didn't check the spec carefully, i always found bluetooth connected fail before doing this.  
Now, let's add some codes to this python script, help to control GPIO LED when bluetooth send message.  let's said, "light on" to turn on LED light and "light off" to turn off LED light. 
Of course let's use Pin8(GPIO49) to make this simple, and you need to set up this pin as GPIO output as introduced before.    

<pre>
def NewConnection(self, path, fd, properties):
	self.fd = fd.take()
	print("NewConnection(%s, %d)" % (path, self.fd))


	server_sock = socket.fromfd(self.fd, socket.AF_UNIX, socket.SOCK_STREAM)
	server_sock.setblocking(1)
	server_sock.send("This is Edison SPP loopback test\nAll data will be loopback\nPlease start:\n")

	try:
	    while True:
	        data = server_sock.recv(1024)
	        print("received: %s" % data)
                       if (data == "light on"):
                          os.system('echo 1 > /sys/class/gpio/gpio49/value')
                       if (data == "light off"):
                          os.system('echo 0 > /sys/class/gpio/gpio49/value')

		server_sock.send("looping back: %s\n" % data)
	except IOError:
	    pass

	server_sock.close()
	print("all done")
</pre>

###An Andriod Application(AAA)
Believe me you can do this event you didn't write a single line of andriod app before, i just download andriod SDK two days ago.  
Here's a good example: [Serial Over Bluetooth Simple Test Client][btsppandriodLnk]  
You could also check video tutorial from youtube: [Andriod Develop Tutorial Bluetooth][andriodbtLnk]  
The idea simply list as below:  

1. OnCreate,  
   `btAdapter = BluetoothAdapter.getDefaultAdapter()`  
   ensure bluetooth is enable;  
2. OnClick, if click connect button,  
   `btDevice = btAdapter.getRemoteDevice(EDISON_ADDRESS)`,  
   `btSocket = btDevice.createRfcommSocketToServiceRecord(SSP_UUID)`,  
   connect by `btSocket.connect()` and create output stream by  
   `outStream = btSocket.getOutputStream()`    
3. if click Light On button, send 'light on' message by  
   `outStream.write(msgOnBuf)`, if click Light Off button, send 'light off'.  

Now you should able to control Edison board GPIO LED by teamwork of andriod bluetooth client and SPP-loopback.py script run in Edison.  

###My Example  
You can find all the source code including andriod bluetooth client, modified SPP-loopback.py and gpio8.sh from [my bluetest github](https://github.com/kurtqiao/programs/tree/master/andriod/bluetest)  
The tutorial is too brief to understand? 
<pre>
  try {
    Tutorial("Intel Edison Board Bluetooth control GPIO");
  } catch (IOExecption tooBrieftoUnderstand) {
    SendEmail("kurtqiao@gmail.com");
  }
</pre>

###Expansion
Here's a good sample [Intel IoT Edison web controlled LED][webcontrolLnk].  
you can refer to [Intel web controller presentation][webcontrolpstLnk].  
download webcontroller.js from [Intel-academic-IoT-course][webcontrollerjsLnk].  
How to read data from edison? check [sending and receiving data via Bluetooth][btThreadLnk].  

[emutexlabsLnk]:	http://www.emutexlabs.com/project/215-intel-edison-gpio-pin-multiplexing-guide  
[edisonarduinohgLnk]:  http://download.intel.com/support/edison/sb/edisonarduino_hg_331191007.pdf  
[edisongpioLnk]:    http://www.intel-software-academic-program.com/courses/diy/Intel_Academic_-_DIY_-_InternetOfThings/IntelAcademic_IoT-Edison_04_GPIO_on_Edison.pdf  
[startedgdLnk]:    https://software.intel.com/en-us/assembling-intel-edison-board-with-arduino-expansion-board  
[andriodsdkLnk]:  https://developer.android.com/sdk/index.html  
[edisonbtLnk]:   http://download.intel.com/support/edison/sb/edisonbluetooth_331704004.pdf  
[btsppandriodLnk]:    http://www.anddev.org/code-snippets-for-andriod-f33/serial-over-bluetooth-simple-test-client-t11106.html  
[andriodbtLnk]:    https://www.youtube.com/watch?v=OTQHZ16q0Ik&list=PLQrQKDQmvSfxEmYOugNkYLSEs5oLxs5u6  
[webcontrolLnk]:	  http://www.instructables.com/id/Intel-IoT-Edison-web-controlled-LED/?ALLSTEPS  
[webcontrolpstLnk]:    http://www.intel-software-academic-program.com/courses/diy/Intel_Academic_-_DIY_-_InternetOfThings/IntelAcademic_IoT-Edison_06_NodeJS_web_controller.pdf  
[webcontrollerjsLnk]:  https://github.com/guermonprez/intel-academic-IoT-course/tree/master/labs/07_webLed_NodeHTTP  
[btThreadLnk]:    http://www.egr.msu.edu/classes/ece480/capstone/spring14/group01/docs/appnote/Wirsing-SendingAndReceivingDataViaBluetoothWithAnAndroidDevice.pdf  