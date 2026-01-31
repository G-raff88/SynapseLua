-- [file name]: 1st.lua (обновленная версия)
local Creature = {}

function Creature.new()
    math.randomseed(os.time() * 1000 + math.random(1000))
    
    local BrainFactory = require("logic.brain.brain")
    local CreatureFactory = require("logic.creatures.creature")
    local RaySensor = require("logic.sensors.types.ray_sensor")
    local TimeSensor = require("logic.sensors.types.sin_timer")

    local brain = BrainFactory.new(2, 2, 2, 400)
    local creature = CreatureFactory.new({x = 300, y = 300}, 0, brain)
    
    -- Добавляем сенсоры времени (синус и косинус)
    creature.sensors[#creature.sensors + 1] = TimeSensor.new(1, 0.5, 1.0, 0)      -- sin, 0.5 Гц
    creature.sensors[#creature.sensors + 1] = TimeSensor.new(2, 0.5, 1.0, math.pi/2) -- cos, 0.5 Гц
    
    -- Добавляем мышцы
    local muscle1 = require("logic.muscles.types.photosynthesis")
    local muscle2 = require("logic.muscles.types.reproduce")
    creature.muscles = creature.muscles or {}
    creature.muscles[#creature.muscles + 1] = muscle1.new({1})
    creature.muscles[#creature.muscles + 1] = muscle2.new({2})
    
    creature.energy = 20
    creature.tags.food = true
    creature.color = 300

    return creature
end

return Creature