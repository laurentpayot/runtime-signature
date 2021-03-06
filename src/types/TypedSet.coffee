import Type from './Type'
import isValid from '../isValid'
import {isAny, isLiteral, getTypeName} from '../tools'

class CheckedTypedSet extends Set
	# NB: cannot use @type argument as sets would store is inside data as a key-value pair
	constructor: (type, set) ->
		super([set...])
		# overwriting add() inside constructor to use its type and set parameters
		@add = (val, context="", aliasName="") =>
			Type.error((if context then context + ' ' else '') +
						(if aliasName then aliasName + ' ' else '') +
						"set element", val, type) unless isValid(type, val)
			set.add(val) # to have side effects
			super.add(val)

class TypedSet extends Type
	# exactly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@type) ->
		super(arguments...)
		Type.invalid "You cannot have #{getTypeName(@type)} as '#{@constructor.name}' argument." if isLiteral(@type)
		Type.warn "Use 'Set' type instead of a #{@constructor.name} with elements of any type." if isAny(@type)
	validate: (val) -> switch
		when not (val instanceof Set) then false
		when isAny(@type) then true
		else [val...].every((e) => isValid(@type, e))
	getTypeName: -> "set of '#{getTypeName(@type)}'"
	# NB: https://stackoverflow.com/questions/43927933/why-is-set-incompatible-with-proxy
	#new Proxy(set,
	#	# https://stackoverflow.com/questions/43236329/why-is-proxy-to-a-map-object-in-es2015-not-working/43236808#43236808
	#	get: (s, k, receiverProxy) =>
	#		ret = Reflect.get(s, k, receiverProxy)
	#		if ret is Set.prototype.add
	#			(v) => if isValid(@type, v) then s.add(v) else Type.error("set element", v, @type)
	#		else ret)
	checkWrap: (set, context) ->
		# super(set, context)
		# custom instantiation validation
		unless @validate(set)
			super(set, context) unless set instanceof Set
			s = new CheckedTypedSet(@type, new Set())
			s.add(e, context, @aliasName) for e in [set...]
		new CheckedTypedSet(@type, set)

export default Type.createHelper(TypedSet)
