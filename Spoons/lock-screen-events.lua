
local pow = hs.caffeinate.watcher

local function ok2str(ok)
    if ok then return "ok" else return "fail" end
end

local function on_pow(event)
    local name = "?"
    for key,val in pairs(pow) do
        if event == val then name = key end
    end
    if     event == pow.screensDidWake
        or event == pow.sessionDidBecomeActive
        or event == pow.screensaverDidStop
    then
        log.write("awake!")
        local ok, st, n = os.execute("sh ~/.hammerspoon/scripts/login-actions.sh")
        log.write("unlock_keys " .. ok2str(ok) .. ' ' .. st  .. ' ' .. n)
        return
    end
    if     event == pow.screensDidSleep
        or event == pow.systemWillSleep
        or event == pow.systemWillPowerOff
        or event == pow.sessionDidResignActive
        or event == pow.screensDidLock
    then
        log.write("sleeping...")
        local ok, st, n = os.execute("sh ~/.hammerspoon/scripts/logout-actions.sh")
        log.write("lock_keys " .. ok2str(ok) .. ' ' .. st  .. ' ' .. n)
        return
    end
end

pow.new(on_pow):start()
