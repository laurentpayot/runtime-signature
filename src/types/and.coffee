import Type from './Type'
import isValid from '../isValid'
import {isAny, isLiteral, getTypeName} from '../tools'

class And extends Type
	# 2 or more arguments
	argsMin: 2
	constructor: (@types...) ->
		super(arguments...)
		for t, i in @types
			Type.invalid "You cannot have #{getTypeName(t)} as '#{@helperName}' argument number #{i+1}." if isLiteral(t)
			Type.warn "Any is not needed as '#{@helperName}' argument number #{i+1}." if isAny(t)
	validate: (val) -> @types.every((t) -> isValid(t, val))
	getTypeName: -> (getTypeName(t) for t in @types).join(" and ") # NB: no quotes around `and` operands
	helperName: "and"

export default Type.createHelper(And)
