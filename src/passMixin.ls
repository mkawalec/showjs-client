# Decorator that only continues if localStorage is available
has-store = (fn) -> -> if local-storage? then fn ...

# A timeout of 24 hours
timeout = 24 * 60 * 60 * 1000

module.exports.pass-mixin =
  save-pass: has-store ->
    local-storage.masterpass = JSON.stringify {pass: pass, time: +new Date}

  clearPass: has-store ->
    delete local-storage.masterpass

  get-pass: has-store ->
    if not local-storage.masterpass?
      false
    else
      masterpass = JSON.parse local-storage.masterpass
      if +new Date - masterpass.time > timeout
        false
      else
        masterpass.pass
