
local resizeKeybindings = {
   { 'h', 'half', {'ctrl', 'alt'} },
   { '1', 'half', {'ctrl', 'alt'} },
   { '2', 'forth', {'ctrl', 'alt'} },
   { '3', 'three_forth', {'ctrl', 'alt'} },
   { '4', 'third', {'ctrl', 'alt'} },
   { '5', 'two_third', {'ctrl', 'alt'} },
   { 'h', 'half', {'ctrl', 'alt', 'shift'} },
   { '1', 'half', {'ctrl', 'alt', 'shift'}  },
   { '2', 'forth', {'ctrl', 'alt', 'shift'}  },
   { '3', 'three_forth', {'ctrl', 'alt', 'shift'}  },
   { '4', 'third', {'ctrl', 'alt', 'shift'}  },
   { '5', 'two_third', {'ctrl', 'alt', 'shift'}  }
}

local sizes = {
   forth       = 0.25,
   third       = 0.3333333334,
   half        = 0.50,
   two_third   = 0.6666666666,
   three_forth = 0.75,
   full        = 1.00
}

local sizeKeys = {}
for key, value in pairs(sizes) do
   table.insert( sizeKeys, key )
end

local positions = {
   top    = { nil, 0.00 },
   bottom = { nil, 1.00 },
   left   = { 0.00, nil },
   right  = { 1.00, nil },
}


--- Helper ---

local function round(x, places)
   local places = places or 0
   local x = x * 10^places
   return (x + 0.5 - (x + 0.5) % 1) / 10^places
end
local function currentWindowRect( win )
   local places = 10
   local ur, r = win:screen():toUnitRect(win:frame()), round
   return {r(ur.x,places), r(ur.y,places), r(ur.w,places), r(ur.h,places)} -- an hs.geometry.unitrect table
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
      winRect[2],
      sizes[size],
      1.00
   }

   moveToRect[1] = filterRectSize(moveToRect, 1)

   if ( vertical_half ) then
      moveToRect[4] = 0.5
      moveToRect[2] = filterRectSize(moveToRect, 2)
   end

   win:move( moveToRect )
end

local function filterRectPosition( rect, index, position )
   if nil ~= position[index] then
      if 1.00 == position[index] then
         return 1.00 - rect[index + 2]
      else
        return 0.00
      end
   end
   return rect[index]
end

local function getNextSize( width )
   local index = 1
   for key, size in pairs(sizes) do
      if width == size then
         if sizeKeys[ index + 1 ] then 
            return sizeKeys[ index + 1 ] 
         else
            return sizeKeys[ 1 ] 
         end
      elseif width < size then
         return key
      end
      index = index + s1
   end
   ---return 'half'
end

local function moveCurrentWindow( position )
   local win = hs.window.focusedWindow()
   if not win then return end

   local winRect = currentWindowRect(win)

   if not positions[position] then return end

   local position = positions[position]
   local moveToRect = winRect

   moveToRect[1] = filterRectPosition( moveToRect, 1, position )
   moveToRect[2] = filterRectPosition( moveToRect, 2, position )

   -- if nil ~= position[1] and winRect[1] == moveToRect[1] then
   --    local nextSize = getNextSize( winRect[3] )
   --    hs.alert.show(nextSize)
   --    resizeCurrentWindow( nextSize )
   -- end
   -- if nil ~= position[2] and winRect[2] == moveToRect[2] then
   --    hs.alert.show('resize v')
   -- end

   win:move( moveToRect )
end

local function fullCurrentWindow()
   local win = hs.window.focusedWindow()
   if not win then return end

   local winRect = currentWindowRect(win)

   win:move( { 0, 0, 1, 1 } )
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


hs.hotkey.bind({'ctrl', 'alt'}, 'left', function()
   moveCurrentWindow( 'left' )
end)
hs.hotkey.bind({'ctrl', 'alt'}, 'right', function()
   moveCurrentWindow( 'right' )
end)
hs.hotkey.bind({'ctrl', 'alt'}, 'up', function()
   moveCurrentWindow( 'top' )
end)
hs.hotkey.bind({'ctrl', 'alt'}, 'down', function()
   moveCurrentWindow( 'bottom' )
end)



hs.hotkey.bind({'ctrl', 'alt'}, 'f', fullCurrentWindow)
hs.hotkey.bind({'ctrl', 'alt'}, 'c', centerCurrentWindow)