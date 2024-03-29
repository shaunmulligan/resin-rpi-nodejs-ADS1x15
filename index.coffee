#node module includes
wire = require 'i2c'
time = require 'sleep'

class Analog2Digital
  #IC Identifiers
  __IC_ADS1015: 0x00
  __IC_ADS1115: 0x01

  # Pointer Register
  __ADS1015_REG_POINTER_MASK: 0x03
  __ADS1015_REG_POINTER_CONVERT: 0x00
  __ADS1015_REG_POINTER_CONFIG: 0x01
  __ADS1015_REG_POINTER_LOWTHRESH: 0x02
  __ADS1015_REG_POINTER_HITHRESH: 0x03

  # Config Register
  __ADS1015_REG_CONFIG_OS_MASK: 0x8000
  __ADS1015_REG_CONFIG_OS_SINGLE: 0x8000  # Write: Set to start a single-conversion
  __ADS1015_REG_CONFIG_OS_BUSY: 0x0000  # Read: Bit : 0 when conversion is in progress
  __ADS1015_REG_CONFIG_OS_NOTBUSY: 0x8000  # Read: Bit : 1 when device is not performing a conversion

  __ADS1015_REG_CONFIG_MUX_MASK: 0x7000
  __ADS1015_REG_CONFIG_MUX_DIFF_0_1: 0x0000  # Differential P : AIN0, N : AIN1 (default)
  __ADS1015_REG_CONFIG_MUX_DIFF_0_3: 0x1000  # Differential P : AIN0, N : AIN3
  __ADS1015_REG_CONFIG_MUX_DIFF_1_3: 0x2000  # Differential P : AIN1, N : AIN3
  __ADS1015_REG_CONFIG_MUX_DIFF_2_3: 0x3000  # Differential P : AIN2, N : AIN3
  __ADS1015_REG_CONFIG_MUX_SINGLE_0: 0x4000  # Single-ended AIN0
  __ADS1015_REG_CONFIG_MUX_SINGLE_1: 0x5000  # Single-ended AIN1
  __ADS1015_REG_CONFIG_MUX_SINGLE_2: 0x6000  # Single-ended AIN2
  __ADS1015_REG_CONFIG_MUX_SINGLE_3: 0x7000  # Single-ended AIN3

  __ADS1015_REG_CONFIG_PGA_MASK: 0x0E00
  __ADS1015_REG_CONFIG_PGA_6_144V: 0x0000  # +/-6.144V range
  __ADS1015_REG_CONFIG_PGA_4_096V: 0x0200  # +/-4.096V range
  __ADS1015_REG_CONFIG_PGA_2_048V: 0x0400  # +/-2.048V range (default)
  __ADS1015_REG_CONFIG_PGA_1_024V: 0x0600  # +/-1.024V range
  __ADS1015_REG_CONFIG_PGA_0_512V: 0x0800  # +/-0.512V range
  __ADS1015_REG_CONFIG_PGA_0_256V: 0x0A00  # +/-0.256V range

  __ADS1015_REG_CONFIG_MODE_MASK: 0x0100
  __ADS1015_REG_CONFIG_MODE_CONTIN: 0x0000  # Continuous conversion mode
  __ADS1015_REG_CONFIG_MODE_SINGLE: 0x0100  # Power-down single-shot mode (default)
  __ADS1015_REG_CONFIG_DR_MASK: 0x00E0
  __ADS1015_REG_CONFIG_DR_128SPS: 0x0000  # 128 samples per second
  __ADS1015_REG_CONFIG_DR_250SPS: 0x0020  # 250 samples per second
  __ADS1015_REG_CONFIG_DR_490SPS: 0x0040  # 490 samples per second
  __ADS1015_REG_CONFIG_DR_920SPS: 0x0060  # 920 samples per second
  __ADS1015_REG_CONFIG_DR_1600SPS: 0x0080  # 1600 samples per second (default)
  __ADS1015_REG_CONFIG_DR_2400SPS: 0x00A0  # 2400 samples per second
  __ADS1015_REG_CONFIG_DR_3300SPS: 0x00C0  # 3300 samples per second (also 0x00E0)

  __ADS1115_REG_CONFIG_DR_8SPS: 0x0000  # 8 samples per second
  __ADS1115_REG_CONFIG_DR_16SPS: 0x0020  # 16 samples per second
  __ADS1115_REG_CONFIG_DR_32SPS: 0x0040  # 32 samples per second
  __ADS1115_REG_CONFIG_DR_64SPS: 0x0060  # 64 samples per second
  __ADS1115_REG_CONFIG_DR_128SPS: 0x0080  # 128 samples per second
  __ADS1115_REG_CONFIG_DR_250SPS: 0x00A0  # 250 samples per second (default)
  __ADS1115_REG_CONFIG_DR_475SPS: 0x00C0  # 475 samples per second
  __ADS1115_REG_CONFIG_DR_860SPS: 0x00E0  # 860 samples per second

  __ADS1015_REG_CONFIG_CMODE_MASK: 0x0010
  __ADS1015_REG_CONFIG_CMODE_TRAD: 0x0000  # Traditional comparator with hysteresis (default)
  __ADS1015_REG_CONFIG_CMODE_WINDOW: 0x0010  # Window comparator

  __ADS1015_REG_CONFIG_CPOL_MASK: 0x0008
  __ADS1015_REG_CONFIG_CPOL_ACTVLOW: 0x0000  # ALERT/RDY pin is low when active (default)
  __ADS1015_REG_CONFIG_CPOL_ACTVHI: 0x0008  # ALERT/RDY pin is high when active

  __ADS1015_REG_CONFIG_CLAT_MASK: 0x0004  # Determines if ALERT/RDY pin latches once asserted
  __ADS1015_REG_CONFIG_CLAT_NONLAT: 0x0000  # Non-latching comparator (default)
  __ADS1015_REG_CONFIG_CLAT_LATCH: 0x0004  # Latching comparator

  __ADS1015_REG_CONFIG_CQUE_MASK: 0x0003
  __ADS1015_REG_CONFIG_CQUE_1CONV: 0x0000  # Assert ALERT/RDY after one conversions
  __ADS1015_REG_CONFIG_CQUE_2CONV: 0x0001  # Assert ALERT/RDY after two conversions
  __ADS1015_REG_CONFIG_CQUE_4CONV: 0x0002  # Assert ALERT/RDY after four conversions
  __ADS1015_REG_CONFIG_CQUE_NONE: 0x0003  # Disable the comparator and put ALERT/RDY in high state (default)
  constructor: (@address = 0x48, @ic=@__IC_ADS1015, @debug=false) ->
    # Dictionaries with the sampling speed values
    # These simplify and clean the code (avoid the abuse of if/elif/else clauses)
    @spsADS1115 = {
      8:@__ADS1115_REG_CONFIG_DR_8SPS,
      16:@__ADS1115_REG_CONFIG_DR_16SPS,
      32:@__ADS1115_REG_CONFIG_DR_32SPS,
      64:@__ADS1115_REG_CONFIG_DR_64SPS,
      128:@__ADS1115_REG_CONFIG_DR_128SPS,
      250:@__ADS1115_REG_CONFIG_DR_250SPS,
      475:@__ADS1115_REG_CONFIG_DR_475SPS,
      860:@__ADS1115_REG_CONFIG_DR_860SPS
    }
    @spsADS1015 = {
      128:@__ADS1015_REG_CONFIG_DR_128SPS,
      250:@__ADS1015_REG_CONFIG_DR_250SPS,
      490:@__ADS1015_REG_CONFIG_DR_490SPS,
      920:@__ADS1015_REG_CONFIG_DR_920SPS,
      1600:@__ADS1015_REG_CONFIG_DR_1600SPS,
      2400:@__ADS1015_REG_CONFIG_DR_2400SPS,
      3300:@__ADS1015_REG_CONFIG_DR_3300SPS
    }
    # Dictionariy with the programable gains
    @pgaADS1x15 = {
      6144:@__ADS1015_REG_CONFIG_PGA_6_144V,
      4096:@__ADS1015_REG_CONFIG_PGA_4_096V,
      2048:@__ADS1015_REG_CONFIG_PGA_2_048V,
      1024:@__ADS1015_REG_CONFIG_PGA_1_024V,
      512:@__ADS1015_REG_CONFIG_PGA_0_512V,
      256:@__ADS1015_REG_CONFIG_PGA_0_256V
    }
    #set up i2c communication with ADS1115
    console.log('initialise i2c link')
    @i2c = new wire(@address, {device: '/dev/i2c-1', debug:false})
    # Make sure the IC specified is valid
    if ((ic < @__IC_ADS1015) | (ic > @__IC_ADS1115))
      if (@debug)
        print "ADS1x15: Invalid IC specfied: %h" % ic
        return -1
      else
        @ic = ic
      @pga = 6144	#programmable gain set as 6144 initially.

  readADCSingleEnded: (channel=0, pga=6144, sps=250) ->
    ###"Gets a single-ended ADC reading from the specified channel in mV. \
    The sample rate for this mode (single-shot) can be used to lower the noise \
    (low sps) or to lower the power consumption (high sps) by duty cycling, \
    see datasheet page 14 for more info. \
    The pga must be given in mV, see page 13 for the supported values."###
    returnValue = -100
    # With invalid channel return -1
    if channel > 3
      if @debug
        print "ADS1x15: Invalid channel specified: %d" % channel
      return -1

    # Disable comparator, Non-latching, Alert/Rdy active low
    # traditional comparator, single-shot mode
    config = @__ADS1015_REG_CONFIG_CQUE_NONE | \
    @__ADS1015_REG_CONFIG_CLAT_NONLAT  | \
    @__ADS1015_REG_CONFIG_CPOL_ACTVLOW | \
    @__ADS1015_REG_CONFIG_CMODE_TRAD   | \
    @__ADS1015_REG_CONFIG_MODE_SINGLE

    # Set sample per seconds, defaults to 250sps
    # If sps is in the dictionary (defined in init) it returns the value of the constant
    # othewise it returns the value for 250sps. This saves a lot of if/elif/else code!
    if (@ic == @__IC_ADS1015)
      config |= @setDefault(sps, @spsADS1015, @__ADS1015_REG_CONFIG_DR_1600SPS)
    else
      if ( (sps not in @spsADS1115) & @debug)
        print "ADS1x15: Invalid pga specified: %d, using 6144mV" % sps
      config |= @setDefault(sps, @spsADS1115, @__ADS1115_REG_CONFIG_DR_250SPS)

    # Set PGA/voltage range, defaults to +-6.144V
    if ( (pga not in @pgaADS1x15) & @debug)
      print "ADS1x15: Invalid pga specified: %d, using 6144mV" % sps
    config |= @setDefault(pga, @pgaADS1x15, @__ADS1015_REG_CONFIG_PGA_6_144V)
    @pga = pga

    # Set the channel to be converted
    if channel == 3
      config |= @__ADS1015_REG_CONFIG_MUX_SINGLE_3
    else if channel == 2
      config |= @__ADS1015_REG_CONFIG_MUX_SINGLE_2
    else if channel == 1
      config |= @__ADS1015_REG_CONFIG_MUX_SINGLE_1
    else
      config |= @__ADS1015_REG_CONFIG_MUX_SINGLE_0

    # Set 'start single-conversion' bit
    config |= @__ADS1015_REG_CONFIG_OS_SINGLE
    # Write config register to the ADC
    bytes = [(config >> 8) & 0xFF, config & 0xFF]
    console.log 'channel: '+ channel
    @i2c.writeBytes(@__ADS1015_REG_POINTER_CONFIG, bytes, (err) ->
      if(err)
        console.log "error writing config to ADC"
    )

    # Wait for the ADC conversion to complete
    # The minimum delay depends on the sps: delay >= 1/sps
    # We add 0.1ms to be sure
    delay = Math.floor((1.0/sps+0.001)*1000)
    time.usleep(delay*1000)

    done = false
    # Read the conversion results
    @i2c.readBytes(@__ADS1015_REG_POINTER_CONVERT, 2, (err, result) ->
      if (@ic == @__IC_ADS1015)
      	# Shift right 4 bits for the 12-bit ADS1015 and convert to mV
        returnValue = ( ((result[0] << 8) | (result[1] & 0xFF)) >> 4 )*pga/2048.0
        done = true
      else
      # Return a mV value for the ADS1115
      # (Take signed values into account as well)
      val = (result[0] << 8) | (result[1])
      if val > 0x7FFF
        returnValue = (val - 0xFFFF)*pga/32768.0
        done = true
      else
        done = true
        returnValue = ( (result[0] << 8) | (result[1]) )*pga/32768.0)

    while !done
      require('deasync').runLoopOnce();

    return returnValue
	    
  talk: ->
    console.log "My i2c address is #{@address}"

  setDefault: (key, dict, defVal) ->
    if key of dict
      return dict[key]
    else
      return defVal

module.exports = Analog2Digital