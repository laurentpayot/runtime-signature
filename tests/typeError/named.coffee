import {fn, Any} from '../../dist'
import named from '../../dist/types/named'


test "type name", ->
	f = fn named('Foo'), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be a direct instance of Foo, got Boolean true.")

test "type name not a string", ->
	expect(-> f = fn named({a: Number}), Any, ->)
	.toThrow("'named' argument must be a non-empty string.")

test "type name empty string", ->
	expect(-> f = fn named({a: Number}), Any, ->)
	.toThrow("'named' argument must be a non-empty string.")

test "named type by name aliasName", ->
	f = fn named('Bar').alias("Foo"), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be Foo: a direct instance of Bar, got Boolean true.")
