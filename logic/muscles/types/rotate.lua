local Muscle = {}

function Muscle.new(neuron_indexes, strength)
    local muscle = {
        output_indexes = neuron_indexes or {1};
        
        signals = {},
        
        strength = strength or 1
    }
    
    function muscle:update(creature)
        self.signals = {}
        for i, neuron_index in ipairs(self.output_indexes) do
            self.signals[i] = creature.brain:get_output(neuron_index) or 0
        end
    end

    function muscle:move(creature)
                
        if #self.signals >= 1 then
            creature.rot = creature.rot + self.strength * self.signals[1]
        end

        
    end
    
    return muscle
end

return Muscle