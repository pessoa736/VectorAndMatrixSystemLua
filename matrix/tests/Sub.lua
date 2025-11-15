
os.execute("clear")

local ms = require("matrix.core")
local log = require("loglua")
local test = require("matrix.tests.TestFunctions")

-- criação das matrizes1
local matrix1 = ms.CreateMatrix(
    {1, 2, 3},
    {2, 5, 6},
    {3, 6, 9}
)

-- criação das matrizes2
local matrix2 = ms.CreateMatrix(
    {1, 9, 3},
    {2, 5, 6},
    {3, 6, 9}
)

log("matrix1: \n" .. matrix1)
log("matrix2: \n" .. matrix2)

test.setStart()

local reault = matrix1 - matrix2

test.setFinal()

log("tempo de subtração: ", test.showtime())
log("\n" .. reault)

log.show()