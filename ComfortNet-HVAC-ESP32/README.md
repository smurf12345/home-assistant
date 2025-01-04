This is my attempt to monitor communications via RS-485 diagnostic port on the HVAC control board.
Using ESP32 and RS-485 module in ESPHome
HVAC is an Amana Furnace and Air Conditioner
ComfortNet based on ClimateTalk Protocol???

<img width="266" alt="image" src="https://github.com/user-attachments/assets/ef66fe05-1f4d-4fe6-9080-49eb7095480d" />
<img width="305" alt="image" src="https://github.com/user-attachments/assets/e8651bda-ce90-4292-b07b-041580b8f383" />

Decoded Commands so far:
 - Fan Demand Percentage 25.0%
 - Fan Mode 0.0
 - Fan On/Off Rate 200.0
 - Cool Demand Percentage 100.0%
 - Heat Demand Percentage 50.0%
 - Humidification Demand 40.0%

Much of the information gather on the procotol and decoding were gain from the below repos:
 - ClimateTalk Specs: https://github.com/rrmayer/climate-talk-web-api
 - ClimateTalk Python: https://github.com/kdschlosser/ClimateTalk
 - Net845: https://github.com/kpishere/Net485

Inspired by the Econet project: https://github.com/esphome-econet/

```
Diagnostic port on control board pinout.  A and B are for data communication, and G is ground. Only using A and B for now,
but potentially could be powered from the control board itself as I was measuring 5v on 1 of the pins

    6P4C RJ11/RJ12 male connector end view   
    
              +---------+
            1 ---       |
   (unused) 2 ---       +--+ 
        B   3 ---          |     
        A   4 ---          |        
       GND  5 ---       +--+
            6 ---       |
              +---------+
```
![ComfortNet-HVAC-ESP32](https://github.com/user-attachments/assets/815e37de-b993-4419-ac75-21c3e48f759e)

