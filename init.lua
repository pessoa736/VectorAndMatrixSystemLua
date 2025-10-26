package.path = package.path .. ";./?/init.lua"

local V = require "vectors"
local M = require "matrix"

return {
	matrix = M,
	vectors = V
}