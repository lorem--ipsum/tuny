angular.module('player', [])

.directive 'songPlayer', (videoLoader, $janitor, $commands, $http) ->
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
          delete song.promise
          s.lastPlayed = new Date().getTime()
          return unless song is scope.currentSong
          player.setAttribute('src', song.filePath)
          player.play()
          scope.preloadNext()
          return

        if song.promise
          song.promise.then ->
            delete song.promise
            fn(song)
            return
        else if !song.filePath
          song.promise = videoLoader.load(song.id).then(
            (response) ->
              song.filePath = response[0]
              fn(song)
              return response
            (error) ->
              scope.play(getSongAfter(song))
              return error
          )
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
          $http.get('http://api.icndb.com/jokes/random/10').then ({data}) ->
            joke = (data.value.sort (a, b) -> a.joke.length - b.joke.length)[0].joke
            new Notification(song.title, {body: joke})

          scope.play(song)
        return

      scope.isPlaying = -> return !!scope.currentSong && !player.paused
      scope.$watch scope.isPlaying, (v) -> scope.isPlayingAttr = v

      scope.preloadNext = ->
        nextSong = getSongAfter(scope.currentSong)
        return if nextSong.filePath? or nextSong.promise

        nextSong.preloading = true
        nextSong.promise = videoLoader.load(nextSong.id).then (response) ->
          nextSong.filePath = response[0]
          nextSong.preloading = false
          nextSong.lastPlayed = new Date(new Date().getTime() + scope.currentSong.duration*1000)
          delete nextSong.promise
          return response
        return

      getSongAfter = (song) -> scope.songs[(scope.songs.indexOf(song) + 1)%scope.songs.length]
      getPreviousSong = ->
        index = scope.songs.indexOf(scope.currentSong)
        index or= scope.songs.length
        return scope.songs[index-1]

      scope.next = -> scope.currentSong = getSongAfter(scope.currentSong)

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
