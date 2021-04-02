# Some configuration and Setup Notes

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

Ctrl+D to exit the bluetoothctrl interface. Now apparently /dev/rfcomm0 is already bound to the tnc, but as luck would have it it is using Channel 1, and this particular TNC utilizes channel 6 for SPP. For that reason we are going to have to bind the TNC to /dev/rfcomm1 using channel 6:

```
rfcomm bind 1 34:81:F4:38:99:68 6
```

That will get us set up to use the Mobilinkd TNC3 with the laptop. We can test this real quick. a 'tx' and 'rx' folder have already been created in this directory for this purpose. "test-port.sh" is a one line script that uses kissutil to monitor and control the tnc using this command:

```
kissutil -p /dev/rfcomm1 -f tx -o rx
```

Keep that running in one terminal. Open another and create a sample APRS message to send. This message is in the right format to be sent from my handheld to my APRS iGate, but the location in the message is somewhere in the UK I think. It doesn't matter though, because I will not actually be sending it to the iGate. I am tuning the handheld to 145.010 MHz for testing, and setting the power to the lowest setting.

```
echo 'KD2EGT-7>KD2EGT-10,WIDE1-1:=3807.41N/212006.78WbMESSAGE' > tx/msg
```

This command takes the message in quotes, and saves it to a text file named tx/msg. The kissutil command we issued monitors that folder and converts the file to packet data and relays it to the TNC to transmit through the radio. If it works you should see the radio key up, and if you are monitoring 145.010 on another radio you will hear the packet transmission.