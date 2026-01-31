Controller = {}

function Controller.onKeyPress(key, callback)
    if love.keyboard.isDown(key) then
        callback()
    end
end

function Controller.withCooldown(cooldown, func)
    local lastCall = -cooldown  -- гарантируем первый вызов
    
    return function(...)
        local currentTime = love.timer.getTime()  -- или os.clock()
        
        if currentTime - lastCall >= cooldown then
            lastCall = currentTime
            return func(...)
        else
            local timeLeft = cooldown - (currentTime - lastCall)
            -- print(string.format("Кулдаун: %.2f секунд осталось", timeLeft))
            return nil, timeLeft  -- можно вернуть время оставшегося кулдауна
        end
    end
end
--======


return Controller