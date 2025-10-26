rockspec_format = "3.0"

package = "VMSL"
version = "1.0-1"
source = {
   url = "git+https://github.com/pessoa736/VectorAndMatrixSystemLua"
}
description = {
   summary = "Biblioteca Lua para vetores e matrizes em N dimensões. API de módulos Lua (require), experimental.",
   detailed = [[
      Vector and Matrix System (Lua) — lib simples para criar e manipular
      vetores e matrizes matemáticas em N dimensões. Foco em usos práticos
      (jogos/simulações). As interfaces ainda estão em evolução; não há API
      estável por enquanto. Tipo de API: módulos Lua acessados via `require`.
      Projeto em desenvolvimento.
   ]],
   homepage = "https://github.com/pessoa736/VectorAndMatrixSystemLua",
   license = "MIT"
}
dependencies = {
   "lua >= 5.2"
}
build = {
   type = "builtin",
   modules = {
      VMSL = "init.lua",
      vectors = "vectors/init.lua",
      matrix = "matrix/init.lua"
   }
}