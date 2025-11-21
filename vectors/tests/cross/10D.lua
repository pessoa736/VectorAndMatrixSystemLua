os.execute("clear")


local unpack = table.unpack
local random = math.random

local initTime, finalTime
local vs = require("vectors.core")
local log = require("loglua")
local test = require("vectors.tests.TestFunctions")

print("wait 8s")
--- criando os vetores aleatorios de 10D
local d = {}
local v = {}
local n = 10
for i = 1, n-1 do
  d = {}
  for j = 1, n do
    d[j] = random(-10, 10)
  end
  v[i] = vs.CreateVector(unpack(d)) 
end 

local vm = {unpack(v)}
table.remove(vm, 1)


--- o test
local vres
local status = test:reapeatTest(
  10,
  function()
    vres = v[1]:Cross(unpack(vm))
  end
)

log("vectors 10D:")
for i=1, 10 do log("\t", v[i]) end

log()
log("Projection result: ")
log("\t", vres)
log()
log("numero de iterações: ", 10)
log("tempo em media de subdivisão: ", status.med)
log("tempo maximo de subdivisão: ", status.max)
log("tempo minimo de subdivisão: ", status.min)
log()
log("execution time", test.showtime())

log.show()