-- Copyright (C) zht Inc.
local access = require "kong.plugins.timesign4hmac.access"


local HMACAuthHandler = {
  PRIORITY = 1000,
  VERSION = "2.2.0",
}


function HMACAuthHandler:access(conf)
  access.execute(conf)
end


return HMACAuthHandler
