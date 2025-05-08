return {
    FunctionDeclaration = function(name, params, returnType, body)
        return {type = "FunctionDeclaration", name = name, params = params, returnType = returnType, body = body}
    end,

    VariableDeclaration = function(scope, name, varType, value)
        return {type = "VariableDeclaration", scope = scope, name = name, varType = varType, value = value}
    end,

    FunctionCall = function(name, args)
        return {type = "FunctionCall", name = name, args = args}
    end,

    Literal = function(value, valueType)
        return {type = "Literal", value = value, valueType = valueType}
    end
}