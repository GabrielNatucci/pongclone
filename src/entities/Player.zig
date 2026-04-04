const c = @import("../c.zig").c;
const SCREEN_WIDTH = @import("../main.zig").WIDTH;
const SCREEN_HEIGHT = @import("../main.zig").HEIGHT;
const Ball = @import("Ball.zig").Ball;

const PLAYER_HEIGHT: c_int = 100;
const PLAYER_WIDTH: c_int = 20;

pub const Player = struct {
    x: c_int,
    y: c_int,

    pub fn init(x: c_int, y: c_int) !Player {
        return .{
            .x = x,
            .y = y,
        };
    }

    pub fn tick(self: *Player, delta: c_int) !void {
        const keyboardState = c.SDL_GetKeyboardState(null);

        if (keyboardState[c.SDL_SCANCODE_W] != 0) {
            self.y -= 1 * delta;

            if (self.y - PLAYER_HEIGHT / 2 < 0) {
                self.y = PLAYER_HEIGHT / 2;
            }
        }

        if (keyboardState[c.SDL_SCANCODE_S] != 0) {
            self.y += 1 * delta;

            if (self.y + PLAYER_HEIGHT / 2 > SCREEN_HEIGHT) {
                self.y = SCREEN_HEIGHT - PLAYER_HEIGHT / 2;
            }
        }
    }

    pub fn render(self: Player, renderer: *c.SDL_Renderer) void {
        _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);

        var rect: c.SDL_Rect = .{ .x = self.x - @divTrunc(PLAYER_WIDTH, 2), .y = self.y - @divTrunc(PLAYER_HEIGHT, 2), .w = PLAYER_WIDTH, .h = PLAYER_HEIGHT };
        _ = c.SDL_RenderFillRect(renderer, &rect);
    }

    pub fn isHittingPLayer(self: Player, ball: Ball) bool {
        const ball_x = @as(c_int, @intFromFloat(ball.x));
        const ball_y = @as(c_int, @intFromFloat(ball.y));
        const ball_w: c_int = 10;
        const ball_h: c_int = 10;

        const player_left = self.x - @divTrunc(PLAYER_WIDTH, 2);
        const player_right = self.x + @divTrunc(PLAYER_WIDTH, 2);
        const player_top = self.y - @divTrunc(PLAYER_HEIGHT, 2);
        const player_bottom = self.y + @divTrunc(PLAYER_HEIGHT, 2);

        const ball_left = ball_x - @divTrunc(ball_w, 2);
        const ball_right = ball_x + @divTrunc(ball_w, 2);
        const ball_top = ball_y - @divTrunc(ball_h, 2);
        const ball_bottom = ball_y + @divTrunc(ball_h, 2);

        return player_left <= ball_right and player_right >= ball_left and player_top <= ball_bottom and player_bottom >= ball_top;
    }

    pub fn deinit(self: *Player) !void {
        _ = self;
    }
};
