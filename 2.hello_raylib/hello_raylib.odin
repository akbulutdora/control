package main

import "core:fmt"
import t "core:time"
import rl "vendor:raylib"

WINDOW_WIDTH :: 1200
WINDOW_HEIGHT :: 720

FPS: i32 : 60

PLAYER_HEIGHT :: 30
PLAYER_WIDTH :: 30
PLAYER_POS_X: i32 = WINDOW_WIDTH / 2 - PLAYER_WIDTH / 2
PLAYER_POS_Y: i32 = WINDOW_HEIGHT - PLAYER_HEIGHT - 50
PLAYER_DX := 0
PLAYER_DY := 0
PLAYER_SPEED :: 500

Direction :: enum {
	LEFT,
	RIGHT,
}

LINE_COLOR :: rl.DARKGRAY
LINE_HEIGHT :: 60
Line :: struct {
	pos_y:               i32,
	direction:           Direction,
	speed:               i32,
	cars:                [dynamic]Car,
	last_car_spawned_at: t.Time,
}

CAR_HEIGHT :: PLAYER_HEIGHT
CAR_WIDTH :: PLAYER_WIDTH * 2
Car :: struct {
	color:        rl.Color,
	pos_x, pos_y: i32,
}

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "CONTROL")
	rl.SetTargetFPS(FPS)
	defer rl.CloseWindow()

	lines: [dynamic]Line
	append(
		&lines,
		Line{pos_y = WINDOW_HEIGHT - LINE_HEIGHT - 200, speed = 200, cars = make([dynamic]Car)},
	)
	append(
		&lines,
		Line {
			pos_y = WINDOW_HEIGHT - 2 * LINE_HEIGHT - 200,
			speed = 200,
			cars = make([dynamic]Car),
		},
	)
	append(
		&lines,
		Line {
			pos_y = WINDOW_HEIGHT - 3 * LINE_HEIGHT - 200,
			speed = 400,
			cars = make([dynamic]Car),
		},
	)

	game_loop: for !rl.WindowShouldClose() {
		delta_time := rl.GetFrameTime()
		fmt.printfln("Current delta_time: %f", delta_time)
		// Handle user input
		using rl.KeyboardKey

		PLAYER_DY = 0
		if rl.IsKeyDown(.W) do PLAYER_DY = -PLAYER_SPEED
		if rl.IsKeyDown(.S) do PLAYER_DY = PLAYER_SPEED

		PLAYER_DX = 0
		if rl.IsKeyDown(.A) do PLAYER_DX = -PLAYER_SPEED
		if rl.IsKeyDown(.D) do PLAYER_DX = PLAYER_SPEED

		if rl.IsKeyPressed(.Q) do break game_loop

		PLAYER_POS_Y += i32(f32(PLAYER_DY) * delta_time)
		PLAYER_POS_X += i32(f32(PLAYER_DX) * delta_time)

		for &line, idx in lines {
			rl.DrawRectangle(0, line.pos_y, WINDOW_WIDTH, LINE_HEIGHT, LINE_COLOR)
			// will i spawn a car
			if t.duration_seconds(t.since(line.last_car_spawned_at)) >= 3 {
				append(
					&line.cars,
					Car {
						pos_x = line.direction == Direction.RIGHT ? 0 : WINDOW_WIDTH - CAR_WIDTH,
						color = rl.YELLOW,
					},
				)
				line.last_car_spawned_at = t.now()
			}

			// draw all cars
			for car in &line.cars {
				car.pos_x += i32(
					f32(line.direction == Direction.LEFT ? -line.speed : line.speed) * delta_time,
				)

				rl.DrawRectangle(
					car.pos_x,
					line.pos_y + LINE_HEIGHT / 2 - CAR_HEIGHT / 2,
					CAR_WIDTH,
					CAR_HEIGHT,
					car.color,
				)
			}

			if idx != len(lines) - 1 {
				rl.DrawRectangle(0, line.pos_y, WINDOW_WIDTH, 5, rl.WHITE)
			}
		}

		rl.DrawRectangle(PLAYER_POS_X, PLAYER_POS_Y, PLAYER_WIDTH, PLAYER_HEIGHT, rl.RED)


		rl.BeginDrawing()
		rl.ClearBackground(rl.DARKBLUE)
		rl.EndDrawing()
	}
}
