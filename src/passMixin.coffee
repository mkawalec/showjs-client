hasStore = (fn) ->
  # Decorator that only continues if localStorage is available
  ->
    if localStorage
      fn.apply this, arguments

module.exports.passMixin =
  savePass: hasStore (pass) ->
    localStorage.masterpass = pass

  clearPass: hasStore ->
    delete localStorage.masterpass

  getPass: hasStore ->
    localStorage.masterpass
