

os.execute("clear")

local vs = require("vectors.core")
local log = require("loglua")
local test = require("vectors.tests.TestFunctions")

local vres
local v1, v2
        v1 = vs.CreateVector(1, 2, 4,5,6, 3)
        v2 = vs.CreateVector(3, 2,4,5,6, 3)




local status = test:reapeatTest(
    50000,
    function()
        vres = v1:projection(v2)
    end
)




log("vectors:")
log("\t", v1, v2)
log()
log("Projection result: ")
log("\t",  vres)
log()
log("numero de iterações: ", 50000)
log("tempo em media de subdivisão: ", status.med)
log("tempo maximo de subdivisão: ", status.max)
log("tempo minimo de subdivisão: ", status.min)
log()
log("execution time", test.showtime())

log.show()