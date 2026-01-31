-- [file name]: reproduce.lua
local clone = require("clone")

local Reproduce = {}

function Reproduce.new(neuron_index)
    local muscle = {
        neuron_index = neuron_index or 1
    }
    
    function muscle:update(creature)
        -- ничего не делаем
    end
    
    function muscle:move(creature, world)
        if creature.energy and creature.energy > 20 then
            local signal = 0
            if creature.brain and creature.brain.get_output then
                signal = creature.brain:get_output(self.neuron_index) or 0
            end

            if math.abs(signal) > -0.5 then
                -- Клонируем существо
                print(1)
                local clone_creature = clone(creature)
                
                -- Обновляем позицию
                clone_creature.pos = {
                    x = creature.pos.x + math.random(100),
                    y = creature.pos.y + math.random(100)
                }
                
                -- Делим энергию
                creature.energy = creature.energy / 2
                clone_creature.energy = creature.energy
                
                clone_creature.brain:mutate()
                -- Добавляем в мир
                table.insert(world.creatures, clone_creature)
            end
        end
    end
    
    return muscle
end

return Reproduce