TextImpl = 

  config:
    exitDescriptions:
      "crossDomain": "Some kind of glowing portal"
      500:     "A narrow crack that looks like you could squeeze through"
      1000:    "An alley"
      5000:    "A doorway"
      10000:   "A large doorway"
      50000:   "An arch"
      100000:  "A large archway"
      9999999999:  "A massive archway"

  init: ->
    for key, value of TextImpl.windowFunctions
      window[key] = value

  loadUrl: (url) ->
    ourHostname = location.host
    hostname = $('<a>').prop('href', "http://#{url}").prop('hostname')
    TextImpl.pageHostname = hostname
    TextImpl.pageDomain = hostname.split('.')[1..-1].join('.')

    # TODO: replace one of these cors-anywhere type services with our own server
    # $.get "http://www.corsproxy.com/#{url}", (response) ->
    $.get "https://cors-anywhere.herokuapp.com/#{url}", (response) ->
      response = $(response.replace(/<script[\s\S]*?\/script>/gi, ''))
      response.find('a:not([href])').remove()
      $(response).find('a').each ->
        href = $(@).prop('href').replace(ourHostname, hostname)
        $(@).prop('href', "#{href}")
      $("#source-page").html(response)
      JsQuest.pageSourceUrl = url
      JsQuest.parsePage()
      console.log("You find yourself in #{url}")

  windowFunctions:
    help: ->
      console.log("known top-level functions:\n" + (k for k, v of TextImpl.windowFunctions).join("\n") )
      null
    look: (obj = "area") ->
      if obj == "area"
        console.log("you find yourself in #{JsQuest.pageSourceUrl}")
        console.log("you see #{JsQuest.exits.length} exits")
        console.log("you see... other things")
      if obj == "exits"
        console.log("you see\n")
        JsQuest.exits.each (exit) ->
          if exit.destination.has(TextImpl.pageDomain)
            winningText = ""
            for size, text of TextImpl.config.exitDescriptions
              if size < exit.size
                winningText = text
          else
            winningText = TextImpl.config.exitDescriptions.crossDomain
          index = JsQuest.exits.indexOf(exit)
          console.log("#{winningText} (#{index} : #{exit.destination}) \n")
      null

    move: (to = "nowhere") ->
      if to == 'nowhere'
        console.log("you pace back and forth")
      else
        exit = JsQuest.exits[to]
        exit = (JsQuest.exits.find (e) -> e.destination == to) unless exit?
        if exit?
          url = exit.destination.replace(/http[s]?:\/\//, "")
          TextImpl.loadUrl(url)
        else
          console.log("you don't know how to go there. Maybe take another look around")
      null

TextImpl.init()

$ ->
  $('#load-url').click (e) ->
    url = $("#url-to-load").val().replace("http://", "")
    TextImpl.loadUrl(url)

$.ajaxSettings.beforeSend = (xhr, b, c) ->
  xhr.setRequestHeader('X-Requested-With', location.host)
