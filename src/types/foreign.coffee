import Type from './Type'
import isValid from '../isValid'
import {isEmptyObject} from '../tools'

class Foreign extends Type
	# exacly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@type) ->
		super(arguments...)
		unless typeof @type is 'string' or @type?.constructor is Object and not isEmptyObject(@type)
			Type.invalid "'#{@helperName}' argument must be a string or a non-empty object."
	validate: (val) -> val?.constructor?.name is @type or Object.keys(@type).every((k) => isValid(val[k], @type[k]))
	getTypeName: -> "foreign type #{if typeof @type is 'string' then @type else 'with typed properties'}"
	helperName: "foreign"

export default Type.createHelper(Foreign)

