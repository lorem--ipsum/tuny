fs = require('fs')
remote = require('remote')
app = remote.require('app')
BrowserWindow = remote.require('browser-window')

angular.module('tuny', ['utils', 'directives'])

.controller 'TunyCtrl', ($scope, $http, $timeout, arrayUtils, $commands, $settings, videoLoader) ->
  $scope.shuffled = false

  originalSongs = undefined
  _filePath = undefined

  $scope.addSongFromUrlOrId = (urlOrId) ->
    $scope.isAdding = true
    videoLoader.getInfo(urlOrId).then (song) ->
      $scope.isAdding = false
      $scope.allSongs.push(song)
      $scope.songs.push(song)
      $scope.songToAdd = ''
      return

    return

  updateSongs = ->
    return unless $scope.allSongs?

    if $scope.shuffled
      songs = arrayUtils.shuffleArray($scope.allSongs)

      if $scope.currentSong
        songs.splice(songs.indexOf($scope.currentSong), 1)
        songs.unshift($scope.currentSong)

      $scope.songs = songs
    else
      $scope.songs = $scope.allSongs.concat()

    return

  $scope.$watch('allSongs', (allSongs) ->
    BrowserWindow.getFocusedWindow()?.setDocumentEdited(
      allSongs? and !(JSON.stringify(allSongs) is originalSongs)
    )
  , true)

  loadSongs = (filePath) ->
    $http.get(filePath).success (data) ->
      _filePath = filePath
      $settings.set('last-file', filePath)
      app.addRecentDocument(filePath)
      BrowserWindow.getFocusedWindow()?.setRepresentedFilename(filePath)
      BrowserWindow.getFocusedWindow()?.setTitle(filePath.replace(/.*\/([^.]+\.json)/, '$1'))

      originalSongs = JSON.stringify(data)
      $scope.allSongs = data
      updateSongs()
    return

  savePlaylist = ->
    return unless _filePath
    fs.writeFile _filePath, JSON.stringify($scope.allSongs, null, 2), (err) ->
      # notify error or success

      if !err
        originalSongs = JSON.stringify($scope.allSongs)
        BrowserWindow.getFocusedWindow()?.setDocumentEdited(false)
      else
        console.log err

      return
    return


  $scope.$watch 'shuffled', (value) ->
    $settings.set('shuffle-mode', value)
    updateSongs()

    return

  $settings.get('last-file').then(loadSongs)
  $settings.get('shuffle-mode').then (value) -> $scope.shuffled = value

  $commands.on('openFile', loadSongs)
  $commands.on('saveFile', savePlaylist)

  return
