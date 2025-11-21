
os.execute("clear")

local ms = require("matrix.core")
local log = require("loglua")
local test = require("matrix.tests.TestFunctions")


test.setStart()
-- criação das matrizes
local matrix1 = ms.CreateNullMatrix(2, 4)

test.setFinal()

log("tempo de criação: ", test.showtime())
log(matrix1)

log.show()