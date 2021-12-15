# Valerie
**Valerie** is a tool to simplify interpolation between numbers.

## What it Does
Valerie allows you to transition between two values with a *relatively* simple process.

## How to Use It
### Installation
Just drop [valerie.lua](https://github.com/massette/valerie-love/blob/master/valerie.lua) into whatever you're working on.

### But Actually, How to Use It
You'll need to require it before you can do anything with it.
```lua
local Val = require("valerie")
```

Initialize whatever value you plan to transition as a table with its actual value under the key `value`.
```lua
local a = { value = 0 }

print(a.value) -- 0
```

When you want to transition it to something else set it to the return of `Valerie.Transition(...)` (or `Valerie.Transition:new(...)`).
```lua
a = Val.Transition({}, 5) -- will transition linearly from 0 to 5 over the course of 5 seconds
a = Val.Transition({}, 2, Val.linear(a.value, 10)) -- transition from the current value of a to 10 over the course of 2 seconds
a = Val.Transition({}, 3, Val.ease_in_out(a.value, a.value + 10)) -- increase a by 10 over the courseo of 3 seconds not linearly
```

For this to work you have to run Val.Transition:update(...) periodically. Since this function will only exist when the value is transitioning, you will probably need to check for it before you run it.
```lua
function love.update(dt)
    if a.update then
        a:update(dt)
    end
end
```

Update will return the final value of the transition when it is done. Although the transition will stop when it reaches its end, you can check for this value if you want to do anything at the end of the transition.
```lua
function love.update(dt)
    if a.update then
        local out = a:update(dt)

        if out then
            a = { value = a }
        end
    end
end
```