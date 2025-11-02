os.execute("clear")


local unpack = table.unpack
local random = math.random

local initTime, finalTime
local vs = require("vectors.core")
local log = require("loglua")
local test = require("vectors.tests.TestFunctions")

print("wait 8s")

test.setStart()
local d = {}
local v = {}
local n = 10
for i = 1, n-1 do
  d = {}
  for j = 1, n do
    d[j] = random(-2, 2)
  end
  v[i] = vs.CreateVector(unpack(d)) 
end 

local vm = {unpack(v)}
table.remove(vm, 1)


local vres = v[1]:Cross(unpack(vm))
test.setFinal()

log("vectors 10D:")
log("\t", unpack(v))
log()
log("Projection result: ")
log("\t", vres)
log()
log("execution time", test.showtime())

log.show()