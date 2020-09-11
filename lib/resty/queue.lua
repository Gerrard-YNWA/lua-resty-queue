local semaphore = require('ngx.semaphore')

local _M = {_VERSION = "0.1"}

local tab_ok, new_tab = pcall(require, "table.new")
if not tab_ok then
    new_tab = function() return {} end
end

-- constant
local max_size = 1024

local mt = {__index = _M}


function _M.new(opts)
    local capacity = opts.capacity or max_size
    local queue = new_tab(capacity, 10)

    queue.head = 1
    queue.tail = 1
    queue._capacity = capacity
    queue._max_n = capacity + 1

    if opts.blocked then
        queue.push_sema = semaphore.new()
        queue.pop_sema = semaphore.new()
        queue.timeout = opts.timeout or 3
    end

    return setmetatable(queue, mt)
end


function _M:size()
    return (self.tail - self.head + self._max_n) % self._max_n
end


function _M:capacity()
    return self._capacity
end


function _M:full()
    return (self.tail + 1) % self._max_n == self.head
end


function _M:empty()
    return self.head == self.tail
end


function _M:push(v, wait)
    if self:full() then
        if not self.push_sema or wait == false then
            return nil, "queue is full"
        end
        self._push_blocking = true
        while true do
            local ok, err = self.push_sema:wait(self.timeout)
            if ok then
                break
            end

            if err and err ~= 'timeout' then
                self._push_blocking = false
                return nil, err
            end
        end
        self._push_blocking = false
    end

    self[self.tail] = v
    self.tail = self.tail % self._max_n + 1
    if self.pop_sema then
        self.pop_sema:post()
    end

    return true
end


function _M:pop(wait)
    if self.pop_sema and wait ~= false then
        local ok, err
        while true do
            ok, err = self.pop_sema:wait(self.timeout)
            if ok then
                break
            end

            if err and err ~= 'timeout' then
                break
            end
        end
    end

    if self:empty() then
        return nil
    end

    local is_full = self:full()
    local v = self[self.head]
    if v then
        self[self.head] = nil
        self.head = self.head % self._max_n + 1
    end

    if is_full and self._push_blocking then
        self.push_sema:post()
    end

    return v
end


function _M:clear()
    while self:size() > 0 do
        self:pop(false)
    end
    self.head = 1
    self.tail = 1
end


return _M
