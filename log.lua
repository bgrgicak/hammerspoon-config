local log = {}
local logFile = "debug.log"

local function write( message ) 
    local data = io.open(logFile, "a")
    data:write(message)
    data:write('\n')
    data:flush()
end

log.write = write

return log