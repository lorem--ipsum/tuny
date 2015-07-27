fs = require 'fs'

angular.module('janitor', [])

.service '$settings', ($q) ->
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

    trigger: (eventType, options) -> callbacks[eventType]?.forEach (cb) -> cb(options)
  }

.service 'arrayUtils', ->
  return {
    # Shamelessly stolen from
    # http://stackoverflow.com/questions/6274339/how-can-i-shuffle-an-array-in-javascript
    # and converted to CoffeeScript using http://js2.coffee/
    shuffleArray: (o) ->
      o = o.concat()
      j = undefined
      x = undefined
      i = o.length
      while i
        j = Math.floor(Math.random() * i)
        x = o[--i]
        o[i] = o[j]
        o[j] = x

      return o;
    }

.service 'timeUtils', ->
  return {
    durationToString: (s) ->
      s  = s || 0

      sec_num = parseInt(s, 10)
      hours   = Math.floor(sec_num / 3600)
      minutes = Math.floor((sec_num - (hours * 3600)) / 60)
      seconds = sec_num - (hours * 3600) - (minutes * 60)

      minutes = "0" + minutes if minutes < 10
      seconds = "0" + seconds if seconds < 10

      string = minutes + ':' + seconds

      if hours > 0
        hours = "0" + hours if hours < 10
        string = hours + ':' + string

      return string
    }

# KNIFE WREEEENCH
.service '$janitor', ($q, $interval) ->
  limit = 5 # files that aren't in the last played 5 are deleted
  delay = 1000*60*15 # 15 minutes old files are deleted
  _promise = undefined

  _makeCleaner = (_items) ->
    return ->
      safeTimezone = new Date().getTime() - delay

      # I know. This could be optimized. Hey, this is not iTunes, okay ?
      # Yeah I know iTunes sucks, too ^^
      _items
        .filter (item) -> !!item.filePath
        .sort (a, b) ->  b.lastPlayed - a.lastPlayed
        .filter (item, index) -> index >= limit || item.lastPlayed < safeTimezone
        .map (item) ->
          fs.unlink item.filePath, (err) -> delete item.filePath unless err?
  return {
    watch: (items) ->
      $interval.cancel(_promise) if _promise?
      _promise = $interval(_makeCleaner(items), 5000)
  }
