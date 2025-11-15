
os.execute("clear")
local ms = require("matrix.core")
local log = require("loglua")
local test = require("matrix.tests.TestFunctions")

-- criação das matrizes
local matrix1 = ms.CreateMatrix(
    {1, 2, 3, 4},
    {2, 5, 6, 7},
    {3, 6, 9, 10},
    {11, 12, 13, 14}
)

log("matrix1: \n" .. matrix1)

--- iniciar o time para ver o tempo que demora para fazer a soma
test.setStart()
local result = matrix1:submatrix(1, 3)
-- termina o time
test.setFinal()

log("tempo de subdivisão",test.showtime())
log("result: \n" .. result)

log.show()

