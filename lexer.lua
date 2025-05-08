local lexer = {}

function lexer:tokenize(input)
    local tokens = {}
    local i = 1
    while i <= #input do
        local char = input:sub(i, i)

        -- Check for opening and closing parentheses
        if char == "(" or char == ")" then
            table.insert(tokens, char)
            i = i + 1
        -- Skip whitespace
        elseif char:match("%s") then
            i = i + 1
        -- Check for numbers
        elseif char:match("%d") then
            local number = input:match("^(%d+)", i)
            table.insert(tokens, number)
            i = i + #number
        -- Check for operators
        elseif char:match("[%+%-*/]") then  -- Match operators: +, -, *, /
            table.insert(tokens, char)
            i = i + 1
        else
            error("Unexpected character: " .. char)
        end
    end
    return tokens
end

return lexer
