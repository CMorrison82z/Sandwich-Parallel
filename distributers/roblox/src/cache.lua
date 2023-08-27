local DEFAULT_REPLENISH_AMOUNT = 10

local module = {}

local methods = {}

do
    -- In future, could return an Option
    function methods:get()
        if #self.cache < 1 then
            print("Cache drained")

            self:expand(DEFAULT_REPLENISH_AMOUNT)
        end

        local _num_in_cache = #self.cache

        local _retrieved_object = self.cache[_num_in_cache]
        self.cache[_num_in_cache] = nil
        self.objects_in[_retrieved_object] = false

        return _retrieved_object
    end

    function methods:expand(amount)
        for _ = 1, amount do
            local _new_obj = self._constructor()

            table.insert(self.cache, _new_obj)
            self.objects_in[_new_obj] = true
        end
    end

    function methods:return_object(obj)
        if self.objects_in[obj] then
            return print("Object already in cache.")
        end

        table.insert(self.cache, obj)
        self.objects_in[obj] = true

        self._on_return(obj)
    end

    module.methods = methods
    methods.__index = methods
end

local function _no_op() end

-- Constructor should be a higher-order function over whatever specific construction you want (For example :
-- constructor = function()
--    return Part.new{
--      Size = {4, 4, 4},
--      Position = {0, 0, 0},
--      Color = {0, 0, 0}
--    }
-- end
-- )
function module.new(amount, constructor, on_return)
    local in_cache = {}
    local cache = {}

    for i = 1, amount do
        table.insert(cache, constructor())
        in_cache[cache[i]] = true
    end

    return setmetatable({
        cache = cache,
        objects_in = in_cache,

        _constructor = constructor,
        _on_return = on_return or _no_op,
    }, methods)
end

return module
