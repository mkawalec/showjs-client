{map, filter, fold, fold1} = require 'prelude-ls'

chars = 'qwertyuipasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM0123456789'

randchar = ->
  idx = Math.floor(Math.random! * chars.length)
  chars[idx]

module.exports.helpersMixin =

  get-slide-id: (slide) ->
    # Returns the id of the slide
    "#{slide.indexh};#{slide.indexv}"

  # Get the id, random selection of characters
  getId: -> [til 15] |> map randchar |> fold1 (+)

  notify: -> console.log it

  # Parses DOM style attribute
  parseAttr: ->
    it.split ';'
    |> filter (.indexOf(':') != -1)
    |> map (.split ':')
    |> fold (acc, [prop, acc[prop]]) -> acc, {}

  indicatorPos: ->
    indicator = document.querySelector '.progress span'
    indicatorWidth = @parseAttr(indicator.getAttribute 'style').width |> parseFloat

    # Return the indicator width as a proportion of window width
    indicatorWidth / window.innerWidth
