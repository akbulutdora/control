package main

import "core:fmt"
import "core:testing"
import rl "vendor:raylib"

@(test)
smoke_test :: proc(t: ^testing.T) {
	testing.expect(t, 1 == 1, "One is one")
}

WINDOW_WIDTH :: 1200
WINDOW_HEIGHT :: 675
BG_COLOR :: rl.DARKGREEN

PLAYER_WIDTH :: 30
PLAYER_HEIGHT :: 80
PLAYER_INITIAL_POSX :: WINDOW_WIDTH / 2 - PLAYER_WIDTH / 2
PLAYER_INITIAL_POSY :: PLAYER_HEIGHT + 20
PLAYER_COLOR :: rl.MAROON
PLAYER_SPEED_X :: 200
PLAYER_JUMP_ACC :: -500

GROUND_Y :: 200
GRAVITY_ACC :: 800

Vector2 :: #type rl.Vector2

SHOW_PLAYER_DEBUG_INFO := true
PLAYER_DEBUG_INFO_POSX :: WINDOW_WIDTH - 300
PLAYER_DEBUG_INFO_POSY :: 10
PLAYER_DEBUG_INFO_FONTSIZE :: 20
PLAYER_DEBUG_INFO_COLOR :: rl.RAYWHITE

Entity :: struct {
	position: Vector2,
	size:     Vector2,
	velocity: Vector2,
	grounded: bool,
}

Player :: struct {
	using entity: Entity,
	color:        rl.Color,
}

main :: proc() {
	fmt.println("Hello Mania!")
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Mania Demo")
	defer rl.CloseWindow()

	player := Player {
		size     = {PLAYER_WIDTH, PLAYER_HEIGHT},
		position = {PLAYER_INITIAL_POSX, PLAYER_INITIAL_POSY},
		color    = PLAYER_COLOR,
	}

	game_loop: for !rl.WindowShouldClose() {
		delta_time := rl.GetFrameTime()
		rl.ClearBackground(BG_COLOR)

		{ 	// DRAW PLAYER DEBUG_INFO
			if SHOW_PLAYER_DEBUG_INFO {
				rl.DrawText(
					fmt.ctprintf(
						`
						FPS: %v
						pos.x: %6.2f,
						pos.y: %6.2f
						vel.x: %3.0f,
						vel.y: %3.0f,
						grounded: %v,
						`,
						rl.GetFPS(),
						player.position.x,
						player.position.y,
						player.velocity.x,
						player.velocity.y,
						player.grounded,
					),
					PLAYER_DEBUG_INFO_POSX,
					PLAYER_DEBUG_INFO_POSY,
					PLAYER_DEBUG_INFO_FONTSIZE,
					PLAYER_DEBUG_INFO_COLOR,
				)
			}
		}


		jumped: bool
		{ 	// HANDLE INPUT
			player.velocity.x = 0
			if rl.IsKeyDown(.A) {
				player.velocity.x -= PLAYER_SPEED_X
			}
			if rl.IsKeyDown(.D) {
				player.velocity.x += PLAYER_SPEED_X
			}

			jumped = player.grounded && rl.IsKeyPressed(.SPACE)

			if rl.IsKeyPressed(.P) {
				SHOW_PLAYER_DEBUG_INFO = !SHOW_PLAYER_DEBUG_INFO
			}
			if rl.IsKeyPressed(.R) {
				player.position = {PLAYER_INITIAL_POSX, PLAYER_INITIAL_POSY}
				player.velocity = 0
			}
		}

		{ 	// DRAW THE GROUND
			rl.DrawRectangleV({0, WINDOW_HEIGHT - GROUND_Y}, {WINDOW_WIDTH, GROUND_Y}, rl.DARKGRAY)
		}

		{ 	// MOVE AND DRAW PLAYER
			player.grounded = player.position.y + player.size.y + GROUND_Y >= WINDOW_HEIGHT

			if !player.grounded {
				player.velocity.y += GRAVITY_ACC * delta_time
			} else {
				player.velocity.y = 0
				player.position.y = WINDOW_HEIGHT - GROUND_Y - player.size.y
			}
			if jumped && player.grounded {
				player.velocity.y = PLAYER_JUMP_ACC
			}
			player.position += player.velocity * delta_time
			rl.DrawRectangleV(player.position, player.size, player.color)
		}

		rl.EndDrawing()

		if rl.IsKeyPressed(.Q) {
			break game_loop
		}
	}
}
