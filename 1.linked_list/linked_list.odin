package main

import "core:fmt"

Node :: struct {
	next: ^Node,
	data: int,
}

do_plain_linked_list :: proc() {
	head := new(Node)
	head.data = 1
	head.next = new(Node)
	head.next.data = 2

	fmt.println(head^)
	fmt.println(head^.next^)
	fmt.println(head.next^)

	for current := head; current != nil; {
		next := current.next
		free(current)
		current = next
	}

	fmt.println("DONE!")
}

main :: proc() {
	i : f32 = 5.2
	fmt.println(i)

	fmt.println(i % 3)
	
	do_plain_linked_list()
}
