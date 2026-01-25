BrainFactory = require("logic.brain.brain")
local brain = BrainFactory.new(3,2)

brain:set_input(3,1)

brain:step()

for i, v in pairs(brain.input_nodes) do
    print(i,v,brain.neurons[v].activation)
end

print()

for i, v in ipairs(brain.output_nodes) do
    print(i,v,brain.neurons[v].activation)
end

print()

for i, v in ipairs(brain.neurons) do
    print(i,v.activation)
end
