package.path = package.path .. ";../?.lua"

function love.load()
    -- Создаем мир
    world = require("world").new(800, 600)
    
    -- Создаем существо
    creature = require("logic.creatures.types.1st").new()
    creature.pos = {x = 400, y = 300}
    
    -- Добавляем существо в мир
    table.insert(world.creatures, creature)
end

function love.update(dt)
    -- Обновляем входы мозга (синусоида для демонстрации)
    creature.brain:set_input(1, math.sin(love.timer.getTime()))
    
    -- Обновляем мир (он сам обновит существ)
    world:update(dt)
    
    -- Вращение для движения
    creature.rot = love.timer.getTime()
end

function love.draw()
    -- Очищаем экран
    love.graphics.clear(0.1, 0.1, 0.15)
    
    -- Рисуем мир (существ)
    world:draw()
    
    -- Рисуем мозг отдельно
    creature.brain:draw(love.timer.getDelta(), 60, 30)
end