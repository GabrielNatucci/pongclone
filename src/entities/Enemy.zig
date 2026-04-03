const std = @import("std");
const c = @import("../c.zig").c;

const HEIGHT: c_int = 100;
const WIDTH: c_int = 20;

pub const Enemy = struct {
    x: c_int,
    y: c_int,

    pub fn init(x: c_int, y: c_int) !Enemy {
        return .{
            .x = x,
            .y = y,
        };
    }

    pub fn tick(self: *Enemy, delta: c_int) !void {
        _ = self;
        _ = delta;
    }

    pub fn render(self: Enemy, renderer: *c.SDL_Renderer) void {
        _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);

        var rect: c.SDL_Rect = .{ .x = self.x - @divTrunc(WIDTH, 2), .y = self.y - @divTrunc(HEIGHT, 2), .w = WIDTH, .h = HEIGHT };
        _ = c.SDL_RenderFillRect(renderer, &rect);
    }

    pub fn deinit(self: *Enemy) !void {
        _ = self;
    }
};
