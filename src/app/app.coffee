angular.module('tuny', ['utils', 'directives'])

.controller 'TunyCtrl', ($scope, $http, $timeout, arrayUtils, $commands, $settings) ->
  updateSongs = ->
    return unless $scope.originalSongs?

    if $scope.shuffled
      songs = arrayUtils.shuffleArray($scope.originalSongs)

      if $scope.currentSong
        songs.splice(songs.indexOf($scope.currentSong), 1)
        songs.unshift($scope.currentSong)

      $scope.songs = songs
    else
      $scope.songs = $scope.originalSongs.concat()

    return

  loadSongs = (filePath) ->
    $http.get(filePath).success (data) ->
      $settings.set('last-file', filePath)
      $scope.originalSongs = data;
      updateSongs()
    return

  $scope.shuffled = false

  $scope.toggleShuffle = ->
    $scope.setShuffle(!$scope.shuffled)
    return

  $scope.setShuffle = (value) ->
    console.log value
    $scope.shuffled = value
    $settings.set('shuffle-mode', value)
    updateSongs()

    return

  $settings.get('last-file').then(loadSongs)
  $settings.get('shuffle-mode').then($scope.setShuffle)

  $commands.on('openFile', loadSongs)

  return
