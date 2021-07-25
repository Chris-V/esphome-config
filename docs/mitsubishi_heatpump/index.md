# Mitsubishi controller board
Board: ESP8266 Wemo D1 v2
Heat pump model: MSZ-FE12NA-8

## Libraries
* https://github.com/geoffdavis/esphome-mitsubishiheatpump
* https://github.com/SwiCago/HeatPump

## Connectors
Heat pump: CN105 / DST-PA, 5 pins
Wemo: Dupont, 8 pins

Heat pump pin | Wemo pin
--- | ---
1 12V |
2 GND | 2 GND
3 5V | 1 5V
4 RX | 7 TX
5 TX | 8 RX
