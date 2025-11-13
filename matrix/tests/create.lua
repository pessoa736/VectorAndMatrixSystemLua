
os.execute("clear")

local initTime, finalTime
local ms = require("matrix.core")
local log = require("loglua")
local test = require("vectors.tests.TestFunctions")


test.setStart()
-- criação das matrizes
local matrix1 = ms.CreateMatrix(
    {1, 2, 3},
    {2, 5, 6},
    {3, 6, 9}
)

test.setFinal()

log("tempo de criação: ", test.showtime())
log(matrix1)

log.show()