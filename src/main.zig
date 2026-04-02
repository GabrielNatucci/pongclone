const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const WINDOW_WIDTH = 800;
const WINDOW_HEIGHT = 600;
const PADDLE_WIDTH = 15;
const PADDLE_HEIGHT = 100;
const BALL_SIZE = 15;
const PADDLE_SPEED = 400.0;
const BALL_SPEED_X = 350.0;
const BALL_SPEED_Y = 350.0;

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow(
        "Zig Pong",
        c.SDL_WINDOWPOS_CENTERED,
        c.SDL_WINDOWPOS_CENTERED,
        WINDOW_WIDTH,
        WINDOW_HEIGHT,
        0,
    ) orelse {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.SDLWindowCreationFailed;
    };
    defer c.SDL_DestroyWindow(window);

    const renderer = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED | c.SDL_RENDERER_PRESENTVSYNC) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return error.SDLRendererCreationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    var player1_y: f32 = @as(f32, WINDOW_HEIGHT - PADDLE_HEIGHT) / 2.0;
    var player2_y: f32 = @as(f32, WINDOW_HEIGHT - PADDLE_HEIGHT) / 2.0;
    
    var ball_x: f32 = @as(f32, WINDOW_WIDTH - BALL_SIZE) / 2.0;
    var ball_y: f32 = @as(f32, WINDOW_HEIGHT - BALL_SIZE) / 2.0;
    var ball_vel_x: f32 = BALL_SPEED_X;
    var ball_vel_y: f32 = BALL_SPEED_Y;

    var last_time: u32 = c.SDL_GetTicks();
    var quit = false;

    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    quit = true;
                },
                else => {},
            }
        }

        const current_time = c.SDL_GetTicks();
        const delta_time: f32 = @as(f32, @floatFromInt(current_time - last_time)) / 1000.0;
        last_time = current_time;

        const keyboard_state = c.SDL_GetKeyboardState(null);

        // Player 1 (W/S)
        if (keyboard_state[c.SDL_SCANCODE_W] != 0) {
            player1_y -= PADDLE_SPEED * delta_time;
        }
        if (keyboard_state[c.SDL_SCANCODE_S] != 0) {
            player1_y += PADDLE_SPEED * delta_time;
        }

        // Player 2 (Up/Down)
        if (keyboard_state[c.SDL_SCANCODE_UP] != 0) {
            player2_y -= PADDLE_SPEED * delta_time;
        }
        if (keyboard_state[c.SDL_SCANCODE_DOWN] != 0) {
            player2_y += PADDLE_SPEED * delta_time;
        }

        // Clamp paddles
        if (player1_y < 0) player1_y = 0;
        if (player1_y > WINDOW_HEIGHT - PADDLE_HEIGHT) player1_y = WINDOW_HEIGHT - PADDLE_HEIGHT;
        if (player2_y < 0) player2_y = 0;
        if (player2_y > WINDOW_HEIGHT - PADDLE_HEIGHT) player2_y = WINDOW_HEIGHT - PADDLE_HEIGHT;

        // Update ball
        ball_x += ball_vel_x * delta_time;
        ball_y += ball_vel_y * delta_time;

        // Ball collision with top/bottom
        if (ball_y < 0) {
            ball_y = 0;
            ball_vel_y = -ball_vel_y;
        } else if (ball_y > WINDOW_HEIGHT - BALL_SIZE) {
            ball_y = WINDOW_HEIGHT - BALL_SIZE;
            ball_vel_y = -ball_vel_y;
        }

        // Ball collision with paddles
        const ball_rect = c.SDL_FRect{ .x = ball_x, .y = ball_y, .w = BALL_SIZE, .h = BALL_SIZE };
        const p1_rect = c.SDL_FRect{ .x = 50.0, .y = player1_y, .w = PADDLE_WIDTH, .h = PADDLE_HEIGHT };
        const p2_rect = c.SDL_FRect{ .x = WINDOW_WIDTH - 50.0 - PADDLE_WIDTH, .y = player2_y, .w = PADDLE_WIDTH, .h = PADDLE_HEIGHT };

        if (c.SDL_HasIntersectionF(&ball_rect, &p1_rect) == c.SDL_TRUE) {
            ball_x = 50.0 + PADDLE_WIDTH;
            ball_vel_x = -ball_vel_x;
        } else if (c.SDL_HasIntersectionF(&ball_rect, &p2_rect) == c.SDL_TRUE) {
            ball_x = WINDOW_WIDTH - 50.0 - PADDLE_WIDTH - BALL_SIZE;
            ball_vel_x = -ball_vel_x;
        }

        // Ball out of bounds (score)
        if (ball_x < 0 or ball_x > WINDOW_WIDTH) {
            ball_x = @as(f32, WINDOW_WIDTH - BALL_SIZE) / 2.0;
            ball_y = @as(f32, WINDOW_HEIGHT - BALL_SIZE) / 2.0;
            // Simple flip direction
            ball_vel_x = -ball_vel_x;
        }

        // Draw
        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        _ = c.SDL_RenderClear(renderer);

        _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);

        const p1_sdl_rect = c.SDL_Rect{ .x = 50, .y = @as(c_int, @intFromFloat(player1_y)), .w = PADDLE_WIDTH, .h = PADDLE_HEIGHT };
        const p2_sdl_rect = c.SDL_Rect{ .x = WINDOW_WIDTH - 50 - PADDLE_WIDTH, .y = @as(c_int, @intFromFloat(player2_y)), .w = PADDLE_WIDTH, .h = PADDLE_HEIGHT };
        const ball_sdl_rect = c.SDL_Rect{ .x = @as(c_int, @intFromFloat(ball_x)), .y = @as(c_int, @intFromFloat(ball_y)), .w = BALL_SIZE, .h = BALL_SIZE };

        _ = c.SDL_RenderFillRect(renderer, &p1_sdl_rect);
        _ = c.SDL_RenderFillRect(renderer, &p2_sdl_rect);
        _ = c.SDL_RenderFillRect(renderer, &ball_sdl_rect);

        c.SDL_RenderPresent(renderer);
    }
}
