local Valerie = {
    _VERSION = "Valerie v.1.0.0",
    _DESCRIPTION = "A thing.",
    _URL = "https://github.com/massette/",

	_LICENSE = [[Copyright (c) 2021 massette

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.]]
}

function Valerie.get(v)
    return (type(v) == "table" and v.value) or v
end

-- DEFINE TRANSITION SLOPES
function Valerie.linear(a,b)
    local diff = b - a

    return function (self, t)
        t = t or self.t

        local x = (t / self.duration)

        return a + diff * x
    end
end

function Valerie.ease_in_out(a,b, r)
    r = r or 2

    local diff = b - a

    return function (self, t)
        t = t or self.t

        local x = (t / self.duration)

        return a + diff * (x^r / (x^r + (1 - x)^r))
    end
end

-- CREATE TRANSITION OBJECT
Valerie.Transition = {}

function Valerie.Transition:new(o, duration, get)
    o = o or {}

    o.get = get or o.get or Valerie.linear(0,o.t, 1)

    o.duration = duration or o.duration

    o.t = o.t or 0
    o.value = o.value or o:get(o.t)

    setmetatable(o, {
        __index = Valerie.Transition,
        __call = o.get
    })

    return o
end

function Valerie.Transition:update(dt)
    self.t = math.min(self.t + dt, self.duration)
    self.value = self:get()

    if self.t == self.duration then
        return self.value
    else
        return nil
    end
end

setmetatable(Valerie.Transition, {
    __call = Valerie.Transition.new
})

return Valerie