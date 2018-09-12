{Type, InvalidTypeError, createHelper} = require '.'
{isType, isAnyType, typeName} = require '..'

class Tuple extends Type
	constructor: (@types...) ->
		super() # needed
		throw new InvalidTypeError "Tuple must have at least two type arguments." if arguments.length < 2
		return Array(types.length) if @types.every((t) -> isAnyType(t)) # return needed
	validate: (val) ->
		return false unless Array.isArray(val) and val.length is @types.length
		val.every((e, i) => isType(e, @types[i]))
	typeName: ->
		"tuple of #{@types.length} elements '#{(typeName(t) for t in @types).join(", ")}'"

module.exports = createHelper(Tuple)

