package deniz

import "core:testing"
import "tan"

@(test)
test_taskme :: proc(t: ^testing.T) {
	testing.expect(t, DORA == tan.REKIN - 5, "One is one")
}

main :: proc() {}
