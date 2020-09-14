use strict;
use Test::Nginx::Socket::Lua 'no_plan';

log_level('warn');

our $HttpConfig = <<'_EOC_';
    lua_socket_log_errors off;
    lua_package_path 'lib/?.lua;/usr/local/share/lua/5.3/?.lua;/usr/share/lua/5.1/?.lua;;';
_EOC_

run_tests();

__DATA__

=== TEST 1: new
--- http_config eval: $::HttpConfig
--- config
    location = /t {
        content_by_lua_block {
            local ringq = require("resty.queue")
            local queue, err = ringq.new({
                capacity = 10,
                blocked = true,
                timeout = 1
            })
            if err then
                ngx.log(ngx.ERR, "new queue error: ", err)
            end
            ngx.say("new ok")
        }
    }
--- request
GET /t
--- no_error_log
[error]
--- response_body
new ok


=== TEST 2: push and pop blocked
--- http_config eval: $::HttpConfig
--- config
    location = /t {
        content_by_lua_block {
            local ringq = require("resty.queue")
            local queue, err = ringq.new({
                capacity = 5,
                blocked = true,
                timeout = 0.1
            })

            if err then
                ngx.log(ngx.ERR, "new queue error: ", err)
            end

            --blocked
            local co = ngx.thread.spawn(function()
                for i = 1, 6 do
                    local v, err = queue:pop()
                    if err then
                        ngx.log(ngx.ERR, "pop returns err ", err)
                    end
                end
            end)
            ngx.sleep(0.01)
            for i = 1, 6 do
                local ok, err = queue:push(i)
                if err then
                    ngx.log(ngx.ERR, "push returns err ", err)
                end
            end
            ngx.thread.wait(co)
            ngx.say("all checks done")
        }
    }
--- request
GET /t
--- no_error_log
[error]
--- response_body
all checks done


=== TEST 3: push and pop return instantly
--- http_config eval: $::HttpConfig
--- config
    location = /t {
        content_by_lua_block {
            local ringq = require("resty.queue")
            local queue, err = ringq.new({
                capacity = 5,
                blocked = true,
                timeout = 0.01
            })

            if err then
                ngx.log(ngx.ERR, "new queue error: ", err)
            end

            --blocked
            local co = ngx.thread.spawn(function()
                ngx.sleep(0.1)
                while not queue:empty() do
                    local v, err = queue:pop(false)
                    if err then
                        ngx.log(ngx.ERR, "pop returns err ", err)
                    end
                end
            end)
            for i = 1, 6 do
                local ok, err = queue:push(i, false)
                if i ==  6 and err then
                    ngx.log(ngx.ERR, string.format("push returns '%s' on element %d", err, i))
                end
            end
            ngx.thread.wait(co)
        }
    }
--- request
GET /t
--- error_log
push returns 'queue is full' on element 6


=== TEST 4: clear
--- http_config eval: $::HttpConfig
--- config
    location = /t {
        content_by_lua_block {
            local ringq = require("resty.queue")
            local queue, err = ringq.new({
                capacity = 5,
                timeout = 0.01
            })

            if err then
                ngx.log(ngx.ERR, "new queue error: ", err)
            end

            for i = 1, 5 do
                queue:push(i)
            end
            
            ngx.say(string.format("size: %d, capacity: %d, is_full: %s, is_empty: %s", queue:size(), queue:capacity(), queue:full(), queue:empty()))
            queue:clear()
            ngx.say(string.format("size: %d, capacity: %d, is_full: %s, is_empty: %s", queue:size(), queue:capacity(), queue:full(), queue:empty()))

        }
    }
--- request
GET /t
--- no_error_log
[error]
--- response_body
size: 5, capacity: 5, is_full: true, is_empty: false
size: 0, capacity: 5, is_full: false, is_empty: true
