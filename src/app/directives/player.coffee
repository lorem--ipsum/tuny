angular.module('player', [])

.directive 'songPlayer', (videoLoader, $janitor, $commands) ->
  return {
    replace: true
    scope: {
      songs: '='
      currentSong: '='
      isPlayingAttr: '=isPlaying'
      duration: '=?'
      currentTime: '=?'
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
        $janitor.watch(scope.songs) if songs?
        return

      scope.play = (song) ->
        fn = (s) ->
          s.lastPlayed = new Date().getTime()
          player.setAttribute('src', song.filePath)
          player.play()
          scope.preloadNext()
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
    <div class="song-player">
      <button ng-click="previous()" ng-class="{disabled: !currentSong}"><i class="fa fa-2x fa-fast-backward"></i></button>
      <button ng-click="playPause()"><i class="fa fa-2x" ng-class="{'fa-play': !isPlaying(), 'fa-pause': isPlaying()}"></i></button>
      <button ng-click="next()" ng-class="{disabled: !currentSong}"><i class="fa fa-2x fa-fast-forward"></i></button>
      <audio></audio>
    </div>
    """
  }
