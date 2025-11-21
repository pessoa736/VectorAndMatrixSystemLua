
os.execute("clear")

local ms = require("matrix.core")
local log = require("loglua")
local test = require("matrix.tests.TestFunctions")

-- criação das matrizes
local matrix1 = ms.CreateNullMatrix(3, 1)
local matrix2 = ms.CreateNullMatrix(1, 3)
log("matrix1: \n", matrix1)
log("matrix2: \n", matrix2)

--- iniciar o time para ver o tempo que demora para fazer a multiplicação
test.setStart()

local result1 = matrix1 * matrix2

-- termina o time
test.setFinal()

log("tempo de multiplicação1: ", test.showtime())
log("resultado1: \n", result1)

test.setStart()
local result2 = matrix2 * matrix1
test.setFinal()

log("tempo de multiplicação2: ", test.showtime())
log("resultado2: \n", result2)
log.show()