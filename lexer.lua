local lexer = {}

function lexer.tokenize(input)
    local tokens = {}

    local patterns = {
        {"SCOPE", "^local"},
        {"SCOPE", "^global"},
        {"TYPE", "^int"},
        {"TYPE", "^auto"},
        {"TYPE", "^string"},
        {"TYPE", "^void"},
        {"KEYWORD", "^let"},
        {"KEYWORD", "^functionlocal"},
        {"KEYWORD", "^functionglobal"},
        {"KEYWORD", "^println"},
        {"KEYWORD", "^print"},
        {"STRING", "^\"[^\"]*\""},
        {"IDENT", "^%a[%w_]*"},
        {"COLON", "^:"},
        {"EQUALS", "^="},
        {"NUMBER", "^%d+"},
        {"WHITESPACE", "^%s+", true},
        {"LPAREN", "^%("},
        {"RPAREN", "^%)"},
        {"LBRACE", "^{"},
        {"RBRACE", "^}"},
        {"COMMA", "^,"},
        {"ARROW", "^->"},
        {"SEMICOLON", "^;"},
        {"NEWLINE", "^\n"}
    }

    local i = 1
    while i <= #input do
        local substring = input:sub(i)
        local matched = false

        for _, pattern in ipairs(patterns) do
            local token_type, pattern_str, skip = pattern[1], pattern[2], pattern[3]
            local match = substring:match(pattern_str)

            if match then
                if skip then
                    i = i + #match
                    matched = true
                    break
                end

                table.insert(tokens, {type = token_type, value = match})
                i = i + #match
                matched = true
                break
            end
        end

        if not matched then
            error("Unexpected token at: " .. substring)
        end
    end

    return tokens
end

return lexer