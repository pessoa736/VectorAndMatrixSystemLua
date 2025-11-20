
os.execute("clear")

local ms = require("matrix.core")
local log = require("loglua")
local test = require("matrix.tests.TestFunctions")
local reault

-- criação das matrizes1
local matrix1 = ms
    .CreateMatrix(3,2)
    .data(
        1, 2,
        2, 5,
        3, 6
    )


-- criação das matrizes2
local matrix2 = ms
    .CreateMatrix(3,2)
    .data(
        1, 9,
        10, 5,
        5, 6
    )


log("matrix1: \n" .. matrix1)
log("matrix2: \n" .. matrix2)

local status = test:reapeatTest(50000, function ()
    reault = matrix1 - matrix2
end)

test.setFinal()

log("numero de iterações: ", 50000)
log("tempo em media de subtração: ", status.med)
log("tempo maximo de subtração: ", status.max)
log("tempo minimo de subtração: ", status.min)
log()
log("resultado: \n" .. reault)

log.show()