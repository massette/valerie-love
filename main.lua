local Val = require("valerie")

local a = { value = 0 }

function love.keypressed(k)
    a = Val.Transition({}, 0.5, Val.ease_in_out(a.value, a.value + 200))
end

function love.update(dt)
    if a.update then
        local out = a:update(dt)

        if out then
            a = { value = out }
        end
    end
end

function love.draw()
    love.graphics.circle("fill", 400,a.value, 5)
end