extends Node
## Base for files named *_test.gd. tests/run_tests.gd adds each one to the tree, calls
## before_all(), then every method whose name starts with test_, then after_all().
##
## Assertions record a failure and carry on, because GDScript has no exceptions to stop a test.

var failures: PackedStringArray = []


func before_all() -> void:
	pass


func after_all() -> void:
	pass


func fail(message: String) -> void:
	failures.append(message)


func assert_true(condition: bool, message: String) -> void:
	if not condition:
		fail(message)


func assert_false(condition: bool, message: String) -> void:
	if condition:
		fail(message)


func assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		fail("%s: expected %s, got %s" % [message, expected, actual])


func assert_near(actual: float, expected: float, tolerance: float, message: String) -> void:
	if absf(actual - expected) > tolerance:
		fail("%s: expected %s ± %s, got %s" % [message, expected, tolerance, actual])
