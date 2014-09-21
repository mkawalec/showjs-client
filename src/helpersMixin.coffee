chars = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890'

module.exports.helpersMixin =
  get_id: ->
    return _.reduce _.range(15), ((acc) ->
      acc += chars[_.random(0, chars.length-1)]
      acc
    ), ''

  notify: console.log

