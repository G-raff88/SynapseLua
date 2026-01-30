local Muscle = {}

function Muscle.new(neuron_indexes, strength)
    local muscle = {
        output_indexes = neuron_indexes or {1},
        
        signals = {},
        
        strength = strength or 1
    }
    
    function muscle:update(creature)
        self.signals = {}
        for i, neuron_index in ipairs(self.output_indexes) do
            creature.energy = creature.energy + 0.01
        end
    end


    
    return muscle
end

return Muscle