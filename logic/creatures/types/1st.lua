local Creature = {}

function Creature.new()
    
    math.randomseed(os.time())
    local BrainFactory = require("logic.brain.brain")
    local brain = BrainFactory.new(1,4,3,30)
    local CreatureFactory = require("logic.creatures.creature")
    local creature = CreatureFactory.new({x = 300, y = 300}, 0, brain)

    local muscle = require("logic.muscles.types.move_forward")
    creature.muscles[#creature.muscles+1] = muscle.new({1}, 10)


    return creature
end

return Creature