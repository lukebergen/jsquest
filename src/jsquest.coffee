JsQuest = JsQuest || {}
window.JsQuest = JsQuest

JsQuest.debug =
  logExits: ->
    console.log JsQuest.exits.map((e) ->
      "#{e.size}: #{e.destination}"
    ).join("\n")

JsQuest.config =
    minRelevantAnchorSize: 500

JsQuest.parsePage = ->
  # figure out exits.  Anchor tags are exits, the width() * height() of the anchor
  #   will be reflected in the verbiage of the exit (e.g. "a grand archway" vs "a crack 
  #   in the wall that looks like you could squeeze through")
  JsQuest.createExits()

  #
  # generate content.
  #   certain elements will be treated as different kinds of in game objects/npcs/etc...
  #   e.g. <h1>s are large treasure chests or something
  #   <div>s and <span>s are something really common, maybe even used to figure out
  #   random elements like "a vase on a table" and such. A hash of innerHtml() can be used
  #   as and ID and/or a randomness seed such that page changes can subtly change the
  #   look/feel of a room
  #   
  #   Open Question: should things like items/opened chests be phoned home to some central
  #                  server such that players can influence things permanently?
  #   

JsQuest.createExits = ->
  JsQuest.exits ||= []
  anchorEls = $("a").toArray()
  anchorEls = anchorEls.filter (el) ->
    el.href != ""  &&
    el.href != window.location.toString() &&
    el.href.indexOf("#") == -1 &&
    el.href.indexOf("javascript:") == -1 &&
    $(el).width() * $(el).height() >= JsQuest.config.minRelevantAnchorSize

  groupedEls = anchorEls.groupBy (el) -> el.href

  for href, occurrences of groupedEls
    averageSize = occurrences.average (el) -> $(el).width() * $(el).height()
    size = occurrences.length * averageSize
    JsQuest.exits.push({destination: href, size: size})

  JsQuest.exits = JsQuest.exits.sortBy (exit) -> exit.size * -1
