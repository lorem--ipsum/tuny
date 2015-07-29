remote = require('remote')
Menu = remote.require('menu')
dialog = remote.require('dialog')
BrowserWindow = remote.require('browser-window')

Menu.setApplicationMenu(Menu.buildFromTemplate([
  {
    label: 'Tuny',
    submenu: [
      {label: 'About Tuny', selector: 'orderFrontStandardAboutPanel:'},
      {type: 'separator'},
      {label: 'Hide Tuny', accelerator: 'Command+H', selector: 'hide:'},
      {label: 'Hide Others', accelerator: 'Command+Shift+H', selector: 'hideOtherApplications:'},
      {label: 'Show All', selector: 'unhideAllApplications:'},
      {type: 'separator'},
      {label: 'Quit', accelerator: 'Command+Q', selector: 'terminate:'},
    ]
  },
  {
    label: 'Playlist',
    submenu: [
      {
        label: 'Import',
        accelerator: 'Command+O',
        click: ->
          dialog.showOpenDialog(
            {properties: ['openFile'], filters: [{ name: 'Files', extensions: ['json'] }]}
            (files) ->
              return unless files?.length > 0
              injector = angular.element(document.querySelector('[ng-controller]')).injector()
              injector.get('$commands').trigger('openFile', files[0])
              injector.get('$rootScope').$apply()
          )
      }
      {
        label: 'Save',
        accelerator: 'Command+S',
        click: ->
          fn = (filePath) ->
            injector = angular.element(document.querySelector('[ng-controller]')).injector()
            injector.get('$commands').trigger('saveFile', filePath)
            injector.get('$rootScope').$apply()

          w = BrowserWindow.getFocusedWindow()

          if !!w.getRepresentedFilename()
            fn(undefined)
          else
            dialog.showSaveDialog(w, {defaultPath: '~/playlist.json'}, fn)
      }
    ]
  },
  {
    label: 'Edit',
    submenu: [
      {label: 'Undo', accelerator: 'Command+Z', selector: 'undo:'},
      {label: 'Redo', accelerator: 'Shift+Command+Z', selector: 'redo:'},
      {type: 'separator'},
      {label: 'Cut', accelerator: 'Command+X', selector: 'cut:'},
      {label: 'Copy', accelerator: 'Command+C', selector: 'copy:'},
      {label: 'Paste', accelerator: 'Command+V', selector: 'paste:'},
      {label: 'Select All', accelerator: 'Command+A', selector: 'selectAll:'}
    ]
  },
  {
    label: 'View',
    submenu: [
      {label: 'Reload', accelerator: 'Command+R', click: -> remote.getCurrentWindow().reload() },
      {label: 'Toggle DevTools', accelerator: 'Alt+Command+J', click: -> remote.getCurrentWindow().toggleDevTools() },
    ]
  },
  {
    label: 'Window',
    submenu: [
      {label: 'Minimize', accelerator: 'Command+M', selector: 'performMiniaturize:'},
      {label: 'Close', accelerator: 'Command+W', selector: 'performClose:'},
      {type: 'separator'},
      {label: 'Bring All to Front', selector: 'arrangeInFront:'}
    ]
  }
]))
