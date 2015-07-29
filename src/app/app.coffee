fs = require('fs')
remote = require('remote')
app = remote.require('app')
BrowserWindow = remote.require('browser-window')

angular.module('tuny', ['utils', 'directives'])

.controller 'TunyCtrl', ($scope, $http, $timeout, arrayUtils, $commands, $settings, videoLoader) ->
  _filePath = undefined
  $scope.shuffled = false

  originalSongs = undefined
  $scope.allSongs = []

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

  updateSongs()

  $scope.addSongFromUrlOrId = (urlOrId) ->
    $scope.isAdding = true
    videoLoader.getInfo(urlOrId).then (song) ->
      $scope.isAdding = false
      $scope.allSongs.push(song)
      $scope.songs.push(song)
      $scope.songToAdd = ''
      return

    return

  $scope.$watch('allSongs', (allSongs) ->
    return unless allSongs

    cleanSongs = JSON.parse(JSON.stringify(allSongs)).map ({id, title}) -> {id, title}

    BrowserWindow.getFocusedWindow()?.setDocumentEdited(!(JSON.stringify(cleanSongs) is originalSongs))

  , true)

  setFilePath = (path) ->
    _filePath = path
    $settings.set('last-file', path)
    app.addRecentDocument(path)
    BrowserWindow.getFocusedWindow()?.setRepresentedFilename(path)
    BrowserWindow.getFocusedWindow()?.setTitle(path.replace(/.*\/([^.]+\.json)/, '$1'))
    return

  loadSongs = (path) ->
    return unless path?

    $http.get(path).success (data) ->
      setFilePath(path)

      originalSongs = JSON.stringify(data)
      $scope.allSongs = data
      updateSongs()
    return

  savePlaylist = (newPath) ->
    return unless _filePath or newPath
    cleanSongs = JSON.parse(JSON.stringify($scope.allSongs)).map ({id, title}) -> {id, title}
    fs.writeFile _filePath or newPath, JSON.stringify(cleanSongs, null, 2), (err) ->
      # notify error or success

      if !err
        originalSongs = JSON.stringify($scope.allSongs)
        _filePath = newPath if newPath?
        setFilePath(_filePath)
      else
        console.log err

      return
    return



    return

  $settings.get('last-file').then(loadSongs)
  $settings.get('shuffle-mode').then (value) -> $scope.shuffled = value

  $scope.$watch 'shuffled', (value) ->
    return unless value?
    $settings.set('shuffle-mode', value)
    updateSongs()

  $commands.on('openFile', loadSongs)
  $commands.on('saveFile', savePlaylist)

  return
