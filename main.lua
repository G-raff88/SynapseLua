package.path = package.path .. ";../?.lua"

function love.load()
    world = require("world").new(800, 600)
    creature1 = require("logic.creatures.types.2nd").new()
    creature2 = require("logic.creatures.types.food").new()
    creature1.pos = {x = 420, y = 304}
    table.insert(world.creatures, creature1)
    table.insert(world.creatures, creature2)
end

function love.update(dt)
    --creature1.brain:set_input(2, math.sin(love.timer.getTime()))
    --creature2.brain:set_input(1, math.sin(love.timer.getTime()))
    world:update(dt, world, dt)
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.15)
    world:draw()
    creature2.brain:draw(love.timer.getDelta(), 60, 30)
    print(creature1.energy)
end