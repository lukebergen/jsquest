TextImpl = 

  config:
    exitDescriptions:
      500:  "A narrow crack that looks like you could squeeze through"
      1000: "A narrow alley"

  init: ->
    for key, value of TextImpl.windowFunctions
      window[key] = value

  windowFunctions:
    help: ->
      console.log("a help message")
    look: (obj = "area") ->
      console.log("examining #{obj}")
    move: (direction = "nowhere") ->
      console.log("moving #{direction}")

TextImpl.init()
