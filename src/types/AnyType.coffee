import CustomType from './CustomType'

class AnyType extends CustomType
	# no arguments
	argsMin: 0
	argsMax: 0
	constructor: -> super(arguments...)
	validate: (val) -> true
	getTypeName: -> "any type"

export default CustomType.createHelper(AnyType)