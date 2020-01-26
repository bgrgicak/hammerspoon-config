
local pow = hs.caffeinate.watcher

local function ok2str(ok)
    if ok then return "ok" else return "fail" end
end

local function logOsResponse(event, ok, st, n)
    if nil == st then
        st = ''
    end
    if nil == st then
        n = ''
    end
    log.write(event .. ' ' .. ok2str(ok) .. ' ' .. st  .. ' ' .. n)
end

local function onPow(event)
    local name = "?"
    for key,val in pairs(pow) do
        if event == val then name = key end
    end
    if     event == pow.screensDidWake
        or event == pow.sessionDidBecomeActive
        or event == pow.screensaverDidStop
    then
        log.write("Awake!")
        local ok, st, n = os.execute("sh ~/.hammerspoon/scripts/login-actions.sh")
        logOsResponse('logout-events', ok, st, n)
        return
    end
    if     event == pow.screensDidSleep
        or event == pow.systemWillSleep
        or event == pow.systemWillPowerOff
        or event == pow.sessionDidResignActive
        or event == pow.screensDidLock
    then
        log.write("Sleeping...")
        local ok, st, n = os.execute("sh ~/.hammerspoon/scripts/logout-actions.sh")
        logOsResponse('logout-events', ok, st, n)
        return
    end
end

pow.new(onPow):start()
