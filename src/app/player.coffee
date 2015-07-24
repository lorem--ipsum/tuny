remote = require('remote')
app = remote.require('app')
youtubedl = require('youtube-dl')

angular.module('player', [])

# KNIFE WREEEENCH
.service 'janitor', ($q, $interval) ->
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

.service 'videoLoader', ($q) ->
  return {
    load: (id) ->
      name = $q.defer()
      data = $q.defer()

      tmp = app.getPath('cache') + '/Tuny/'

      loadStuff = ->
        youtubedl.getInfo(
          id
          ['-f 141/171/140', '--restrict-filenames', '--get-filename']
          {}
          (err, info) ->
            if err?
              name.reject(err)
              return

            name.resolve(tmp + info._filename.trim())

            petite = youtubedl(
              id
              ['-f 141/171/140', '--restrict-filenames']
              {cwd: tmp}
              (err, output) -> if error? then data.reject(error) else data.resolve()
            )

            petite
              .pipe(fs.createWriteStream(tmp + info._filename.trim()))
              .on('close', -> data.resolve())
        )
      fs.exists(tmp, (exists) -> if exists then loadStuff() else fs.mkdir(tmp, loadStuff))

      return $q.all([name.promise, data.promise])
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

.directive 'audioBar', (timeUtils) ->
  return {
    replace: true
    scope: {
      duration: '='
      currentTime: '='
    }
    link: (scope, element,attrs) ->
      scope.getLeft = -> (scope.currentTime/scope.duration)*100 + '%'
      scope.labelize = timeUtils.durationToString
      return
    template: """<div class="audio-bar">
      <div class="label">{{labelize(currentTime)}}</div>
      <div class="track-container">
        <div class="track"></div>
        <div class="thumb" ng-style="{left: getLeft()}"></div>
      </div>
      <div class="label">{{labelize(duration)}}</div>
    </div>"""
  }

.directive 'ngAudio', (videoLoader, janitor, $timeout, $commands) ->
  return {
    replace: true
    scope: {
      songs: '='
      currentSong: '='
      isPlayingAttr: '=isPlaying'
    }
    link: (scope, element, attrs) ->
      player = element[0].getElementsByTagName('audio')[0]

      player.addEventListener 'durationchange', (event) ->
        scope.duration = player.duration
        scope.$apply()
        return

      player.addEventListener 'timeupdate', (event) ->
        scope.currentTime = player.currentTime
        scope.$apply()
        return

      player.addEventListener 'ended', (event) ->
        scope.next()
        scope.$apply()
        return

      scope.$watch 'songs', (songs) ->
        janitor.watch(scope.songs) if songs?
        return

      scope.play = (song) ->
        fn = (s) ->
          s.lastPlayed = new Date().getTime()
          player.setAttribute('src', song.filePath)
          player.play()
          return

        if !song.filePath
          song.isLoading = true
          videoLoader.load(song.id).then (response) ->
            song.filePath = response[0]
            song.isLoading = false
            fn(song)
        else
          fn(song)

        return

      scope.playPause = ->
        if scope.isPlaying()
          player.pause()
        else if scope.currentSong
          player.play()
        else
          scope.currentSong = scope.songs[0]
        return

      scope.$watch 'currentSong', (song) ->

        player.pause()
        if song
          new Notification(song.title)

          scope.play(song)
          scope.preloadNext()
        return

      scope.isPlaying = -> return !!scope.currentSong && !player.paused
      scope.$watch scope.isPlaying, (v) -> scope.isPlayingAttr = v

      scope.preloadNext = ->
        nextSong = getNextSong()
        return if nextSong.filePath?

        nextSong.preloading = true
        videoLoader.load(nextSong.id).then (response) ->
          nextSong.filePath = response[0]
          nextSong.preloading = false
          nextSong.lastPlayed = new Date()
          return
        return

      getNextSong = -> scope.songs[(scope.songs.indexOf(scope.currentSong) + 1)%scope.songs.length]
      getPreviousSong = ->
        index = scope.songs.indexOf(scope.currentSong)
        index or= scope.songs.length
        return scope.songs[index-1]

      scope.next = -> scope.currentSong = getNextSong()

      scope.previous = ->
        if player.currentTime < 5
          scope.currentSong = getPreviousSong()
        else
          player.currentTime = 0

        return

      $commands.on('keyboard:play', scope.playPause)
      $commands.on('keyboard:next', scope.next)
      $commands.on('keyboard:previous', scope.previous)

      return
    template: """
    <div class="audio-player">
      <div class="left">
        <audio-bar duration="duration" current-time="currentTime"></audio-bar>
      </div><div class="right">
        <button ng-click="previous()" ng-class="{disabled: !currentSong}"><i class="fa fa-2x fa-fast-backward"></i></button>
        <button ng-click="playPause()"><i class="fa fa-2x" ng-class="{'fa-play': !isPlaying(), 'fa-pause': isPlaying()}"></i></button>
        <button ng-click="next()" ng-class="{disabled: !currentSong}"><i class="fa fa-2x fa-fast-forward"></i></button>
        <audio></audio>
      </div>
    </div>
    """
  }
