const c = @import("../c.zig").c;
const SCREEN_WIDTH = @import("../main.zig").WIDTH;
const SCREEN_HEIGHT = @import("../main.zig").HEIGHT;

const std = @import("std");
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

            if (self.y + PLAYER_HEIGHT/2 > SCREEN_HEIGHT) {
                self.y = SCREEN_HEIGHT - PLAYER_HEIGHT / 2;
            }
        }
    }

    pub fn render(self: Player, renderer: *c.SDL_Renderer) void {
        _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);

        var rect: c.SDL_Rect = .{ .x = self.x - @divTrunc(PLAYER_WIDTH, 2), .y = self.y - @divTrunc(PLAYER_HEIGHT, 2), .w = PLAYER_WIDTH, .h = PLAYER_HEIGHT };
        _ = c.SDL_RenderFillRect(renderer, &rect);
    }

    pub fn deinit(self: *Player) !void {
        _ = self;
    }
};
