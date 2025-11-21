
os.execute("clear")

local ms = require("matrix.core")
local log = require("loglua")
local test = require("matrix.tests.TestFunctions")
local result

-- criação das matrizes
local matrix1 = ms.CreateMatrix(3,3).data(
    1, 2, 3,
    2, 5, 6,
    3, 6, 9
)

log("matrix1: \n", matrix1)


local status = test:reapeatTest(50000, function ()
    result = matrix1:map(function(pos, currentValue) return currentValue - 1  end)
end)

test.setFinal()

log("numero de iterações: ", 50000)
log("tempo em media de mapeamento: ", status.med)
log("tempo maximo de mapeamento: ", status.max)
log("tempo minimo de mapeamento: ", status.min)
log()
log("resultado: \n" .. result)
log.show()