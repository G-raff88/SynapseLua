-- [file name]: time_sensor.lua
local TimeSensor = {}

function TimeSensor.new(neuron_index, frequency, amplitude, phase)
    local sensor = {
        -- Индекс входного нейрона в мозге
        neuron_index = neuron_index or 1,
        
        -- Частота синусоиды (колебаний в секунду)
        frequency = frequency or 1.0,
        
        -- Амплитуда сигнала
        amplitude = amplitude or 1.0,
        
        -- Фаза (смещение) в радианах
        phase = phase or 0,
        
        -- Текущее время
        local_time = 0,
        
        -- Текущее значение сигнала
        signal_value = 0
    }
    
    -- Обновление сенсора
    function sensor:update(creature, world, dt)
        -- Увеличиваем локальное время
        self.local_time = self.local_time + dt
        
        -- Вычисляем синусоидальный сигнал
        self.signal_value = self.amplitude * math.sin(
            2 * math.pi * self.frequency * self.local_time + self.phase
        )
        
        -- Передаем сигнал в мозг существа
        if creature.brain and creature.brain.set_input then
            -- Нормализуем значение от -1..1 к 0..1 (если нужно)
            -- creature.brain:set_input(self.neuron_index, self.signal_value)
            -- Или нормализованный вариант:
            local normalized_value = (self.signal_value + 1) / 2  -- от 0 до 1
            creature.brain:set_input(self.neuron_index, normalized_value)
        end
    end
    


    function sensor:draw()
        if not self.start_point or not self.end_point then
            return
        end
    end
--     -- Отрисовка сенсора (опционально, для визуализации)
--     function sensor:draw()
--         -- Можно нарисовать индикатор, если нужно
--         local x = 20
--         local y = 20 + (self.neuron_index - 1) * 30
        
--         -- Фон индикатора
--         love.graphics.setColor(0.2, 0.2, 0.3, 0.7)
--         love.graphics.rectangle("fill", x, y, 100, 20)
        
--         -- Значение
--         love.graphics.setColor(0.2, 0.8, 0.4)
--         local bar_width = 50 + 40 * self.signal_value  -- от 10 до 90
--         love.graphics.rectangle("fill", x + 25, y + 5, bar_width, 10)
        
--         -- Текст
--         love.graphics.setColor(1, 1, 1)
--         love.graphics.print(string.format("Time %d: %.2f", 
--             self.neuron_index, self.signal_value), x + 5, y)
--     end
    
--     -- Получить текущее значение сенсора
--     function sensor:get_value()
--         return self.signal_value
--     end
    
--     -- Получить информацию о сенсоре
--     function sensor:get_info()
--         return {
--             type = "time_sensor",
--             frequency = self.frequency,
--             amplitude = self.amplitude,
--             phase = self.phase,
--             value = self.signal_value,
--             time = self.local_time
--         }
--     end
    
--     -- Сброс сенсора
--     function sensor:reset()
--         self.local_time = 0
--         self.signal_value = 0
--     end
    
--     -- Установить параметры
--     function sensor:set_params(frequency, amplitude, phase)
--         if frequency then self.frequency = frequency end
--         if amplitude then self.amplitude = amplitude end
--         if phase then self.phase = phase end
--     end

    return sensor
end

return TimeSensor