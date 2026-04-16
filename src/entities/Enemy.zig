const SCREEN_WIDTH = @import("../main.zig").WIDTH;
const SCREEN_HEIGTH = @import("../main.zig").HEIGHT;
const Ball = @import("Ball.zig").Ball;

const std = @import("std");
const c = @import("../c.zig").c;
pub const HEIGHT: c_int = 100;
pub const WIDTH: c_int = 20;
pub const SPEED: c_int = 2;

pub const Enemy = struct {
    x: c_int,
    y: c_int,
    target: c_int,

    pub fn init(x: c_int, y: c_int) !Enemy {
        return .{ .x = x, .y = y, .target = SCREEN_HEIGTH / 2 - HEIGHT / 2 };
    }

    pub fn tick(self: *Enemy, delta: c_int, ball: Ball) !void {
        if ((ball.angle > 270 and ball.angle <= 360) or (ball.angle > 0 and ball.angle < 90)) { // se a bola está indo na direção do inimigo
            const angle_ball = ball.angle * std.math.pi / 180.0;
            const distance = @as(f32, @floatFromInt(self.x)) - ball.x;
            const svy = @tan(angle_ball) * distance + ball.y;

            self.target = @intFromFloat(svy);

            if (self.target > self.y) {
                self.y += SPEED * delta;

                if (self.y + HEIGHT / 2 > SCREEN_HEIGTH) {
                    self.y = SCREEN_HEIGTH - HEIGHT / 2;
                }
            } else if (self.target < self.y) {
                self.y -= SPEED * delta;

                if (self.y - HEIGHT / 2 < 0) {
                    self.y = HEIGHT / 2;
                }
            }
        }
    }

    pub fn render(self: Enemy, renderer: *c.SDL_Renderer) void {
        _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);

        var rect: c.SDL_Rect = .{ .x = self.x - @divTrunc(WIDTH, 2), .y = self.y - @divTrunc(HEIGHT, 2), .w = WIDTH, .h = HEIGHT };
        _ = c.SDL_RenderFillRect(renderer, &rect);
    }

    pub fn isHittingEnemy(self: Enemy, ball: Ball) bool {
        const ball_x = @as(c_int, @intFromFloat(ball.x));
        const ball_y = @as(c_int, @intFromFloat(ball.y));
        const ball_w: c_int = 10;
        const ball_h: c_int = 10;

        const enemy_left = self.x - @divTrunc(WIDTH, 2);
        const enemy_right = self.x + @divTrunc(WIDTH, 2);
        const enemy_top = self.y - @divTrunc(HEIGHT, 2);
        const enemy_bottom = self.y + @divTrunc(HEIGHT, 2);

        const ball_left = ball_x - @divTrunc(ball_w, 2);
        const ball_right = ball_x + @divTrunc(ball_w, 2);
        const ball_top = ball_y - @divTrunc(ball_h, 2);
        const ball_bottom = ball_y + @divTrunc(ball_h, 2);

        return enemy_left <= ball_right and enemy_right >= ball_left and enemy_top <= ball_bottom and enemy_bottom >= ball_top;
    }

    pub fn deinit(self: *Enemy) !void {
        _ = self;
    }
};
