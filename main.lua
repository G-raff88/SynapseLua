package.path = package.path .. ";../?.lua"

function love.load()
    world = require("world").new(800, 600)
    creature1 = require("logic.creatures.types.1st").new()
    creature2 = require("logic.creatures.types.1st").new()
    creature1.pos = {x = 400, y = 300}
    table.insert(world.creatures, creature1)
    table.insert(world.creatures, creature2)
end

function love.update(dt)
    creature1.brain:set_input(1, math.sin(love.timer.getTime()))
    creature2.brain:set_input(1, math.sin(love.timer.getTime()))
    world:update(dt)
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.15)
    world:draw()
    creature1.brain:draw(love.timer.getDelta(), 60, 30)
end