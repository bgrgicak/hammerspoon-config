local resizeKeybindings = {
   { 'h', 'five', {'ctrl', 'alt'} },
   { '1', 'one', {'ctrl', 'alt'} },
   { '2', 'two', {'ctrl', 'alt'} },
   { '3', 'three', {'ctrl', 'alt'} },
   { '4', 'four', {'ctrl', 'alt'} },
   { '5', 'five', {'ctrl', 'alt'} },
   { '6', 'onePtFive', {'ctrl', 'alt'} },
   { '7', 'twoPtFive', {'ctrl', 'alt'} },
   { '8', 'threePtFive', {'ctrl', 'alt'} },
   { '9', 'fourPtFive', {'ctrl', 'alt'} },
   { 'h', 'five', {'ctrl', 'alt', 'shift'} },
   { '1', 'one', {'ctrl', 'alt', 'shift'} },
   { '2', 'two', {'ctrl', 'alt', 'shift'} },
   { '3', 'three', {'ctrl', 'alt', 'shift'} },
   { '4', 'four', {'ctrl', 'alt', 'shift'} },
   { '5', 'five', {'ctrl', 'alt', 'shift'} },
   { '6', 'onePtFive', {'ctrl', 'alt', 'shift'} },
   { '7', 'twoPtFive', {'ctrl', 'alt', 'shift'} },
   { '8', 'threePtFive', {'ctrl', 'alt', 'shift'} },
   { '9', 'fourPtFive', {'ctrl', 'alt', 'shift'} },
}

local moveKeybindings = {
   { 'left', {'ctrl', 'alt'} },
   { 'right', {'ctrl', 'alt'} },
   { 'up', {'ctrl', 'alt'} },
   { 'down', {'ctrl', 'alt'} },
   { 'left', {'ctrl', 'alt', 'shift'} },
   { 'right', {'ctrl', 'alt', 'shift'} },
}

local sizes = {
   one   = 0.10,
   two   = 0.20,
   three = 0.30,
   four  = 0.40,
   five  = 0.50,
   onePtFive   = 0.15,
   twoPtFive   = 0.25,
   threePtFive = 0.35,
   fourPtFive  = 0.45
}

local positions = {
   up    = { nil, 0.00 },
   down = { nil, 1.00 },
   left   = { 0.00, nil },
   right  = { 1.00, nil },
}

local arrowSizes = { 'one', 'two', 'three', 'four', 'five' }

--- Helper ---

local function round(x, places)
   local places = places or 2
   local x = x * 10^places
   return (x + 0.5 - (x + 0.5) % 1) / 10^places
end
local function currentWindowRect( win )
   local ur, r = win:screen():toUnitRect(win:frame()), round
   return {r(ur.x), r(ur.y), r(ur.w), r(ur.h)} -- an hs.geometry.unitrect table
end

local function filterRectSize( rect, index )
   local size = rect[index] + rect[index + 2]
   if ( size > 1.00 ) then
      return rect[index] + ( 1.00 - size )
   end
   return rect[index]
end

local function resizeCurrentWindow( size, vertical_half )
   local win = hs.window.focusedWindow()
   if not win then return end

   local winRect = currentWindowRect(win)

   if not size then size = 'half' end
   if not vertical_half then vertical_half = false end
   if not sizes[size] then return end

   local moveToRect = {
      winRect[1],
      0.00,
      sizes[size],
      1.00
   }

   moveToRect[1] = filterRectSize(moveToRect, 1)
   if ( vertical_half ) then
      moveToRect[4] = 0.5
      moveToRect[2] = filterRectSize(moveToRect, 2)
   end

   log.write( moveToRect[1] ..' ' .. moveToRect[2] ..' ' .. moveToRect[3] ..' ' .. moveToRect[4] )
   win:move( moveToRect )
   
end

local function filterRectPosition( rect, index, position, center )
   local x = rect[index]
   if nil ~= position[index] then
      if center then
         if 1.00 == position[index] then
            x = 0.50
         else
            x = 0.50 - rect[index + 2]
         end
      else
         if 1.00 == position[index] then
            x = 1.00 - rect[index + 2]
         else
            x = 0.00
         end
      end
   end
   return round( x )
end

local function getNextSize( width )
   for index, size in pairs(arrowSizes) do
      nextSize = arrowSizes[ index + 1 ]
      if width >= sizes[ size ] and ( nil == nextSize or width < sizes[ nextSize ] )  then
         if nextSize then 
            return nextSize
         else
            return arrowSizes[ 1 ]
         end
      end
   end
   return arrowSizes[1]
end

local function do_tables_match( a, b )
   return table.concat(a) == table.concat(b)
end

local function moveCurrentWindow( position, center )
   local win = hs.window.focusedWindow()
   if not win then return end

   local winRect = currentWindowRect(win)

   if not positions[position] then return end

   local position = positions[position]

   local x = winRect[1]
   local y = winRect[2]
   winRect[1] = filterRectPosition( winRect, 1, position, center )
   winRect[2] = filterRectPosition( winRect, 2, position, center )

   if nil ~= position[1] and x == winRect[1] then
      local nextSize = getNextSize( round( winRect[3] ) )
      if nextSize then
         winRect[3] = sizes[nextSize]
         winRect[1] = filterRectPosition( winRect, 1, position, center )
      end
   elseif nil ~= position[2] and y == winRect[2] then
      if 1 == winRect[4] then
         winRect[4] = 0.5
         if 0 == position[2] then -- up
            winRect[2] = 0
         else
            winRect[2] = 0.5
         end
      else -- if not full set full
         winRect[2] = 0
         winRect[4] = 1
      end
   end
   
   win:move( winRect )
end

local function fullHeightCurrentWindow()
   local win = hs.window.focusedWindow()
   if not win then return end

   local winRect = currentWindowRect(win)
   winRect[2] = 0
   winRect[4] = 1

   win:move( winRect )
end

local function centerCurrentWindow()
   local win = hs.window.focusedWindow()
   if not win then return end

   local winRect = currentWindowRect(win)

   winRect[1] = (1 - winRect[3]) / 2
   winRect[2] = (1 - winRect[4]) / 2

   win:move( winRect )
end


--- Keybindings ---

for index, keybinding in pairs(resizeKeybindings) do
   hs.hotkey.bind(keybinding[3], keybinding[1], function()
      resizeCurrentWindow( keybinding[2], 'shift' == keybinding[3][3] )
   end)
end

for index, keybinding in pairs(moveKeybindings) do   
   hs.hotkey.bind( keybinding[2], keybinding[1], function()
      moveCurrentWindow( keybinding[1], 'shift' == keybinding[2][3] )
   end)
end


hs.hotkey.bind({'ctrl', 'alt'}, 'f', fullHeightCurrentWindow)
hs.hotkey.bind({'ctrl', 'alt'}, 'c', centerCurrentWindow)