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
  JsQuest.page = $("#source-page")
  # JsQuest.fetchPersistenceData()
  # JsQuest.createEnvironment()
  JsQuest.createExits()
  # JsQuest.createEnemies()
  # JsQuest.createObjects()
  # JsQuest.createNPCs()

JsQuest.createExits = ->
  JsQuest.exits = []
  anchorEls = JsQuest.page.find("a").toArray()
  anchorEls = anchorEls.filter (el) ->
    el.href != ""  &&
    el.href != JsQuest.pageSourceUrl &&
    el.href.indexOf("#") == -1 &&
    el.href.indexOf("javascript:") == -1 &&
    $(el).width() * $(el).height() >= JsQuest.config.minRelevantAnchorSize

  groupedEls = anchorEls.groupBy (el) -> el.href

  for href, occurrences of groupedEls
    averageSize = occurrences.average (el) -> $(el).width() * $(el).height()
    size = occurrences.length * averageSize
    JsQuest.exits.push({destination: href, size: size})

  JsQuest.exits = JsQuest.exits.sortBy (exit) -> exit.size * -1
