const std = @import("std");
const c = @import("c.zig").c;

const Player = @import("entities/Player.zig").Player;

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        return;
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("My pong game", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, 1280, 720, 0);
    if (window == null) {
        return;
    }
    defer c.SDL_DestroyWindow(window.?);

    const renderer = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED | c.SDL_RENDERER_PRESENTVSYNC);

    if (renderer == null) {
        return;
    }
    defer c.SDL_DestroyRenderer(renderer);

    var isRunning = true;

    var player = try Player.init(40, 720/2);

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

        player.render(renderer.?);

        c.SDL_RenderPresent(renderer);
    }

    try player.deinit();
}
