local Valerie = {}

function Valerie:new(o, v, get_value, panel_props)
    o.transitions = {}
    o.get = get_value
    
    setmetatable(o, {
        __index = self,
        __call = Valerie.set
    })

    o:set(v, panel_props)

    return o
end

function Valerie:set(v, panel_props, ignore_queue)
    if not (#self.transitions == 0 or ignore_queue) then
        self.transitions[#self.transitions + 1] = {
            old = self.real_value,
            new = v,
        }

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

function Valerie:update(panel_props, dt)
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
end

setmetatable(Valerie, {
    __call = Valerie.new
})

return Valerie
