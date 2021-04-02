



### Set up mobilinkd tnc3 to talk with Kubuntu 20.04 laptop:

So the first thing you need to do is pair the TNC via Bluetooth and set up the serial data connection.  The following worked for my. YRMV:

From the command line:

Scan for TNC:

```
hcitool scan
```

This will pop up:

```
Scanning ...
        34:81:F4:38:99:68       TNC3 Mobilinkd
```

Now we have the MAC address, so:

```
bluetoothctl
scan on
pairable on
agent on
pair 34:81:F4:38:99:68
```

Ctrl+D to exit the bluetoothctrl This particular TNC utilizes channel 6 for SPP. For that reason we are going to have to bind the TNC to /dev/rfcomm0 using channel 6:

```
rfcomm bind 0 34:81:F4:38:99:68 6
```

That will get us set up to use the Mobilinkd TNC3 with the laptop. We can test this real quick. a 'tx' and 'rx' folder have already been created in this directory for this purpose. "test-port.sh" is a one line script that uses kissutil to monitor and control the tnc using this command. If you don't have direwolf installed (compiled from source to get the utility we need to use) use the instructions found on the direwolf github:

https://github.com/wb2osz/direwolf

First make sure the dependencies are met:

```
sudo apt-get install git gcc g++ make cmake libasound2-dev libudev-dev
```

Next :

```
cd ~
git clone https://www.github.com/wb2osz/direwolf
cd direwolf
mkdir build && cd build
cmake ..
make -j4
sudo make install
make install-conf
```

Assuming everything went according to plan, direwolf is now compiled and installed.

Then:

```
kissutil -p /dev/rfcomm0 -f tx -o rx
```

Keep that running in one terminal. Open another and create a sample APRS message to send. This message is in the right format to be sent from my handheld to my APRS iGate, but the location in the message is somewhere in the UK I think. It doesn't matter though, because I will not actually be sending it to the iGate. I am tuning the handheld to 145.010 MHz for testing, and setting the power to the lowest setting.

```
echo 'KD2EGT-7>KD2EGT-10,WIDE1-1:=3807.41N/212006.78WbMESSAGE' > tx/msg
```

This command takes the message in quotes, and saves it to a text file named tx/msg. The kissutil command we issued monitors that folder and converts the file to packet data and relays it to the TNC to transmit through the radio. If it works you should see the radio key up, and if you are monitoring 145.010 on another radio you will hear the packet transmission.

So if that works out we now need to integrate our shiny new rfcomm port with the AX.25 stack in linux:

```
sudo nano /etc/ax25/axports
```

This file will set up an /dev/ax* port to use the AX25 protocol natively as a network interface. The Syntax is:

```
Port Name -- Callsign-SSID -- Speed -- Maximum Packet Size -- Window Size -- Description
```

Mine looks like this:

```
1       KD2EGT-7        1200    255     7       TNC3
```

I'm not 100% about the 1200 baud speed, but that is the speed the BBS I am going to run is set to, so I'll keep that for now.

Next we are going to script the bluetooth pairing and port setup (tnc_connect):

```
#!/bin/bash
bluetoothcrtl pair 34:81:F4:38:99:68
sudo rfcomm bind 0 34:81:F4:38:99:68 6
sudo kissattach /dev/rfcomm0 1
echo "The TNC Connection has been Established and Configured"
```

This will script the pairing, bind the rfcomm device, and attach the AX25 port. Once this is configured I can issue an ifconfig command, and at the end see that the AX0 port has been created and configured:

```
$ ifconfig
<Rest of my network interfaces omitted>
4: ax0: <BROADCAST,UP,LOWER_UP> mtu 255 qdisc fq_codel state UNKNOWN group default qlen 10
    link /ax25 96:88:64:8a:8e:a8:0e brd a2:a6:a8:40:40:40:00
```

Now using the port is very simple. Just tune the radio to the frequency you want to use (145.01 MHz in my case), and issue this command to connect to the BBS:

```
axcall 1 KD2EGT-15
```

axcall is the command to transmit out and attempt a connection, 1 is the axport created above, and KD2EGT-15 is the callsign and SSID of my packet BBS! 

Success!!