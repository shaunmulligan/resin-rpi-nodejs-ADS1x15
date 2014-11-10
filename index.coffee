class Analog2Digital 
    constructor: (@address = 0x48) ->

    talk: ->
        console.log "My i2c address is #{@address}"

module.exports = Analog2Digital