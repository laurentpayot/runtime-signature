import {instance} from '../../dist'

test "init", ->
	Trio = Array(3)
	a = instance Trio, [1, true, 'three']
	expect(a).toEqual([1, true, 'three'])

test "set", ->
	Trio = Array(3)
	a = instance Trio, [1, true, 'three']
	a[1] = 2
	expect(a).toEqual([1, 2, 'three'])

test "trow an error with a non-array type", ->
	Trio = Array(3)
	expect(-> a = instance Trio, 1)
	.toThrow("Instance should be of type 'array of 3 elements' instead of Number 1.")

test "trow an error with a too long array", ->
	Trio = Array(3)
	expect(-> a = instance Trio, [1, true, 3, 4])
	.toThrow("Instance should be an array with a length of 3 instead of 4.")

test "trow an error with a too short array", ->
	Trio = Array(3)
	expect(-> a = instance Trio, [1, true])
	.toThrow("Instance should be an array with a length of 3 instead of 2.")

test "trow an error after a push", ->
	Trio = Array(3)
	a = instance Trio, [1, true, 'three']
	expect(-> a.push(4))
	.toThrow("Sized array instance must have a length of 3.")

test "trow an error after a pop", ->
	Trio = Array(3)
	a = instance Trio, [1, true, 'three']
	expect(-> a.pop())
	.toThrow("Sized array instance must have a length of 3.")

describe.skip "Size 1", ->

	test "init", ->
		Mono = Array(1)
		a = instance Mono, [1]
		expect(a).toEqual([1])

	test "set", ->
		Mono = Array(1)
		a = instance Mono, [1]
		a[0] = 2
		expect(a).toEqual([2])

	test "trow an error with a non-array type", ->
		Mono = Array(1)
		expect(-> a = instance Mono, 1)
		.toThrow("Instance should be of type 'array of 1 elements' instead of Number 1.")

	test "trow an error with a too long array", ->
		Mono = Array(1)
		expect(-> a = instance Mono, [1, true])
		.toThrow("Instance should be an array with a length of 1 instead of 2.")

	test "trow an error with a too short array", ->
		Mono = Array(1)
		expect(-> a = instance Mono, [])
		.toThrow("Instance should be an array with a length of 1 instead of 0.")

	test "trow an error after a push", ->
		Mono = Array(1)
		a = instance Mono, [1]
		expect(-> a.push(2))
		.toThrow("Sized array instance must have a length of 1.")

	test "trow an error after a pop", ->
		Mono = Array(1)
		a = instance Mono, [1]
		expect(-> a.pop())
		.toThrow("Sized array instance must have a length of 1.")
