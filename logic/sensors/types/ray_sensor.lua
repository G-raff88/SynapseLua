-- [file name]: ray_sensor.lua
local RaySensor = {}

function RaySensor.new(neuron_index, angle, length, ray_color)
    local sensor = {
        -- Индекс входного нейрона в мозге
        neuron_index = neuron_index or 1,
        
        -- Угол луча относительно направления существа (в радианах)
        angle = angle or 0,
        
        -- Длина луча
        length = length or 100,
        
        -- Цвет луча для отрисовки
        ray_color = ray_color or {0.9, 0.2, 0.2, 0.7},
        
        -- Результаты сканирования
        hit_distance = length, -- расстояние до столкновения
        hit_point = nil,       -- точка столкновения
        hit_object = nil,      -- объект, в который попал луч
        signal_value = 0       -- нормализованное значение (0-1)
    }
    
    -- Обновление сенсора (определение коллизий)
    function sensor:update(creature, world, dt)
        -- Сбрасываем значения
        self.hit_distance = self.length
        self.hit_point = nil
        self.hit_object = nil
        
        -- Вычисляем абсолютный угол луча
        local absolute_angle = creature.rot + self.angle
        
        -- Начальная точка луча (позиция существа)
        local start_x = creature.pos.x
        local start_y = creature.pos.y
        
        -- Конечная точка луча (максимальная длина)
        local end_x = start_x + math.cos(absolute_angle) * self.length
        local end_y = start_y + math.sin(absolute_angle) * self.length
        
        -- Проходим по всем существам в мире (кроме самого себя)
        local closest_hit_distance = self.length
        local closest_hit_point = nil
        local closest_hit_object = nil
        
        for _, other_creature in ipairs(world.creatures) do
            if other_creature ~= creature then
                -- Проверяем пересечение луча с кругом (существом)
                local hit, distance, hit_x, hit_y = self:ray_circle_intersection(
                    start_x, start_y, end_x, end_y,
                    other_creature.pos.x, other_creature.pos.y, 
                    other_creature.radius or 5
                )
                
                if hit and distance < closest_hit_distance then
                    closest_hit_distance = distance
                    closest_hit_point = {x = hit_x, y = hit_y}
                    closest_hit_object = other_creature
                end
            end
        end
        
        -- Сохраняем результаты, если было столкновение
        if closest_hit_object then
            self.hit_distance = closest_hit_distance
            self.hit_point = closest_hit_point
            self.hit_object = closest_hit_object
            
            -- Нормализуем расстояние: 1 = близко, 0 = далеко
            self.signal_value = 1 - (closest_hit_distance / self.length)
        else
            -- Если столкновений нет, расстояние максимальное
            self.hit_distance = self.length
            self.signal_value = 0
        end
        
        -- Передаем сигнал в мозг существа
        if creature.brain and creature.brain.set_input then
            creature.brain:set_input(self.neuron_index, self.signal_value)
        end
        
        -- Сохраняем данные для отрисовки
        self.start_point = {x = start_x, y = start_y}
        self.end_point = {
            x = start_x + math.cos(absolute_angle) * self.hit_distance,
            y = start_y + math.sin(absolute_angle) * self.hit_distance
        }
        self.abs_angle = absolute_angle
    end
    
    -- Проверка пересечения луча с кругом
    function sensor:ray_circle_intersection(ray_x1, ray_y1, ray_x2, ray_y2, circle_x, circle_y, radius)
        -- Вектор луча
        local dx = ray_x2 - ray_x1
        local dy = ray_y2 - ray_y1
        
        -- Вектор от начала луча до центра круга
        local fx = ray_x1 - circle_x
        local fy = ray_y1 - circle_y
        
        -- Квадратичное уравнение для нахождения пересечения
        local a = dx * dx + dy * dy
        local b = 2 * (fx * dx + fy * dy)
        local c = fx * fx + fy * fy - radius * radius
        
        -- Дискриминант
        local discriminant = b * b - 4 * a * c
        
        -- Нет пересечений
        if discriminant < 0 then
            return false
        end
        
        discriminant = math.sqrt(discriminant)
        
        -- Находим два решения (t1, t2)
        local t1 = (-b - discriminant) / (2 * a)
        local t2 = (-b + discriminant) / (2 * a)
        
        -- Нас интересуют только пересечения в пределах отрезка луча (0 <= t <= 1)
        -- Берем ближайшее пересечение
        local t = nil
        
        if t1 >= 0 and t1 <= 1 then
            t = t1
        elseif t2 >= 0 and t2 <= 1 then
            t = t2
        else
            return false
        end
        
        if not t then return false end
        
        -- Вычисляем точку пересечения и расстояние
        local hit_x = ray_x1 + t * dx
        local hit_y = ray_y1 + t * dy
        
        -- Расстояние от начала луча до точки пересечения
        local distance = math.sqrt(
            (hit_x - ray_x1) * (hit_x - ray_x1) + 
            (hit_y - ray_y1) * (hit_y - ray_y1)
        )
        
        return true, distance, hit_x, hit_y
    end
    
    -- Отрисовка сенсора
    function sensor:draw()
        if not self.start_point or not self.end_point then
            return
        end
        
        -- Рисуем луч
        love.graphics.setColor(unpack(self.ray_color))
        love.graphics.setLineWidth(2)
        love.graphics.line(
            self.start_point.x, self.start_point.y,
            self.end_point.x, self.end_point.y
        )
        
        -- Рисуем точку столкновения, если есть
        if self.hit_point then
            love.graphics.setColor(1, 0.2, 0.2, 1)
            love.graphics.circle("fill", self.hit_point.x, self.hit_point.y, 4)
        end
        
        -- Рисуем небольшую метку в начале луча
        love.graphics.setColor(0.2, 0.9, 0.2, 1)
        love.graphics.circle("fill", self.start_point.x, self.start_point.y, 3)
        
        love.graphics.setLineWidth(1)
    end
    
    -- Получить текущее значение сенсора
    function sensor:get_value()
        return self.signal_value
    end
    
    -- Получить информацию о последнем столкновении
    function sensor:get_hit_info()
        return {
            distance = self.hit_distance,
            point = self.hit_point,
            object = self.hit_object,
            signal = self.signal_value
        }
    end
    
    return sensor
end

return RaySensor