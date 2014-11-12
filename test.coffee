ADC = require "./index"
sensor = new ADC(0x48, 'ADS1115')
for num in [1..10]
  sensor.readADCSingleEnded(0)
  sensor.readADCSingleEnded(1)