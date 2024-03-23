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

PLAYER_WIDTH :: TILE_SIZE
PLAYER_HEIGHT :: TILE_SIZE * 3
PLAYER_INITIAL_POSX :: WINDOW_WIDTH / 2 - PLAYER_WIDTH / 2
PLAYER_INITIAL_POSY :: PLAYER_HEIGHT + 20
PLAYER_COLOR :: rl.MAROON
PLAYER_SPEED_X :: 200
PLAYER_JUMP_ACC :: -500

GRAVITY_ACC :: 800

Vector2 :: #type rl.Vector2

SHOW_PLAYER_DEBUG_INFO := true
PLAYER_DEBUG_INFO_POSX :: WINDOW_WIDTH - 600
PLAYER_DEBUG_INFO_POSY :: 10
PLAYER_DEBUG_INFO_FONTSIZE :: 20
PLAYER_DEBUG_INFO_COLOR :: rl.RAYWHITE

SHOW_TILE_GRID := true

Entity :: struct {
	position: Vector2,
	size:     Vector2,
	velocity: Vector2,
	grounded: bool,
}

Player :: struct {
	using entity:   Entity,
	color:          rl.Color,
	colliding_tile: ^Tile,
}

TILE_SIZE :: 30
Tile :: struct {
	position: Vector2,
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

	tiles: [dynamic]Tile
	for i in 0 ..< WINDOW_WIDTH / TILE_SIZE {
		append(&tiles, Tile{{f32(i) * TILE_SIZE, WINDOW_HEIGHT - TILE_SIZE}})
	}

	for i in 0 ..< WINDOW_WIDTH / (TILE_SIZE * 2) {
		append(&tiles, Tile{{f32(i) * TILE_SIZE, WINDOW_HEIGHT - 2 * TILE_SIZE}})
	}
	game_loop: for !rl.WindowShouldClose() {
		delta_time := rl.GetFrameTime()
		rl.BeginDrawing()
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
						colliding tile: %v,
						`,
						rl.GetFPS(),
						player.position.x,
						player.position.y,
						player.velocity.x,
						player.velocity.y,
						player.grounded,
						player.colliding_tile,
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

			if rl.IsKeyPressed(.T) {
				SHOW_TILE_GRID = !SHOW_TILE_GRID
			}
		}

		// Draw Platform Tiles
		for tile in tiles {
			rl.DrawRectangleV(tile.position, {TILE_SIZE, TILE_SIZE}, rl.DARKBLUE)
		}

		if (SHOW_TILE_GRID) {
			// Draw Tile Grid
			for x in 0 ..= WINDOW_WIDTH / TILE_SIZE {
				for y in 1 ..= WINDOW_HEIGHT / TILE_SIZE + 1 {
					rect := rl.Rectangle {
						f32(x * TILE_SIZE),
						f32(WINDOW_HEIGHT - y * TILE_SIZE),
						TILE_SIZE,
						TILE_SIZE,
					}
					rl.DrawRectangleLinesEx(rect, 0.5, rl.GRAY)
				}
			}
		}

		player_bottom_center := Vector2 {
			player.position.x + player.size.x / 2,
			player.position.y + player.size.y,
		}

		{ 	// MOVE AND DRAW PLAYER
			player.colliding_tile = nil
			player.grounded = false
			player_direction := player.velocity.x / abs(player.velocity.x)
			player_top, player_bottom: Vector2
			tile_top, tile_bottom: Vector2
			collision_point: Vector2

			for &tile in tiles {
				if rl.CheckCollisionPointRec(
					   player_bottom_center,
					   rl.Rectangle{tile.position.x, tile.position.y, TILE_SIZE, TILE_SIZE},
				   ) {
					fmt.printfln("Collidng tile %d", tile)
					player.grounded = true
					player.colliding_tile = &tile
				} else if rl.CheckCollisionLines(
					   player_top,
					   player_bottom,
					   tile_top,
					   tile_bottom,
					   &collision_point,
				   ) {
					fmt.println("TODO(dora): check collision on x axis")
				}
			}

			switch {
			case !player.grounded:
				player.velocity.y += GRAVITY_ACC * delta_time
			case jumped && player.grounded:
				player.grounded = false
				player.velocity.y = PLAYER_JUMP_ACC
				player.colliding_tile = nil
			case player.grounded:
				player.velocity.y = 0
			}

			player.position = player.position + player.velocity * delta_time
			if (player.colliding_tile != nil) {
				player.position.y = player.colliding_tile.position.y - player.size.y
			}
			rl.DrawRectangleV(player.position, player.size, player.color)
			rl.DrawRectangleV(player_bottom_center, {1, 10}, rl.BLACK)
		}

		rl.EndDrawing()

		if rl.IsKeyPressed(.Q) {
			break game_loop
		}
	}
}
