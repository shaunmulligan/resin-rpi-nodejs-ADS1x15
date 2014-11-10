ADC = require "./index"
sensor = new ADC (0x48, ic=ADS1115)
sensor.readADCSingleEnded()