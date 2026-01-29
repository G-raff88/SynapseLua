local World = {}

function World.new()
    local world = {
        creatures = {};
        time = 0;
        step_time = 1;
        last_step_time = 0
    }

    function world:update(dt)
        self.time = self.time + dt
        
        -- Обновляем каждое существо
        for _, creature in ipairs(self.creatures) do
            -- 1. Обновляем сенсоры
            if creature.sensors then
                for _, sensor in ipairs(creature.sensors) do
                    if sensor.update then
                        sensor:update(creature, self, dt)
                    end
                end
            end
            
            -- 2. Обновляем входы мозга (если есть сенсоры с данными)
            if creature.sensors then
                for i, sensor in ipairs(creature.sensors) do
                    if sensor.value and creature.brain and creature.brain.set_input then
                        creature.brain:set_input(i, sensor.value)
                    end
                end
            end
            
            -- 3. Шаг мозга
            if creature.brain and creature.brain.step and self.last_step_time+self.step_time < self.time then
                creature.brain:step()
            end
            
            -- 4. Обновляем мускулы
            if creature.muscles then
                for _, muscle in ipairs(creature.muscles) do
                    if muscle.update then
                        muscle:update(creature)
                    end
                    
                    if muscle.move then
                        muscle:move(creature)
                    end
                end
            end
        end

        if self.last_step_time+self.step_time < self.time then
            self.last_step_time = self.time
        end
    end

    function world:draw()
        for _, creature in ipairs(self.creatures) do
            love.graphics.setColor(0.9, 0.8, 0.2)
            love.graphics.circle("fill", creature.pos.x or 0, creature.pos.y or 0, creature.radius or 5)
        end
    end

    return world
end

return World