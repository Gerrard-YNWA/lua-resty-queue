package = "lua-resty-queue"
version = "0.2-0"
source = {
   url = "git+https://github.com/Gerrard-YNWA/lua-resty-queue.git",
   tag = "v0.2"
}
description = {
   summary = "lua-resty-queue, event driven ring queue for Openresty.",
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
