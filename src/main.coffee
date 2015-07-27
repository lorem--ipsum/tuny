fs = require('fs')
dialog = require('dialog')
globalShortcut = require('global-shortcut')
rimraf = require('rimraf')
app = require('app')
BrowserWindow = require('browser-window')

require('crash-reporter').start()

mainWindow = null

cache = app.getPath('cache') + '/Tuny/'

cleanUp = ->
  globalShortcut.unregisterAll()
  rimraf(cache, ->)

app.on 'window-all-closed', ->
  cleanUp()
  app.quit()

app.on 'before-quit', -> cleanUp()

app.on 'ready', ->
  mainWindow = new BrowserWindow({width: 600, height: 800, frame: false})
  mainWindow.loadUrl('file://' + __dirname + '/index.html')
  mainWindow.on 'closed', -> mainWindow = null
  return
