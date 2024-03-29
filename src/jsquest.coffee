JsQuest = window.JsQuest || {}
window.JsQuest = JsQuest

JsQuest.debug =
  logExits: ->
    console.log JsQuest.exits.map((e) ->
      "#{e.size}: #{e.destination}"
    ).join("\n")

JsQuest.config =
    minRelevantAnchorSize: 500,
    geographies: ['castle', 'desert', 'jungle', 'sky', 'cave', 'ice', 'other']

JsQuest.parsePage = ->
  JsQuest.page = $("#source-page")
  # JsQuest.fetchPersistenceData()
  JsQuest.createEnvironment()
  JsQuest.createExits()
  # JsQuest.createEnemies()
  # JsQuest.createObjects()
  # JsQuest.createNPCs()

JsQuest.createEnvironment = ->
  JsQuest.environment = {}
  rand = JsQuest.Random.randInt(0, JsQuest.config.geographies.length - 1, 0)
  JsQuest.environment.geography = JsQuest.config.geographies[rand]

JsQuest.createExits = ->
  JsQuest.exits = []
  anchorEls = JsQuest.page.find("a").toArray()
  anchorEls = anchorEls.filter (el) ->
    el.href != ""  &&
    el.href != JsQuest.pageSourceUrl &&
    el.href.indexOf("#") == -1 &&
    el.href.indexOf("mailto:") == -1 &&
    el.href.indexOf("javascript:") == -1 &&
    $(el).width() * $(el).height() >= JsQuest.config.minRelevantAnchorSize
    # TODO: lots of other links that we want to avoid. Grab the mimi-type and kill any exe/downloadable files, etc...

  groupedEls = anchorEls.groupBy (el) -> el.href

  for href, occurrences of groupedEls
    averageSize = occurrences.average (el) -> $(el).width() * $(el).height()
    size = occurrences.length * averageSize
    JsQuest.exits.push({destination: href, size: size})

  JsQuest.exits = JsQuest.exits.sortBy (exit) -> exit.size * -1
