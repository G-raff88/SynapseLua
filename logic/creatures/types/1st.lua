local Creature = {}

function Creature.new()
    
    math.randomseed(os.time())
    local BrainFactory = require("logic.brain.brain")
    local brain = BrainFactory.new(1,2,3,30)
    local CreatureFactory = require("logic.creatures.creature")
    local creature = CreatureFactory.new({x = 300, y = 300}, 0, brain)

    local muscle1 = require("logic.muscles.types.move_forward")
    local muscle2 = require("logic.muscles.types.rotate")
    creature.muscles[#creature.muscles+1] = muscle1.new({1}, 10)
    creature.muscles[#creature.muscles+1] = muscle2.new({2}, 0.1)

    return creature
end

return Creature