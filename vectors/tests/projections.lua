

os.execute("clear")

local initTime, finalTime
local vs = require("vectors.core")
local log = require("loglua")
local test = require("vectors.tests.TestFunctions")


test.setStart()

local vres
local v1, v2
v1 = vs.CreateVector(1, 2, 3)
v2 = vs.CreateVector(3, 2, 1)

vres = v1:projection(v2)

test.setFinal()


log("vectors:")
log("\t", v1, v2)
log()
log("Projection result: ")
log("\t",  vres)
log()
log("execution time", test.showtime())

log.show()