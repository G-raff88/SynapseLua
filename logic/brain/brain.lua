-- neurobrain.lua
local NeuroBrain = {}  -- Это ФАБРИКА (модуль)

-- Метод фабрики для создания нового мозга
function NeuroBrain.new(input_count, output_count, hidden_count, synapses_count)
    hidden_count = hidden_count or 5
    synapses_count = synapses_count or 20
    -- Это КОНКРЕТНЫЙ МОЗГ (объект)
    local brain = {
        -- Данные конкретного мозга
        neurons = {},       -- {id = {activation = 0.5, ...}}
        synapses = {},      -- {{from = 1, to = 2, weight = 0.5}, ...}
        next_neuron_id = 1,
        input_nodes = {},   -- Список ID входных нейронов
        output_nodes = {},  -- Список ID выходных нейронов
    }
    
    -- Создаем входные нейроны
    for i = 1, input_count do
        local neuron_id = brain.next_neuron_id
        brain.next_neuron_id = brain.next_neuron_id + 1
        
        brain.neurons[neuron_id] = {
            id = neuron_id,
            activation = 0,
            type = "input"
        }
        table.insert(brain.input_nodes, neuron_id)
    end
    
    -- Создаем выходные нейроны
    for i = 1, output_count do
        local neuron_id = brain.next_neuron_id
        brain.next_neuron_id = brain.next_neuron_id + 1
        
        brain.neurons[neuron_id] = {
            id = neuron_id,
            activation = 0,
            type = "output"
        }
        table.insert(brain.output_nodes, neuron_id)
    end
    
    -- Добавляем несколько случайных скрытых нейронов
    for i = 1, hidden_count do
        local neuron_id = brain.next_neuron_id
        brain.next_neuron_id = brain.next_neuron_id + 1
        
        brain.neurons[neuron_id] = {
            id = neuron_id,
            activation = 0,
            type = "hidden"
        }
    end
    
    -- Добавляем случайные связи
    for i = 1, synapses_count do
        local neuron_ids = {}
        for id in pairs(brain.neurons) do
            table.insert(neuron_ids, id)
        end
        
        if #neuron_ids >= 2 then
            local from = neuron_ids[math.random(#neuron_ids)]
            local to = neuron_ids[math.random(#neuron_ids)]
            
            if from ~= to then
                table.insert(brain.synapses, {
                    from = from,
                    to = to,
                    weight = math.random() * 2 - 1  -- -1 до 1
                })
            end
        end
    end
    
    -- ============ МЕТОДЫ ЭКЗЕМПЛЯРА ============
    -- Эти методы работают с КОНКРЕТНЫМ мозгом
    
    -- Шаг работы мозга
    function brain:step()
        -- 1. Копируем текущие активации
        local new_activations = {}
        for id, neuron in pairs(self.neurons) do
            new_activations[id] = neuron.activation
        end
        
        -- 2. Обнуляем скрытые и выходные нейроны
        for id, neuron in pairs(self.neurons) do
            if neuron.type ~= "input" then
                new_activations[id] = 0
            end
        end
        
        -- 3. Передаем сигналы по синапсам
        for _, synapse in ipairs(self.synapses) do
            local from_neuron = self.neurons[synapse.from]
            if from_neuron and math.abs(from_neuron.activation) > 0.1 then
                new_activations[synapse.to] = new_activations[synapse.to] + 
                    from_neuron.activation * synapse.weight
            end
        end
        
        -- 4. Применяем функцию активации
        for id, activation in pairs(new_activations) do
            local neuron = self.neurons[id]
            if neuron and neuron.type ~= "input" then
                neuron.activation = math.tanh(activation)
            end
        end
    end
    
    -- Установить входное значение
    function brain:set_input(index, value)
        local neuron_id = self.input_nodes[index]
        if neuron_id and self.neurons[neuron_id] then
            self.neurons[neuron_id].activation = value
        end
    end
    
    -- Получить выходное значение
    function brain:get_output(index)
        local neuron_id = self.output_nodes[index]
        if neuron_id and self.neurons[neuron_id] then
            return self.neurons[neuron_id].activation
        end
        return 0
    end
    
    -- Добавить случайную связь
    function brain:add_synapse(from, to)
        local neuron_ids = {}
        for id in pairs(self.neurons) do
            table.insert(neuron_ids, id)
        end
        
        if #neuron_ids >= 2 then
            local from_ = neuron_ids[math.random(#neuron_ids)]
            local to_ = neuron_ids[math.random(#neuron_ids)]
            
            if from and to then
                from_=from
                to_ = to
            end

            if from_ ~= to_ then
                table.insert(self.synapses, {
                    from = from_,
                    to = to_,
                    weight = math.random() * 2 - 1
                })
                return true
            end
        end
        return false
    end
    
    -- Получить статистику
    function brain:get_stats()
        local neuron_count = 0
        for _ in pairs(self.neurons) do
            neuron_count = neuron_count + 1
        end
        
        return {
            neurons = neuron_count,
            synapses = #self.synapses,
            inputs = #self.input_nodes,
            outputs = #self.output_nodes
        }
    end
    
    -- Вернуть готовый мозг
    return brain
end

-- ============ МЕТОДЫ ФАБРИКИ ============
-- Эти методы работают с самой фабрикой NeuroBrain

-- Создать мутировавшую копию мозга
function NeuroBrain.create_mutated_copy(original_brain, mutation_rate)
    mutation_rate = mutation_rate or 0.1
    
    -- Создаем новый мозг с теми же параметрами
    local new_brain = NeuroBrain.new(
        #original_brain.input_nodes,
        #original_brain.output_nodes
    )
    
    -- Копируем нейроны
    new_brain.neurons = {}
    new_brain.next_neuron_id = 1
    
    -- ... здесь была бы логика копирования с мутациями
    
    return new_brain
end

-- Вернуть фабрику
return NeuroBrain