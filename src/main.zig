const std = @import("std");
const c = @import("c.zig").c;

pub const WIDTH: c_int = 1280;
pub const HEIGHT: c_int = 720;

const Player = @import("entities/Player.zig").Player;
const Enemy = @import("entities/Enemy.zig").Enemy;
const Ball = @import("entities/Ball.zig").Ball;

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        return;
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("My pong game", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, WIDTH, HEIGHT, 0);
    if (window == null) {
        return;
    }
    defer c.SDL_DestroyWindow(window.?);

    const renderer = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED | c.SDL_RENDERER_PRESENTVSYNC);
    if (renderer == null) {
        return;
    }
    defer c.SDL_DestroyRenderer(renderer);
    _ = c.SDL_RenderSetLogicalSize(renderer, WIDTH, HEIGHT);

    var isRunning = true;

    var player = try Player.init(40, HEIGHT / 2);
    var enemy = try Enemy.init(WIDTH - 40, HEIGHT / 2);
    var ball = try Ball.init(WIDTH / 2, HEIGHT / 2);
    var lastTime = c.SDL_GetTicks();

    while (isRunning) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => isRunning = false,
                else => {},
            }
        }

        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        _ = c.SDL_RenderClear(renderer);
        _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);

        const delta: c_int = @intCast(c.SDL_GetTicks() - lastTime);
        try player.tick(delta);
        try enemy.tick(delta);
        try ball.tick(delta);

        lastTime = c.SDL_GetTicks();
        player.render(renderer.?);
        enemy.render(renderer.?);
        ball.render(renderer.?);

        c.SDL_RenderPresent(renderer);
    }

    try player.deinit();
    try enemy.deinit();
    try ball.deinit();
}
