# This is my attempt to monitor communications via RS-485 diagnostic port on the HVAC control board.
# Using ESP32 and RS-485 module in ESPHome
# HVAC is an Amana Furnace and Air Conditioner
# ComfortNet based on ClimateTalk Protocol???
# Decoded Commands so far:
# - Fan Demand Percentage 25.0%
# - Fan Mode 0.0
# - Fan On/Off Rate 200.0
# - Heat Demand Percentage 50.0%
# - Humidification Demand 40.0%

# Much of the information gather on the procotol and decoding were gain from the below repos:
# - ClimateTalk Specs: https://github.com/rrmayer/climate-talk-web-api
# - ClimateTalk Python: https://github.com/kdschlosser/ClimateTalk
# - Net845: https://github.com/kpishere/Net485

# Inspired by the Econet project: https://github.com/esphome-econet/

# Diagnostic port on control board pinout.  A and B are for data communication, and G is ground. Only using A and B for now
#    6P4C RJ11/RJ12 male connector end view   
#    
#              +---------+
#            1 ---       |
#   (unused) 2 ---       +--+ 
#        B   3 ---          |     
#        A   4 ---          |        
#       GND  5 ---       +--+
#            6 ---       |
#              +---------+

