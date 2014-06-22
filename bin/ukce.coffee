casper = require('casper').create
  logLevel: 'error'
  pageSettings:
    loadImages: false
    loadPlugins: false

fs = require 'fs'
utils = require 'utils'

nodeModules = "#{fs.workingDirectory}/../ukce/node_modules"

moment = require "#{nodeModules}/moment/moment.js"
_ = require "#{nodeModules}/lodash/dist/lodash.js"

extractResults = ->
  rowNodes = document.querySelectorAll 'table tr'
  rows = Array::slice.call rowNodes, 1
  rows.map (r) ->
    [surname, firstName] = r.childNodes[1].textContent.trim().split(', ')
    firstName: firstName,
    surname: surname,
    route: r.childNodes[3].textContent.trim().toLowerCase()
    number: r.childNodes[5].textContent.trim()
    time: r.childNodes[7].textContent.trim()
    award: r.childNodes[9].textContent.trim().toLowerCase()

results = []

url = casper.cli.get 'url'

casper.start url, ->
  results = @evaluate extractResults

casper.run ->
  routes = _(results)
    .sortBy((a, b) -> moment.duration(a.time) - moment.duration(b.time))
    .groupBy('route')
    .value()
  # utils.dump routes
  standardFastest = routes.standard[0]
  @echo "Standard: Fastest: #{standardFastest.time} " +
    "(#{standardFastest.firstName} #{standardFastest.surname})"
  @exit()
