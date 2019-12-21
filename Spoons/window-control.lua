local keybindings = {

}


local sizes = {
   half        = 0.50,
   forth       = 0.25,
   three_forth = 0.75,
   third       = 0.3333333334,
   two_third   = 0.6666666666,
   full        = 1.00
}

local positions = {
   top    = { nil, 0.00 },
   bottom = { nil, 1.00 },
   left   = { 0.00, nil },
   right  = { 1.00, nil },
}

local function round(x, places)
   local places = places or 0
   local x = x * 10^places
   return (x + 0.5 - (x + 0.5) % 1) / 10^places
end
local function current_window_rect(win)
   local places = 10
   local ur, r = win:screen():toUnitRect(win:frame()), round
   return {r(ur.x,places), r(ur.y,places), r(ur.w,places), r(ur.h,places)} -- an hs.geometry.unitrect table
end

local function resizeCurrentWindow( size, vertical_half )
   local win = hs.window.focusedWindow()
   if not win then return end

   if not size then size = 'half' end
   if not vertical_half then vertical_half = false end


   if 'full' == size then
      win:move( {0.00, 0.00, 1.00, 1.00} )
      return
   end
   
   local win_rect = current_window_rect( win )

   if nil == sizes[ size ] then return end

   local move_to_rect = {
      win_rect[1],
      win_rect[2],
      sizes[ size ],
      1.00
   }

   local x2 = move_to_rect[1] + move_to_rect[3]
   if ( x2 > 1.00 ) then
      move_to_rect[1] = move_to_rect[1] + ( 1.00 - x2 )
   end

   if ( vertical_half ) then
      move_to_rect[4] = 0.5
      local y2 = win_rect[2] + 0.5
      if ( y2 > 1.00 ) then
         move_to_rect[2] = move_to_rect[2] + ( 1.00 - y2 )
      end
   end

   win:move( move_to_rect )
end

local function moveCurrentWindow( position )
   local win = hs.window.focusedWindow()
   if not win then return end

   if nil == positions[ position ] then return end

   local win_rect = current_window_rect( win )

   local move_to_rect = win_rect

   if nil ~= positions[ position ][1] then
      if 1.00 == positions[ position ][1] then
         move_to_rect[1] = 1.00 - move_to_rect[3]
      else
         move_to_rect[1] = 0.00
      end
   end

   if nil ~= positions[ position ][2] then
      if 1.00 == positions[ position ][2] then
         move_to_rect[2] = 1.00 - move_to_rect[4]
      else
         move_to_rect[2] = 0.00
      end
   end

   win:move( move_to_rect )
end



function windowEvents( shift )
   local keys = {'ctrl', 'alt'}
   if shift then
      keys[3] = 'shift'
   end

   hs.hotkey.bind(keys, '1', function()
      resizeCurrentWindow( 'half', shift )
   end)
   hs.hotkey.bind(keys, 'h', function()
      resizeCurrentWindow( 'half', shift )
   end)

   hs.hotkey.bind(keys, '2', function()
      resizeCurrentWindow( 'forth', shift )
   end)

   hs.hotkey.bind(keys, '3', function()
      resizeCurrentWindow( 'three_forth', shift )
   end)

   hs.hotkey.bind(keys, '4', function()
      resizeCurrentWindow( 'third', shift )
   end)

   hs.hotkey.bind(keys, '5', function()
      resizeCurrentWindow( 'two_third', shift )
   end)

   hs.hotkey.bind(keys, 'f', function()
      resizeCurrentWindow( 'full', shift )
   end)
end

windowEvents()
windowEvents( true )


hs.hotkey.bind({'ctrl', 'alt'}, 'Left', function()
   moveCurrentWindow( 'left' )
end)
hs.hotkey.bind({'ctrl', 'alt'}, 'Right', function()
   moveCurrentWindow( 'right' )
end)
hs.hotkey.bind({'ctrl', 'alt'}, 'up', function()
   moveCurrentWindow( 'top' )
end)
hs.hotkey.bind({'ctrl', 'alt'}, 'down', function()
   moveCurrentWindow( 'bottom' )
end)