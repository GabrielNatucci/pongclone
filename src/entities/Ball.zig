const std = @import("std");
const c = @import("../c.zig").c;

const HEIGHT: c_int = 10;
const WIDTH: c_int = 10;

pub const Ball = struct {
    x: c_int,
    y: c_int,

    pub fn init(x: c_int, y: c_int) !Ball {
        return .{
            .x = x,
            .y = y,
        };
    }

    pub fn tick(self: *Ball, delta: c_int) !void {
        _ = self;
        _ = delta;
    }

    pub fn render(self: Ball, renderer: *c.SDL_Renderer) void {
        _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);

        var rect: c.SDL_Rect = .{ .x = self.x - @divTrunc(WIDTH, 2), .y = self.y - @divTrunc(HEIGHT, 2), .w = WIDTH, .h = HEIGHT };
        _ = c.SDL_RenderFillRect(renderer, &rect);
    }

    pub fn deinit(self: *Ball) !void {
        _ = self;
    }
};
