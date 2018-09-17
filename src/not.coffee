CustomType = require './CustomType'
{isType, isAnyType} = require '.'

class Not extends CustomType
	constructor: (@type) ->
		super(arguments, 1, 1) # exactly 1 argument
		CustomType.warn "AnyType is inadequate as '#{@helperName}' argument." if isAnyType(@type)
	validate: (val) -> not isType(val, @type)
	helperName: "not"

module.exports = CustomType.createHelper(Not)