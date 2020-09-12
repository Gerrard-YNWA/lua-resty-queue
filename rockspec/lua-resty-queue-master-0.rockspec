package = "lua-resty-queue"
version = "master-0"
source = {
   url = "git+https://github.com/Gerrard-YNWA/lua-resty-queue.git",
   branch = "master"
}
description = {
   summary = "lua-resty-queue, event driven ring queue implemented by ngx semaphore.",
   homepage = "https://github.com/Gerrard-YNWA/lua-resty-queue",
   license = "Apache License 2.0",
   maintainer = "Gerrard-YNWA <gyc.ssdut@gmail.com>"
}
build = {
   type = "builtin",
   modules = {
      ["resty.queue"] = "lib/resty/queue.lua"
   }
}
