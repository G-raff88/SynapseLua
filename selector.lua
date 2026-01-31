return function (world)
    local selected = nil
    
    return {
        -- Эта функция должна вызываться из love.mousepressed
        handleClick = function(x, y, button)
            if button == 1 then  -- Левая кнопка мыши
                selected = nil
                
                for i, creature in ipairs(world.creatures) do
                    if creature.pos then
                        local dx = x - creature.pos.x
                        local dy = y - creature.pos.y
                        local distance = math.sqrt(dx*dx + dy*dy)
                        
                        if distance <= (creature.radius or 20) then
                            selected = creature
                            creature.selected = true
                            print("Существо выбрано: ", creature.type or "unknown")
                            break
                        end
                    end
                end
                
                -- Снимаем выделение с других существ
                if not selected then
                    for _, creature in ipairs(world.creatures) do
                        creature.selected = false
                    end
                end
                
                return selected ~= nil  -- возвращаем true если кликнули по существу
            end
            return false
        end,
        
        getSelected = function()
            return selected
        end,
        
        draw = function()
            -- Рисуем индикатор выбранного существа
            if selected and selected.pos then
                love.graphics.setColor(0, 1, 0, 0.5)
                love.graphics.circle("line", selected.pos.x, selected.pos.y, 
                    (selected.radius or 20) + 5)
                love.graphics.setColor(1, 1, 1, 1)
            end
        end
    }
end