ADC = require "./index"
sensor = new ADC(0x48, 'ADS1115')
for num in [1..4]
  console.log sensor.readADCSingleEnded(0, 6144, 250)
  console.log sensor.readADCSingleEnded(1, 6144, 250)