CustomType = require './CustomType'
{isAnyType} = require '.'

class Or extends CustomType
	constructor: (@types...) ->
		super(arguments, 2) # 2 or more arguments
		CustomType.warn "AnyType is inadequate as '#{@helperName}'
						argument number #{i+1}." for t, i in @types when isAnyType(t)
		# return needed to always return an array instead of a new Or instance
		return @types
	helperName: "or"

module.exports = CustomType.createHelper(Or)
