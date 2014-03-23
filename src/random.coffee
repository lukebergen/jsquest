JsQuest = window.JsQuest || {}
window.JsQuest = JsQuest
JsQuest.Random = {}

JsQuest.Random.seeds = {}

JsQuest.Random._strToInt = (str) ->
    result = 1
    result += c.charCodeAt(0) for c in str
    result % 1000000000000

JsQuest.Random.reseed = ->
  strToInt = JsQuest.Random._strToInt

  domainParts = window.location.hostname.split('.')
  if domainParts[-1] == 'uk'
    domainParts = domainParts[0..-2]

  # 1: full domain e.g. "www.example.com"
  JsQuest.Random.seeds[1] = strToInt(domainParts.join('.'))

  # 0: naked domain e.g. "example.com" (yes, 0 and 1 will often look identical) 
  if domainParts.length > 2
    domainParts = domainParts[1..-1]
  JsQuest.Random.seeds[0] = strToInt(domainParts.join('.'))

  # 2: full url e.g. "http://www.example.com/stuff/?foo=bar"
  JsQuest.Random.seeds[2] = strToInt(window.location.toString())

  # 3: documebt body e.g. "<body><div>lots 'o html</div></body>"
  JsQuest.Random.seeds[3] = strToInt(document.body.innerHTML.replace(/[ \n]/g, ''))

JsQuest.Random.rand = (min, max, consistency = 4) ->
  JsQuest.Random.reseed() unless JsQuest.Random.seeds[1]?

  if typeof consistency == "string"
    num = Math.abs(Math.sin(JsQuest.Random._strToInt(consistency)) * 10000 % 1)
  else if consistency == 4
    num = Math.random()
  else
    num = Math.abs(Math.sin(JsQuest.Random.seeds[consistency]++) * 10000 % 1)
  num * (max - min) + min
