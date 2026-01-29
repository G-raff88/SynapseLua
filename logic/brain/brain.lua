-- neurobrain.lua
local NeuroBrain = {}  -- Это ФАБРИКА (модуль)

-- Метод фабрики для создания нового мозга
function NeuroBrain.new(input_count, output_count, hidden_count, synapses_count)
    math.randomseed(os.time())
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
    
    -- ============ ГРАФИКА С ФИЗИКОЙ ============
    function brain:draw(dt, repel_distance, attract_distance)
        -- Если это первый вызов, инициализируем физику
        if not self.positions then
            self:init_physics()
        end
        
        -- Обновляем физику графа
        self:update_graph_physics(dt, repel_distance, attract_distance)
        
        -- Рисуем граф
        self:draw_graph()
    end
    
    -- Инициализация физики графа
    function brain:init_physics()
        local width, height = love.graphics.getDimensions()
        local center_x, center_y = width / 2, height / 2
        
        self.positions = {}
        self.velocities = {}
        
        -- Распределяем нейроны по кругу для начальной позиции
        local count = 0
        for id, _ in pairs(self.neurons) do
            count = count + 1
        end
        
        local i = 0
        local radius = math.min(width, height) * 0.4
        for id, _ in pairs(self.neurons) do
            i = i + 1
            local angle = (i / count) * math.pi * 2
            self.positions[id] = {
                x = center_x + math.cos(angle) * radius,
                y = center_y + math.sin(angle) * radius
            }
            self.velocities[id] = {x = 0, y = 0}
        end
    end
    
    -- Обновление физики графа
    function brain:update_graph_physics(dt, repel_distance, attract_distance)
        repel_distance = repel_distance or 10
        attract_distance = attract_distance or 30
        
        local width, height = love.graphics.getDimensions()
        
        -- Физика притяжения/отталкивания
        local force_constant = 1000
        local damping = 0.9
        
        -- Отталкивание между всеми нейронами
        local ids = {}
        for id, _ in pairs(self.neurons) do
            table.insert(ids, id)
        end
        
        for i = 1, #ids do
            for j = i + 1, #ids do
                local id1, id2 = ids[i], ids[j]
                local pos1, pos2 = self.positions[id1], self.positions[id2]
                
                local dx = pos2.x - pos1.x
                local dy = pos2.y - pos1.y
                local distance = math.sqrt(dx * dx + dy * dy)
                
                if distance > 0 then
                    -- Нормализуем вектор
                    local nx = dx / distance
                    local ny = dy / distance
                    
                    -- Отталкивание на близком расстоянии
                    if distance < repel_distance then
                        local force = force_constant * (repel_distance - distance) / distance
                        self.velocities[id1].x = self.velocities[id1].x - nx * force * dt
                        self.velocities[id1].y = self.velocities[id1].y - ny * force * dt
                        self.velocities[id2].x = self.velocities[id2].x + nx * force * dt
                        self.velocities[id2].y = self.velocities[id2].y + ny * force * dt
                    end
                    
                    -- Притяжение связанных нейронов
                    local is_connected = false
                    for _, synapse in ipairs(self.synapses) do
                        if (synapse.from == id1 and synapse.to == id2) or
                           (synapse.from == id2 and synapse.to == id1) then
                            is_connected = true
                            break
                        end
                    end
                    
                    if is_connected and distance > attract_distance then
                        local force = force_constant * 0.5 * (distance - attract_distance) / distance
                        self.velocities[id1].x = self.velocities[id1].x + nx * force * dt
                        self.velocities[id1].y = self.velocities[id1].y + ny * force * dt
                        self.velocities[id2].x = self.velocities[id2].x - nx * force * dt
                        self.velocities[id2].y = self.velocities[id2].y - ny * force * dt
                    end
                end
            end
        end
        
        -- Применение скоростей и ограничение в пределах экрана
        local margin = 50
        for id, pos in pairs(self.positions) do
            local vel = self.velocities[id]
            
            -- Демпфирование
            vel.x = vel.x * damping
            vel.y = vel.y * damping
            
            -- Обновление позиции
            pos.x = pos.x + vel.x * dt
            pos.y = pos.y + vel.y * dt
            
            -- Удержание в пределах экрана с мягкими границами
            local boundary_force = 100
            if pos.x < margin then
                vel.x = vel.x + (margin - pos.x) * boundary_force * dt
            elseif pos.x > width - margin then
                vel.x = vel.x - (pos.x - (width - margin)) * boundary_force * dt
            end
            
            if pos.y < margin then
                vel.y = vel.y + (margin - pos.y) * boundary_force * dt
            elseif pos.y > height - margin then
                vel.y = vel.y - (pos.y - (height - margin)) * boundary_force * dt
            end
        end
    end
    
    -- Отрисовка графа
    function brain:draw_graph()
        love.graphics.setLineWidth(1)
        
        -- 1. Отрисовка синапсов (сначала, чтобы были под нейронами)
        love.graphics.setColor(0.6, 0.6, 0.6, 0.8) -- Серый цвет для всех связей
        for _, synapse in ipairs(self.synapses) do
            local from_pos = self.positions[synapse.from]
            local to_pos = self.positions[synapse.to]
            
            if from_pos and to_pos then
                -- Толщина линии по абсолютному значению веса
                local weight = math.abs(synapse.weight or 0)
                local line_width = math.min(3, weight * 2 + 0.5)
                love.graphics.setLineWidth(line_width)
                
                -- Рисуем линию
                local angle = math.atan2(to_pos.y - from_pos.y, to_pos.x - from_pos.x)
                local length = math.sqrt((to_pos.x - from_pos.x)^2 + (to_pos.y - from_pos.y)^2)
                
                -- Укорачиваем линию чтобы не перекрывать нейроны
                local neuron_radius = 12
                local start_x = from_pos.x + math.cos(angle) * neuron_radius
                local start_y = from_pos.y + math.sin(angle) * neuron_radius
                local end_x = to_pos.x - math.cos(angle) * neuron_radius
                local end_y = to_pos.y - math.sin(angle) * neuron_radius
                
                love.graphics.line(start_x, start_y, end_x, end_y)
                
                -- Стрелка на конце (только для достаточно длинных связей)
                if length > 40 then
                    local arrow_length = 8
                    local arrow_angle = math.pi / 6
                    
                    love.graphics.setLineWidth(line_width * 1.2)
                    love.graphics.line(
                        end_x, end_y,
                        end_x - arrow_length * math.cos(angle - arrow_angle),
                        end_y - arrow_length * math.sin(angle - arrow_angle)
                    )
                    love.graphics.line(
                        end_x, end_y,
                        end_x - arrow_length * math.cos(angle + arrow_angle),
                        end_y - arrow_length * math.sin(angle + arrow_angle)
                    )
                end
            end
        end
        
        -- 2. Отрисовка нейронов
        for id, neuron in pairs(self.neurons) do
            local pos = self.positions[id]
            if pos then
                local activation = neuron.activation or 0
                
                -- Определяем тип нейрона
                local neuron_type = neuron.type or "hidden"
                local is_input = neuron_type == "input"
                local is_output = neuron_type == "output"
                
                -- Цвет контура всегда соответствует типу нейрона
                local outline_color
                if is_input then
                    outline_color = {0.3, 0.5, 0.9}    -- Синий для входных
                elseif is_output then
                    outline_color = {0.7, 0.3, 0.9}    -- Фиолетовый для выходных
                else
                    outline_color = {0.3, 0.9, 0.5}    -- Зеленый для скрытых
                end
                
                -- Цвет заливки: чем больше активация, тем ближе к цвету контура
                -- При activation=0 -> серый, при activation=1 -> цвет контура
                local activation_factor = math.max(0, math.min(1, activation))
                local fill_r = 0.5 * (1 - activation_factor) + outline_color[1] * activation_factor
                local fill_g = 0.5 * (1 - activation_factor) + outline_color[2] * activation_factor
                local fill_b = 0.5 * (1 - activation_factor) + outline_color[3] * activation_factor
                
                -- Основной круг нейрона (заливка)
                love.graphics.setColor(fill_r, fill_g, fill_b)
                love.graphics.circle("fill", pos.x, pos.y, 12)
                
                -- Контур нейрона
                love.graphics.setLineWidth(3)
                love.graphics.setColor(unpack(outline_color))
                love.graphics.circle("line", pos.x, pos.y, 12)
                
                -- Тонкая внутренняя линия для аккуратности
                love.graphics.setLineWidth(1)
                love.graphics.setColor(1, 1, 1, 0.3)
                love.graphics.circle("line", pos.x, pos.y, 11.5)
                
                -- ID нейрона
                love.graphics.setColor(1, 1, 1, 0.9)
                love.graphics.printf(tostring(id), pos.x - 8, pos.y - 5, 16, "center")
            end
        end
        
        -- Восстанавливаем толщину линии
        love.graphics.setLineWidth(1)
    end
    
    -- Дополнительный метод для сброса физики (если нужно)
    function brain:reset_physics()
        self.positions = nil
        self.velocities = nil
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