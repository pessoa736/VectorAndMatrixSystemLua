
os.execute("clear")

local ms = require("matrix.core")
local log = require("loglua")
local test = require("matrix.tests.TestFunctions")

-- criação das matrizes
local matrix1 = ms.CreateMatrix(
    {1, 2, 3},
    {2, 5, 6},
    {3, 6, 9}
)

local matrix2 = ms.CreateMatrix(
    {1, 2, 3},
    {2, 5, 6},
    {3, 6, 9}
)

log("matrix1: \n" .. matrix1)
log("matrix2: \n" .. matrix2)

--- iniciar o time para ver o tempo que demora para fazer a soma
test.setStart()
local result = matrix1 + matrix2
-- termina o time
test.setFinal()

log("tempo de soma",test.showtime())
log("result: \n" .. result)

log.show()