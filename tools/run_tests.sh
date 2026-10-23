#!/usr/bin/env bash
# Runs all headless tests in tests/ (every test_*.gd except test_base.gd).
# Usage, from the project folder: tools/run_tests.sh
set -u
cd "$(dirname "$0")/.."

godot --headless --path . --import > /dev/null 2>&1

failed=0
for test in tests/test_*.gd; do
	[ "$(basename "$test")" = "test_base.gd" ] && continue
	echo "=== $test ==="
	godot --headless --path . --script "res://$test" 2>&1 | grep -E '^\[|RESULT|ERROR'
	[ "${PIPESTATUS[0]}" -ne 0 ] && failed=1
done

[ "$failed" -eq 0 ] && echo "ALL TESTS PASSED" || echo "SOME TESTS FAILED"
exit "$failed"
