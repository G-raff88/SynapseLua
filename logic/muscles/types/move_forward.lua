local Muscle = {}

function Muscle.new(neuron_indexes, strength)
    local muscle = {
        -- neuron_indexes - это таблица с индексами выходных нейронов
        output_indexes = neuron_indexes or {1},  -- по умолчанию 1 и 2
        
        -- Массив сигналов (будет заполняться позже)
        signals = {},
        
        strength = strength or 1
    }
    
    function muscle:update(creature)
        -- Обновляем сигналы из мозга
        self.signals = {}
        for i, neuron_index in ipairs(self.output_indexes) do
            self.signals[i] = creature.brain:get_output(neuron_index) or 0
        end
    end

    function muscle:move(creature)
                
        -- Применяем силу к существу
        -- Предполагаем, что creature имеет pos = {x, y}
        if #self.signals >= 1 then
            creature.pos.x = creature.pos.x + self.strength * self.signals[1] * math.sin(creature.rot)
            creature.pos.y = creature.pos.y + self.strength * self.signals[1] * math.cos(creature.rot)
        end
        
    end
    
    return muscle
end

return Muscle