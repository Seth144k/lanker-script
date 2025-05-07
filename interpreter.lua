local interpreter = {}

function interpreter:load()
    self.keywords = {}
    self.symbolTable = {
        global = {},
        local_ = {},
        functions = {}
    }
    self:registerFunction("println", {"auto"}, "void", function(args)
        print(args[1])
    end)
    self:registerFunction("print", {"auto"}, "void", function(args)
        -- print without making a new line
        io.write(args[1])
    end)
end

function interpreter:evaluateStatement(stmt)
    local handler = self.keywords[stmt.keyword]
    if handler then
        return handler(self, stmt)
    else
        error("Unknown keyword: " .. tostring(stmt.keyword))
    end
end

function interpreter:registerFunction(name, params, returnType, body)
    self.symbolTable.global[name] = {
        params = params,
        returnType = returnType,
        body = body
    }
end

function interpreter:interpret(tokens)
    local i = 1

    local function current()
        return tokens[i]
    end

    local function advance()
        i = i + 1
    end

    while i <= #tokens do
        if current().type == "SEMICOLON" then
            advance()

        elseif current().type == "KEYWORD" and current().value == "let" then
            advance()

            local scope = "global"
            local scopeToken = current()
            if scopeToken.type == "SCOPE" then
                scope = scopeToken.value == "local" and "local_" or "global"
                advance()
            end

            local nameToken = current()
            if nameToken.type ~= "IDENT" then
                error("Expected variable name")
            end
            local varName = nameToken.value
            advance()

            if current().type ~= "COLON" then
                error("Expected ':'")
            end
            advance()

            local varType = "auto"
            local typeToken = current()
            if typeToken.type == "TYPE" then
                varType = typeToken.value
                advance()
            end

            if current().type ~= "EQUALS" then
                error("Expected '='")
            end
            advance()

            local valueToken = current()
            local value, inferredType
            if valueToken.type == "NUMBER" then
                value = tonumber(valueToken.value)
                inferredType = "int"
            elseif valueToken.type == "STRING" then
                value = valueToken.value:sub(2, -2)
                inferredType = "string"
            else
                error("Expected a number or string value")
            end
            advance()

            if varType == "auto" then
                varType = inferredType
            end

            self.symbolTable[scope][varName] = {
                type = varType,
                value = value
            }

            print("Defined " .. scope .. " variable '" .. varName .. "' with type '" .. varType .. "' = " .. tostring(value))

            if current().type ~= "SEMICOLON" then
                error("Expected ';' after statement")
            end
            advance()

        elseif current().type == "KEYWORD" and current().value == "functionlocal" then
            advance()

            local funcNameToken = current()
            if funcNameToken.type ~= "IDENT" then
                error("Expected function name")
            end
            local funcName = funcNameToken.value
            advance()

            if current().type ~= "LPAREN" then
                error("Expected '('")
            end
            advance()

            local params = {}
            while current().type ~= "RPAREN" do
                if current().type ~= "IDENT" then
                    error("Expected parameter name")
                end
                table.insert(params, current().value)
                advance()

                if current().type == "COMMA" then
                    advance()
                elseif current().type ~= "RPAREN" then
                    error("Expected ',' or ')'")
                end
            end
            advance()

            if current().type ~= "ARROW" then
                error("Expected '->'")
            end
            advance()

            local returnType = "void"
            if current().type == "TYPE" then
                returnType = current().value
                advance()
            else
                error("Expected return type after '->'")
            end

            if current().type ~= "LBRACE" then
                error("Expected '{' to start function body")
            end
            advance()

            local body = {}
            while current() and current().type ~= "RBRACE" do
                table.insert(body, current().value)
                advance()
            end

            if not current() or current().type ~= "RBRACE" then
                error("Expected '}' to close function body")
            end
            advance()

            self.symbolTable.functions[funcName] = {
                params = params,
                returnType = returnType,
                body = body
            }

            print("Defined local function '" .. funcName .. "' with return type '" .. returnType .. "' and parameters: " .. table.concat(params, ", "))

            if current() and current().type == "SEMICOLON" then
                advance()
            end
        elseif current().type == "KEYWORD" and current().value == "functionglobal" then
            advance()

            local funcNameToken = current()
            if funcNameToken.type ~= "IDENT" then
                error("Expected function name")
            end
            local funcName = funcNameToken.value
            advance()

            if current().type ~= "LPAREN" then
                error("Expected '('")
            end
            advance()

            local params = {}
            while current().type ~= "RPAREN" do
                if current().type ~= "IDENT" then
                    error("Expected parameter name")
                end
                table.insert(params, current().value)
                advance()

                if current().type == "COMMA" then
                    advance()
                elseif current().type ~= "RPAREN" then
                    error("Expected ',' or ')'")
                end
            end
            advance()

            if current().type ~= "ARROW" then
                error("Expected '->'")
            end
            advance()

            local returnType = "void"
            if current().type == "TYPE" then
                returnType = current().value
                advance()
            else
                error("Expected return type after '->'")
            end

            if current().type ~= "LBRACE" then
                error("Expected '{' to start function body")
            end
            advance()

            local body = {}
            while current() and current().type ~= "RBRACE" do
                table.insert(body, current().value)
                advance()
            end

            if not current() or current().type ~= "RBRACE" then
                error("Expected '}' to close function body")
            end
            advance()

            self.symbolTable.global[funcName] = {
                params = params,
                returnType = returnType,
                body = body
            }

            print("Defined global function '" .. funcName .. "' with return type '" .. returnType .. "' and parameters: " .. table.concat(params, ", "))

            if current() and current().type == "SEMICOLON" then
                advance()
            end
        elseif current().type == "KEYWORD" or current().type == "IDENT" then
            local funcName = current().value
            local func = self.symbolTable.global[funcName]
        
            if func and type(func.body) == "function" then
                advance()
        
                if current().type ~= "LPAREN" then
                    error("Expected '(' after function name")
                end
                advance()
        
                local args = {}
                while current().type ~= "RPAREN" do
                    if current().type ~= "STRING" and current().type ~= "NUMBER" then
                        error("Expected string or number as argument to function '" .. funcName .. "'")
                    end
                    local val = current().type == "STRING" and current().value:sub(2, -2) or tonumber(current().value)
                    table.insert(args, val)
                    advance()
        
                    if current().type == "COMMA" then
                        advance()
                    elseif current().type ~= "RPAREN" then
                        error("Expected ',' or ')'")
                    end
                end
                advance()
        
                func.body(args)
        
                if current().type ~= "SEMICOLON" then
                    error("Expected ';' after function call")
                end
                advance()
            else
                error("Unexpected token or undefined function: " .. tostring(funcName))
            end
        else
            error("Unexpected token: " .. current().type .. " (" .. tostring(current().value) .. ")")
        end
    end
end

return interpreter