import {getTypeName, valueType, isEmptyObject} from './tools'
import isValid from './isValid'
import Type from './types/Type'

# returns a list of keys path to the mismatched type + value not maching + type not matching
badPath = (obj, typeObj) ->
	for k, t of typeObj
		return [k, obj, typeObj[k]] if isEmptyObject(obj)
		# second or clause in case key not in obj and type is undefined
		if not isValid(t, obj[k]) or isEmptyObject(obj[k]) and t?.constructor is Object
			return [k].concat(if obj[k]?.constructor is Object then badPath(obj[k], typeObj[k]) \
								else [obj[k], typeObj[k]])

typeError = (context, val, type, aliasName="", promised=false) -> throw new TypeError(
	if arguments.length < 2
		context
	else
		type = type.type if type instanceof Type and type.constructor.name is 'Unchecked'
		ending = switch
			when Array.isArray(val) and Array.isArray(type) and (type.length is 1 or not Object.values(type).length)
				if type.length
					if not Object.values(type).length # sized array
						"an array with a length of #{type.length} instead of #{val.length}"
					else
						i = val.findIndex((e) -> not isValid(type[0], e))
						"an array with element #{i} of type '#{getTypeName(type[0])}' instead of #{valueType(val[i])}"
				else
					"an empty array, got a non-empty array"
			when val?.constructor is Object and type?.constructor is Object
				if not isEmptyObject(type)
					[bp..., bv, bt] = badPath(val, type)
					bk = bp[bp.length - 1]
					"an object with key '#{bp.join('.')}' of type '#{getTypeName(bt)}' instead of #{\
						if bv is undefined and bk not in Object.keys(bp[...-1].reduce(((acc, curr) -> acc[curr]), val))\
							or bv?.constructor is Object and isEmptyObject(bv)\
						then "missing key '" + bk + "'" else valueType(bv)}"
				else
					"an empty object, got a non-empty object"
			else
				"#{getTypeName(type)}, got #{valueType(val)}"
		if aliasName or type instanceof Type and type.aliasName and type.constructor.name isnt 'Alias'
			ending = (aliasName or type.aliasName) + ": " + ending
		"Expected #{if context then context + ' to be ' else ''}#{if promised then 'a promise of type ' else ''}#{ending}."
)

# NB: to avoid circular dependencies, error static method is added to Type class here instead of `Type` file
Type.error = typeError

export default typeError
