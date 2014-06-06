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

  put: (str) ->
    $(".jsquest").find("#console").append("<li>#{str}</li>")

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
      TextImpl.put("You find yourself in #{url}")

  windowFunctions:
    admin:
      load: (url) ->
        TextImpl.loadUrl(url)

    help: ->
      TextImpl.put("known top-level functions:\n" + (k for k, v of TextImpl.windowFunctions).join("\n") )
      null
    look: (obj = "area") ->
      if obj == "area"
        TextImpl.put("You find yourself in #{JsQuest.pageSourceUrl}")
        TextImpl.put("You see #{JsQuest.exits.length} exits")
        TextImpl.put("You see... other things")
      if obj == "exits"
        TextImpl.put("you see\n")
        JsQuest.exits.each (exit) ->
          if exit.destination.has(TextImpl.pageDomain)
            winningText = ""
            for size, text of TextImpl.config.exitDescriptions
              if size < exit.size
                winningText = text
          else
            winningText = TextImpl.config.exitDescriptions.crossDomain
          index = JsQuest.exits.indexOf(exit)
          TextImpl.put("#{winningText} (#{index} : #{exit.destination}) \n")
      null

    move: (to = "nowhere") ->
      if to == 'nowhere'
        TextImpl.put("you pace back and forth")
      else
        exit = JsQuest.exits[to]
        exit = (JsQuest.exits.find (e) -> e.destination == to) unless exit?
        if exit?
          url = exit.destination.replace(/http[s]?:\/\//, "")
          TextImpl.loadUrl(url)
        else
          TextImpl.put("you don't know how to go there. Maybe take another look around")
      null

TextImpl.init()

$ ->
  TextImpl.loadUrl("www.github.com")

  $('#load-url').click (e) ->
    url = $("#url-to-load").val().replace("http://", "").replace("https://", "")
    TextImpl.loadUrl(url)

  $('.jsquest').find('#console-input').keypress (e) ->
    if e.keyCode == 13
      e.preventDefault()
      line = $('.jsquest').find('#console-input').val()
      eval line
      $('.jsquest').find('#console-input').val('')

$.ajaxSettings.beforeSend = (xhr, b, c) ->
  xhr.setRequestHeader('X-Requested-With', location.host)
