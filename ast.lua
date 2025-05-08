local nodes = require("parser.nodes")

local ast = {}

function ast:eval(expr, node)
    if type(expr) == "number" then
        return expr
    elseif type(expr) == "string" then
        return node[expr]  -- Lookup variable (if needed)
    elseif type(expr) == "table" then
        local fn = nodes[expr[1]]  -- Get the operator function from nodes
        if not fn then
            error("Unknown operator: " .. expr[1])
        end
        
        -- Evaluate the arguments of the operator
        local args = {}
        for i = 2, #expr do
            table.insert(args, self:eval(expr[i], node))
        end

        -- Apply the operator function to the evaluated arguments
        return fn(table.unpack(args))
    end
end

return ast