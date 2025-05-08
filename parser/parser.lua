local parser = {}

function parser:parse(tokens)
    local function parse_expr()
        local token = table.remove(tokens, 1)
        if not token then
            return nil  -- Prevent empty token errors
        end

        if token == "(" then
            local list = {}
            while tokens[1] and tokens[1] ~= ")" do
                table.insert(list, parse_expr())
            end
            if tokens[1] == ")" then
                table.remove(tokens, 1)  -- Remove the closing ')'
            end
            return list
        elseif tonumber(token) then
            return tonumber(token)  -- Convert numbers to actual number values
        else
            return token  -- Return symbol as string (e.g., operator or variable)
        end
    end

    return parse_expr()
end

return parser