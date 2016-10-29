--
-- Public domain
--
local socket = require("socket")
local ssl    = require("ssl")

local function info_cb(str_info, alert_info)
  if alert_info then
    print(string.format("alert_info[%s]->[%s]",
      tostring(alert_info[1]), tostring(alert_info[2])))
  end
  print(string.format("str_info:[%s]", tostring(str_info)))
end

local params = {
   mode = "server",
   protocol = "any",
   key = "../certs/serverAkey.pem",
   certificate = "../certs/serverA.pem",
   cafile = "../certs/rootA.pem",
   verify = {"peer", "fail_if_no_peer_cert"},
   options = "all",
   info = info_cb,
}


-- [[ SSL context
local ctx = assert(ssl.newcontext(params))
--]]

local server = socket.tcp()
server:setoption('reuseaddr', true)
assert( server:bind("127.0.0.1", 8888) )
server:listen()

local peer = server:accept()

-- [[ SSL wrapper
peer = assert( ssl.wrap(peer, ctx) )

-- Before handshake: nil
print( peer:info() )

assert( peer:dohandshake() )
--]]

print("---")
local info = peer:info()
for k, v in pairs(info) do
  print(k, v)
end

print("---")
print("-> Compression", peer:info("compression"))

peer:send("oneshot test\n")
peer:close()
