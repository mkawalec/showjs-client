hasStore = (fn) ->
  # Decorator that only continues if localStorage is available
  ->
    if localStorage
      fn.apply this, arguments

module.exports.passMixin =
  savePass: hasStore (pass) ->
    localStorage.masterpass = JSON.stringify {pass: pass, time: _.now()}

  clearPass: hasStore ->
    delete localStorage.masterpass

  getPass: hasStore ->
    if not localStorage.masterpass
      return false
    else
      masterpass = JSON.parse localStorage.masterpass
      if _.now() - masterpass.time > 6 * 60 * 60 * 1000
        return false
      else
        return masterpass.pass
