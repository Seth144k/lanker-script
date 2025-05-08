local node = require("parser.nodes")

local parser = {}

function parser:parse(tokens)
    local i = 1

    local function current() return tokens[i] end
    local function advance() i = i + 1 end

    local nodes = {}

    while i <= #tokens do
        local token = current()

        if token.type == "KEYWORD" and token.value == "let" then
            advance()
            local scope = current().value
            advance()
            local name = current().value
            advance()
            advance() -- skip ':'
            local varType = current().value
            advance()
            advance() -- skip '='
            local value = current()
            advance()
            table.insert(nodes, node.VariableDeclaration(scope, name, varType, value))
        else
            error("Unhandled token")
        end
    end

    return nodes
end

return parser