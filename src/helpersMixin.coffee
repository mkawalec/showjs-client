chars = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890'

module.exports.helpersMixin =
  getId: ->
    return _.reduce _.range(15), ((acc) ->
      acc += chars[_.random(0, chars.length-1)]
      acc
    ), ''

  notify: (msg) ->
    console.log msg

  parseAttr: (str) ->
    split = _.filter str.split(';'), (val) -> val.indexOf(':') != -1
    _.reduce split, ((acc, property_string) ->
      [prop, value] = property_string.split ':'
      acc[prop] = value
      acc
    ), {}

  indicatorPos: ->
    indicator = document.querySelector('.progress span')
    width = @parseAttr(indicator.getAttribute('style'))['width']
    width = parseFloat width
    width / window.innerWidth

