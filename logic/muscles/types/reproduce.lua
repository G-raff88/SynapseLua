-- [file name]: reproduce_simple.lua
local ReproduceSimple = {}

function ReproduceSimple.new(neuron_index)
    local muscle = {
        output_index = neuron_index or 1,
        signal = 0,
        reproduced = false
    }
    
    function muscle:update(creature)
        if creature.brain and creature.brain.get_output then
            self.signal = creature.brain:get_output(self.output_index) or 0
        end
    end
    
    function muscle:move(creature, world)
        -- Простая проверка: если сигнал > 0.9, то размножаемся
        if not self.reproduced and math.abs(self.signal) > -0.9 then
            self:reproduce(creature, world)
            self.reproduced = true
        elseif math.abs(self.signal) <= 0.5 then
            -- Сброс флага, когда сигнал опускается
            self.reproduced = false
        end
    end
    
    function muscle:reproduce(creature, world)
        math.randomseed(os.time())
        -- Проверяем энергию
        if creature.energy < 20 then return end
        
 
        local x = creature.pos.x + math.random(100)
        local y = creature.pos.y + math.random(100)
        
        -- Простое клонирование мозга
        local brain_clone = {}
        if creature.brain then
            brain_clone = self:simple_clone_brain(creature.brain)
        end
        
        -- Создаем клон
        local clone = {
            pos = {x = x, y = y},
            rot = angle,
            brain = brain_clone,
            sensors = {},
            muscles = {},
            energy = creature.energy / 2,
            radius = creature.radius or 10,
            color = math.random(999)
        }
        
        -- Передаем половину энергии
        creature.energy = creature.energy / 2
        
        -- Добавляем в мир
        table.insert(world.creatures, clone)
        
        print("Клон создан! Энергия родителя: " .. creature.energy)
    end
    
    function muscle:simple_clone_brain(brain)
        if not brain then return {} end
        
        local clone = {
            neurons = {},
            synapses = {},
            input_nodes = {},
            output_nodes = {}
        }
        
        -- Простое копирование (можно добавить мутацию)
        for id, neuron in pairs(brain.neurons or {}) do
            clone.neurons[id] = {id = id, activation = 0, type = neuron.type}
        end
        
        for i, id in ipairs(brain.input_nodes or {}) do
            table.insert(clone.input_nodes, id)
        end
        
        for i, id in ipairs(brain.output_nodes or {}) do
            table.insert(clone.output_nodes, id)
        end
        
        for i, synapse in ipairs(brain.synapses or {}) do
            -- Мутация веса
            local mutated_weight = synapse.weight * (0.9 + math.random() * 0.2)
            table.insert(clone.synapses, {
                from = synapse.from,
                to = synapse.to,
                weight = mutated_weight
            })
        end
        
        -- Копируем функции
        clone.step = brain.step
        clone.set_input = brain.set_input
        clone.get_output = brain.get_output
        clone.add_synapse = brain.add_synapse
        clone.get_stats = brain.get_stats
        clone.draw = brain.draw
        
        return clone
    end
    
    return muscle
end

return ReproduceSimple