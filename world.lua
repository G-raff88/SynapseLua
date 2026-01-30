local World = {}

function World.new(width, height)
    local world = {
        creatures = {};
        time = 0;
        step_time = 0.2;
        last_step_time = 0;
        width = width or 600;
        height = height or 600
    }

    function world:update(creature, world, dt)
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
                for _, sensors in ipairs(creature.sensors) do
                    if sensors.update then
                        sensors:update(creature, world, dt)
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
                        muscle:move(creature,world)
                    end
                end
            end

            if creature.pos.x > self.width or creature.pos.x < 0 then
                creature.pos.x = creature.pos.x % self.width
            end
            if creature.pos.y > self.height or creature.pos.y < 0 then
                creature.pos.y = creature.pos.y % self.height
            end

        end

        if self.last_step_time+self.step_time < self.time then
            self.last_step_time = self.time
        end

    end

    function world:draw()
        for _, creature in ipairs(self.creatures) do
            local color = creature.color
            love.graphics.setColor(color/100,color%100/10,color%10)
            love.graphics.circle("fill", creature.pos.x or 0, creature.pos.y or 0, creature.radius or 5)

            if creature.sensors then
                for _, sensors in ipairs(creature.sensors) do
                    if sensors then
                        sensors:draw()
                    end
                end
            end

        end
    end

    return world
end

return World