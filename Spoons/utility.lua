-- Launch Finder.

hs.hotkey.bind({'alt'}, 'f', function()
  appName = 'Finder'
  app = hs.application.get( appName )
  if( app:isFrontmost() )
  then
    app:hide()
  else
    app.launchOrFocus( appName )
  end
end)

-- Reload Hammerspoon

hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'R', function()
  hs.reload()
end)