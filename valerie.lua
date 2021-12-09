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

function Valerie:new(o, v, get_value, panel_props)
    o.transitions = o.transitions or {}
    o.get = get_value or o.get
    
    setmetatable(o, {
        __index = self,
        __call = Valerie.set
    })

    o:set(v, panel_props)

    return o
end

function Valerie:set(v, panel_props, ignore_queue)
    if not (#self.transitions == 0 or ignore_queue) then
        self.transitions = {{
            old = self.real_value,
            new = v,
        }}

        return self.value
    end

    self.real_value = v
    self.value = self:get(v, panel_props)

    return self.value
end

function Valerie:get(v, panel_props)
    return v
end

function Valerie:transition(mode, v, delta, ignore_queue)
    if ignore_queue then
        self.transitions = {{
            mode = mode,

            old = self.real_value,
            new = v,
            
            delta = delta or 1
        }}
    else
        self.transitions[#self.transitions + 1] = {
            mode = mode,

            old = self.real_value,
            new = v,
            
            delta = delta or 1
        }
    end
end

function Valerie:transition_t(mode, v, time, ignore_queue)
    if ignore_queue then
        self.transitions = {{
            mode = mode,

            old = self.real_value,
            new = v,
            
            time = time or 1
        }}
    else
        self.transitions[#self.transitions + 1] = {
            mode = mode,

            old = self.real_value,
            new = v,
            
            time = time or 1
        }
    end
end

function Valerie:update(dt, panel_props)
    if #self.transitions > 0 then
        local trans = self.transitions[1]

        if not trans.delta and trans.time then
            trans.delta = math.abs((trans.new - trans.old) / trans.time)
        end

        if trans.mode == "linear" then
            if self.real_value < trans.new then
                local v = self.real_value + (dt * trans.delta)
                self:set(math.min(v, trans.new), panel_props, true)
            elseif self.real_value > trans.new then
                local v = self.real_value - (dt * trans.delta)
                self:set(math.max(v, trans.new), panel_props, true)
            else
                self:set(trans.new, panel_props, true)
                table.remove(self.transitions, 1)

                if #self.transitions > 0 then
                    self.transitions[1].old = self.real_value
                end
            end
        else
            self:set(trans.new, panel_props, true)
            table.remove(self.transitions, 1)

            if #self.transitions > 0 then
                self.transitions[1].old = self.real_value
            end
        end
    end

    self:set(self.real_value, panel_props, true)
end

setmetatable(Valerie, {
    __call = Valerie.new
})

return Valerie
