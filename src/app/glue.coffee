fs = require 'fs'

angular.module('glue', [])

.service '$settings', ($q, $timeout) ->
  _settings = undefined
  settingsPath = app.getPath('userData') + '/tuny-settings.json'

  _deferred = $q.defer()
  _initialization = _deferred.promise

  fs.exists settingsPath, (exists) ->
    if exists
      fs.readFile settingsPath, (err, data) ->
        throw err if err?
        _settings = JSON.parse(data)
        _deferred.resolve(_settings)
    else
      _settings = {}
      _deferred.resolve(_settings)

  return {
    set: (key, value) ->
      d = $q.defer()

      _initialization.then ->
        _settings[key] = value

        fs.writeFile settingsPath, JSON.stringify(_settings, null, 2), (err) ->
          throw err if err?
          d.resolve()

      return d.promise

    get: (key) ->
      d = $q.defer()

      _initialization.then (settings) -> d.resolve(settings[key])

      return d.promise
  }

.service '$commands', ->
  callbacks = {}

  return {
    on: (eventType, callback) ->
      callbacks[eventType] = [] unless callbacks[eventType]?
      callbacks[eventType].push(callback)

    trigger: (eventType, options) ->
      console.log(eventType)
      callbacks[eventType]?.forEach (cb) -> cb(options)
  }
