const SCREEN_WIDTH = @import("../main.zig").WIDTH;
const SCREEN_HEIGTH = @import("../main.zig").HEIGHT;
const Ball = @import("Ball.zig").Ball;

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
    pub fn isHittingPLayer(self: Enemy, ball: Ball) bool {
        const ball_x = @as(c_int, @intFromFloat(ball.x));
        const ball_y = @as(c_int, @intFromFloat(ball.y));
        const ball_w: c_int = 10;
        const ball_h: c_int = 10;

        const player_left = self.x - @divTrunc(WIDTH, 2);
        const player_right = self.x + @divTrunc(WIDTH, 2);
        const player_top = self.y - @divTrunc(HEIGHT, 2);
        const player_bottom = self.y + @divTrunc(HEIGHT, 2);

        const ball_left = ball_x - @divTrunc(ball_w, 2);
        const ball_right = ball_x + @divTrunc(ball_w, 2);
        const ball_top = ball_y - @divTrunc(ball_h, 2);
        const ball_bottom = ball_y + @divTrunc(ball_h, 2);

        return player_left <= ball_right and player_right >= ball_left and player_top <= ball_bottom and player_bottom >= ball_top;
    }

    pub fn deinit(self: *Enemy) !void {
        _ = self;
    }
};
