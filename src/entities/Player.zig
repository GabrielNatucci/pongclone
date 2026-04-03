const std = @import("std");
const c = @import("../c.zig").c;

const HEIGHT: c_int = 100;
const WIDTH: c_int = 20;

pub const Player = struct {
    x: c_int,
    y: c_int,

    pub fn init(x: c_int, y: c_int) !Player {
        return .{
            .x = x,
            .y = y,
        };
    }
    
    pub fn tick(self: *Player) !void {
        const keyboardState = c.SDL_GetKeyboardState(null);

        if (keyboardState[c.SDL_SCANCODE_W] != 0) {
            self.y -= 5;
        }

        if (keyboardState[c.SDL_SCANCODE_S] != 0) {
            self.y += 5;
        }
    }

    pub fn render(self: Player, renderer: *c.SDL_Renderer) void {
        _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);

        var rect: c.SDL_Rect = .{ .x = self.x, .y = self.y - @divTrunc(HEIGHT, 2), .w = WIDTH, .h = HEIGHT };
        _ = c.SDL_RenderFillRect(renderer, &rect);
    }

    pub fn deinit(self: *Player) !void {
        _ = self;
    }
};
