
os.execute("clear")

local ms = require("matrix.core")
local log = require("loglua")
local test = require("matrix.tests.TestFunctions")

-- criação das matrizes
local matrix1 = ms.CreateMatrix(3,3).data(
    1, 2, 3,
    2, 5, 6,
    3, 6, 9
)

local matrix2 = ms.CreateMatrix(3,3).data(
    1, 2, 3,
    2, 5, 6,
    3, 6, 9
)

log("matrix1: \n" .. matrix1)
log("matrix2: \n" .. matrix2)

local result 
local status = test:reapeatTest(50000, function ()
    result =  matrix1 + matrix2
end)


log("numero de iterações: ", 50000)
log("tempo em media de subdivisão: ", status.med)
log("tempo maximo de subdivisão: ", status.max)
log("tempo minimo de subdivisão: ", status.min)
log()
log("resultado: \n" .. result)

log.show()