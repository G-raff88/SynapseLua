package.path = package.path .. ";../?.lua"
function love.load()
    creature = require("logic.creatures.types.1st").new()
end

function love.update(dt)
    creature.brain:set_input(1,math.sin(love.timer.getTime()))
    creature.brain:step()

    creature.muscles[1]:update(creature)
    creature.muscles[1]:move(creature)

    creature.rot = love.timer.getTime()
end

function love.draw()
    creature.brain:draw(love.timer.getDelta(), 60, 30) 
    print(creature.brain.neurons[6].activation)
    creature:draw()
end