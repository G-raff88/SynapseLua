-- [file name]: 1st.lua (обновленная версия)
local Creature = {}

function Creature.new()
    math.randomseed(os.time() * 1000 + math.random(1000))
    
    local BrainFactory = require("logic.brain.brain")
    local CreatureFactory = require("logic.creatures.creature")
    local RaySensor = require("logic.sensors.types.ray_sensor")
    local TimeSensor = require("logic.sensors.types.sin_timer")
    
    -- Создаем мозг с 5 входами:
    -- 1-3: сенсоры-лучи
    -- 4: таймер синус
    -- 5: таймер косинус
    local brain = BrainFactory.new(5, 2, 4, 0)
    local creature = CreatureFactory.new({x = 300, y = 300}, 0, brain)

    for i=1,5 do
        for ii=8,11 do
            creature.brain:add_synapse(i,ii)
        end
    end

    for i=8,11 do
        for ii=6,7 do
            creature.brain:add_synapse(i,ii)
        end
    end

    -- Добавляем сенсоры-лучи
    creature.sensors = creature.sensors or {}
    creature.sensors[#creature.sensors + 1] = RaySensor.new(1, 0, 150, {0.9, 0.2, 0.2, 0.7})      -- Прямо
    creature.sensors[#creature.sensors + 1] = RaySensor.new(2, math.pi/4, 120, {0.2, 0.7, 0.2, 0.7})  -- 45° вправо
    creature.sensors[#creature.sensors + 1] = RaySensor.new(3, -math.pi/4, 120, {0.2, 0.2, 0.9, 0.7}) -- 45° влево
    
    -- Добавляем сенсоры времени (синус и косинус)
    creature.sensors[#creature.sensors + 1] = TimeSensor.new(4, 0.5, 1.0, 0)      -- sin, 0.5 Гц
    creature.sensors[#creature.sensors + 1] = TimeSensor.new(5, 0.5, 1.0, math.pi/2) -- cos, 0.5 Гц
    
    -- Добавляем мышцы
    local muscle1 = require("logic.muscles.types.move_forward")
    local muscle2 = require("logic.muscles.types.rotate")
    creature.muscles = creature.muscles or {}
    creature.muscles[#creature.muscles + 1] = muscle1.new({1}, 2)   -- Двигаться вперед/назад
    creature.muscles[#creature.muscles + 1] = muscle2.new({2}, 0.2) -- Поворот
    
    return creature
end

return Creature