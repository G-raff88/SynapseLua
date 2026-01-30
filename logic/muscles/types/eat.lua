-- [file name]: eat.lua
local EatMuscle = {}

function EatMuscle.new(eat_radius)
    local muscle = {
        eat_radius = eat_radius or 15  -- радиус поедания
    }
    
    function muscle:update(creature)
        -- ничего не делаем в update
    end
    
    function muscle:move(creature, world)
        if not creature.pos or not world.creatures then
            return
        end
        
        -- Ищем еду поблизости
        for i = #world.creatures, 1, -1 do
            local food = world.creatures[i]
            
            -- Проверяем, что это не само существо
            if food ~= creature then
                -- Проверяем тег food
                if food.tags and food.tags.food ~= nil then
                    -- Проверяем расстояние
                    local dx = food.pos.x - creature.pos.x
                    local dy = food.pos.y - creature.pos.y
                    local distance = math.sqrt(dx * dx + dy * dy)
                    
                    -- Если в радиусе поедания
                    if distance <= (creature.radius or 10) + (food.radius or 5) + self.eat_radius then
                        -- Передаем энергию
                        if food.energy then
                            creature.energy = (creature.energy or 0) + food.energy
                        end
                        
                        -- Удаляем еду из мира
                        table.remove(world.creatures, i)
                        
                        -- Можно добавить эффект
                        print("Съедено! Энергия: " .. (creature.energy or 0))
                    end
                end
            end
        end
    end
    
    return muscle
end

return EatMuscle