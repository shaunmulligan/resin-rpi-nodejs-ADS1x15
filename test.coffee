ADC = require "./index"
sensor = new ADC(0x48, 'ADS1115')
sensor.readADCSingleEnded()