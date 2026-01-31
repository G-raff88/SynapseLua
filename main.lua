package.path = package.path .. ";../?.lua"

Controller = require("controller")

local spawn1 = Controller.withCooldown(1, function()
    creature2 = require("logic.creatures.types.food").new()
    creature2.pos = {x = math.random(1300), y = math.random(1000)}
    table.insert(world.creatures, creature2)
end)
local spawn2 = Controller.withCooldown(1, function()
    creature1 = require("logic.creatures.types.2nd").new()
    creature1.pos = {x = math.random(700), y = math.random()}
    table.insert(world.creatures, creature1)
end)

function love.load()
    love.window.setMode(1024, 768, {
        centered = false,       -- не центрировать
        x = 200,               -- позиция X
        y = 100,               -- позиция Y
        resizable = true,
        minwidth = 640,
        minheight = 480
    })

    world = require("world").new(800, 600)
end

function love.update(dt)
    t = love.timer.getTime()
    world:update(dt, world, dt)

    Controller.onKeyPress("1", spawn1)
    Controller.onKeyPress("2", spawn2)
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.15)
    world:draw()
end