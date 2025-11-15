package.path = package.path .. ";./?/init.lua"

local V = require "vectors.core"
local M = require "matrix.core"

return {
	matrix = M,
	vectors = V
}