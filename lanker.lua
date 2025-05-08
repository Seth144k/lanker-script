local lexer = require("lexer")
local interpreter = require("interpreter")
local parser = require("parser.parser")

local lanker = {}

function lanker.runFile(filename)
    local file = io.open(filename, "r")
    if not file then
        error("Failed to open file: " .. filename)
    end
    local content = file:read("*a")
    file:close()
    local tokens = lexer.tokenize(content)
    interpreter:interpret(tokens)
end

return lanker