extends SceneTree
## Runs every tests/*_test.gd headless and exits with 1 if any test fails:
##   Godot --headless --path . --script res://tests/run_tests.gd

const TESTS_DIR := "res://tests/"
const AUDIO_SETTLE := 0.3


## Script errors don't stop a test, they only print, so they are caught here and count as failures.
class ErrorCatcher extends Logger:
	var errors: PackedStringArray = []
	var _mutex := Mutex.new()

	func _log_error(function: String, file: String, line: int, code: String, rationale: String,
			_editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
		if error_type == ERROR_TYPE_WARNING:
			return
		_mutex.lock()
		errors.append("%s (%s:%d in %s)" % [rationale if rationale else code, file, line, function])
		_mutex.unlock()

	func take() -> PackedStringArray:
		_mutex.lock()
		var taken := errors.duplicate()
		errors.clear()
		_mutex.unlock()
		return taken


## Deferred because nodes added during _initialize don't get _ready() until the root enters the tree.
func _initialize() -> void:
	_run_all.call_deferred()


func _run_all() -> void:
	var catcher := ErrorCatcher.new()
	OS.add_logger(catcher)
	var passed := 0
	var failed := 0

	for file in DirAccess.get_files_at(TESTS_DIR):
		if not file.ends_with("_test.gd"):
			continue
		# A script that fails to compile can't be made, and calling it would stop this function
		# before it quits, leaving Godot running.
		var script := load(TESTS_DIR + file) as GDScript
		if not script or not script.can_instantiate():
			_report_failure(file, "load", catcher.take())
			failed += 1
			continue
		var suite: Node = script.new()
		root.add_child(suite)
		suite.before_all()
		var setup_errors := catcher.take()
		if not setup_errors.is_empty():
			_report_failure(file, "before_all", setup_errors)
			failed += 1

		for method in suite.get_method_list():
			var test_name: String = method.name
			if not test_name.begins_with("test_"):
				continue
			suite.failures.clear()
			suite.call(test_name)
			var problems: PackedStringArray = suite.failures + catcher.take()
			if problems.is_empty():
				passed += 1
			else:
				_report_failure(file, test_name, problems)
				failed += 1
		suite.after_all()
		var teardown_errors := catcher.take()
		if not teardown_errors.is_empty():
			_report_failure(file, "after_all", teardown_errors)
			failed += 1
		suite.free()

	OS.remove_logger(catcher)
	print("%d passed, %d failed" % [passed, failed])
	# The audio thread lets go of a freed player's sound a moment later; quitting at once reports
	# it as leaked.
	await create_timer(AUDIO_SETTLE).timeout
	quit(1 if failed > 0 else 0)


func _report_failure(file: String, test_name: String, problems: PackedStringArray) -> void:
	print("FAIL %s %s" % [file.get_basename(), test_name])
	for problem in problems:
		print("    " + problem)
