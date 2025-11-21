os.execute("clear")

local initTime, finalTime
local vs = require("vectors.core")
local log = require("loglua")
local test= require("vectors.tests.TestFunctions")


test.setStart()

local v1, vres 

v1 = vs.CreateVector(1, 2)
vres = v1:Cross()

test.setFinal()

log("vectors 2D:")
log("\t", v1)
log()
log("Projection result: ")
log("\t",  vres)
log()
log("execution time", test.showtime())

log.show()