BrainFactory = require("logic.brain.brain")
local brain = BrainFactory.new(1,2,3,10)



function love.load()
    math.randomseed(os.time())
end

function love.update(dt)
    brain:set_input(3,math.sin(love.timer.getTime()))
    brain:step()
    brain:update(dt)
end

function love.draw()
    brain:draw(love.timer.getDelta(), 40, 100) 
    print(brain.neurons[6].activation)
end