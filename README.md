# Valerie
**Valerie** is a tool to easily transition between values and do weird function stuff. It might be useless; I can't tell.

## What it Does
I started this because smooth transitions have always gummed up my code and I wanted a simple way to pass percentages of non-constant values to stuff. It's mainly for use in a GUI thing that I'm working on, but its written entirely in lua, so I guess you could use it for something else if you really wanted to. There's [a version without the weird props stuff](https://github.com/massette/valerie-love/blob/master/valerie-no-props.lua) if you just want the transitions part of it.

## How to Use It
### Installation
If you just want the transitions stuff, then you can download [valerie-no-props.lua](https://github.com/massette/valerie-love/blob/master/valerie-no-props.lua), rename it something a little less unwieldy, and drop it in whatever project you're working on. If you also want the weird globals-work-around props stuff then just download [valerie.lua](https://github.com/massette/valerie-love/blob/master/valerie.lua), and do the same.

### But Actually, How to Use It
Make sure to require it before you try to do anything else with it.
```lua
local Val = require("valerie")
```

To define a value that you want to do transitions on just do one of the following.
```lua
local a = Val:new({}, 0) -- initial value of 0
local b = Val({}, 0)     -- exactly the same as above
```

To access the value of these two variables, do the following.
```lua
print(a.value) -- 0
print(b.value) -- 0
```

And make sure to call the following in love.update (or some equivalent if you're using this outside of löve2D for whatever reason).
```lua
a:update(dt)
b:update(dt)
```

Then later in the code, you can do the one of the following to transition to another value smoothly, or to set the value.
```lua
a:transition("linear", 5, 5) -- transition linearly to a value of 5 at a rate of 5/sec
b:transition_t("linear", 5, 1) -- transition linarly to a value of 5 over one second

a:set(b.value) -- set a to the value of b
```

The output of a value defined through Valerie can also be mapped to a function.
```lua
local function sin (self, v, panel_props)
    return math.sin(v)
end

local function cos (self, v, panel_props)
    return math.cos(v)
end

local c = Val({}, 0, sin)
local d = Val({}, 0, cos)
print(c.value) -- 0
print(d.value) -- 1

c:set(math.pi/2)
d:set(math.pi/2)
print(c.value) -- 1
print(d.value) -- 0

c:set(math.pi)
d:set(math.pi)
print(c.value) -- 0
print(d.value) -- 1
```

Notably, the `self` in both of these functions represents the Valerie value that will later be calling them. You'll notice that the functions passed to they also have a third, unused parameter: `panel_props`. This is the aforementioned "weird globals-work-around props stuff". Most of the calls that set the value of anything defined through Valerie (update, set, and new) expect a panel_props table, and any table you pass here will receive it. This allows for things like the following, and I'm sure most people will just want to ignore it.

```lua
local Val = require("valerie")

local function vw(self, v, panel_props)
    return (v/100) * panel_props.dimensions[1]
end

local window = {
    dimensions = { love.graphics.getDimensions() }
}

local x = Val({}, 0, vw, window)
print(x.value) -- 0

x:set(50, window)

function love.resize(w,h)
    window.dimensions = { w,h }
end

function love.update(dt)
    x:update(dt, window)
    print(x.value) -- 400, at the default love resolution, 800 x 600
                   -- the neat thing is that it will always be the center of the window, even if the window is resized, as long as window.dimensions is updated and x:update(...) is called regularly
end
```

It's probably worth mentioning that, by default Valerie:transition and Valerie:set will always add on to a queue of transitions. If you want to skip this queue you can do a hard set or hard transition like this:
```lua
a:set(0, {}, true)
a:transition("linear", 0, 1, true)
```

Both of these will remove all currently queued transitions.
