
const c = @import("../c.zig").c;
const SCREEN_WIDTH = @import("../main.zig").WIDTH;
const SCREEN_HEIGTH = @import("../main.zig").HEIGHT;

const std = @import("std");
const HEIGHT: c_int = 10;
const WIDTH: c_int = 10;

pub const Ball = struct {
    x: f32,
    y: f32,
    speed: f32,
    angle: f32,

    pub fn init(x: c_int, y: c_int) !Ball {
        return .{
            .x = @floatFromInt(x),
            .y = @floatFromInt(y),
            .speed = 0.5,
            .angle = 100,
        };
    }

    pub fn tick(self: *Ball, delta: c_int) !void {
        const angle_rad = self.angle * std.math.pi / 180.0;

        const svy = @sin(angle_rad) * self.speed;
        const svx = @cos(angle_rad) * self.speed;

        self.x += svx * @as(f32, @floatFromInt(delta));
        self.y += svy * @as(f32, @floatFromInt(delta));

        const half_height = @as(f32, @floatFromInt(HEIGHT)) / 2.0;

        if (self.y + half_height > SCREEN_HEIGTH) {
            self.y = 2 * (SCREEN_HEIGTH - half_height) - self.y;
            self.angle = 360 - self.angle;
        }

        if (self.y - half_height < 0) {
            self.y = 2 * half_height - self.y;
            self.angle = 360 - self.angle;
        }
    }

    pub fn render(self: Ball, renderer: *c.SDL_Renderer) void {
        _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);

        var rect: c.SDL_Rect = .{
            .x = @as(c_int, @intFromFloat(self.x)) - @divTrunc(WIDTH, 2),
            .y = @as(c_int, @intFromFloat(self.y)) - @divTrunc(HEIGHT, 2),
            .w = WIDTH,
            .h = HEIGHT,
        };
        _ = c.SDL_RenderFillRect(renderer, &rect);
    }

    pub fn deinit(self: *Ball) !void {
        _ = self;
    }
};
