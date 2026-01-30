Creature = {}

function Creature.new(pos, rot, brain, sensors, muscles, tags, energy, radius, color)
    local creature = {
        pos = pos or {x = 100, y = 100};
        rot = rot or 0;
        brain = brain or {};
        sensors = sensors or {};
        muscles = muscles or {};
        tags = tags or {};
        energy = energy or 100;
        radius = radius or 10;
        color = color or 10;
    }

    function creature:draw()
        love.graphics.circle("line", self.pos.x, self.pos.y, 12)
    end

    return creature
end


return Creature