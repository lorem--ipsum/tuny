angular.module('tuny', ['player', 'glue', 'tunyShortcuts'])

.service 'utils', ->
  return {
    # Shamelessly stolen from
    # http://stackoverflow.com/questions/6274339/how-can-i-shuffle-an-array-in-javascript
    # and converted to CoffeeScript using http://js2.coffee/
    shuffleArray: (o) ->
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

.controller 'TunyCtrl', ($scope, $http, $timeout, videoLoader, utils, $commands, $settings) ->
  loadSongs = (filePath) ->
    $http.get(filePath).success (data) ->
      $settings.set('last-file', filePath)
      $scope.originalSongs = data;
      $scope.songs = data.concat();
    return

  $settings.get('last-file').then(loadSongs)
  $commands.on('openFile', loadSongs)

  $scope.shuffled = false

  $scope.toggleShuffle = ->
    $scope.shuffled = !$scope.shuffled
    if $scope.shuffled
      utils.shuffleArray($scope.songs)
      if $scope.currentSong
        songs = $scope.songs
        songs.splice(songs.indexOf($scope.currentSong), 1)
        songs.unshift($scope.currentSong)
    else
      $scope.songs = $scope.originalSongs.concat()
