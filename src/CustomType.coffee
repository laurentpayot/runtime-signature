class InvalidType extends Error

s = (n) -> if n is 1 then '' else 's'

class CustomType
	# static methods
	@error: (msg) -> throw new InvalidType msg
	@warn: (msg) -> console.warn("Floweret type:", msg) unless process?.env.NODE_ENV is 'production'
	@createHelper: (childClass) ->
		h = -> new childClass(arguments...)
		h.rootClass = CustomType
		h
	error: -> CustomType.error(arguments...)
	warn: -> CustomType.warn(arguments...)
	constructor: (args, min, max) ->
		@error "Abstract class 'CustomType' cannot be instantiated directly." if @constructor is CustomType
		@error "Super needs child type arguments as its first argument." unless arguments.length
		l = args.length
		name = @helperName or @constructor.name
		switch
			when max is undefined
				if min and l < min then @error "'#{name}' must have at least #{min} argument#{s(min)}."
			when min is max
				if min is 0 and l then @error "'#{name}' cannot have any arguments."
				if l isnt min then @error "'#{name}' must have exactly #{min} argument#{s(min)}."
			else
				if l > max then @error "'#{name}' must have at most #{max} argument#{s(max)}."
				if l < min then @error "'#{name}' must have at least #{min} argument#{s(min)}."
	validate: -> false # false if child class validate() missing
	getTypeName: -> @constructor.name


module.exports = CustomType
