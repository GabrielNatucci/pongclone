const SCREEN_WIDTH = @import("../main.zig").WIDTH;
const SCREEN_HEIGHT = @import("../main.zig").HEIGHT;
const std = @import("std");
const c = @import("../c.zig").c;

pub const Scoreboard = struct {
    playerScore: u4,
    enemyScore: u4,
    scoreLimit: u4,
    hasUpdated: bool = true,
    textTexture: ?*c.SDL_Texture,

    pub fn init() Scoreboard {
        return .{
            .playerScore = 0,
            .enemyScore = 0,
            .scoreLimit = 3,
            .textTexture = undefined,
        };
    }

    pub fn tick(self: *Scoreboard, allocator: std.mem.Allocator) !void {
        _ = allocator;
        if (self.hasUpdated) {
        }
    }

    pub fn render(self: Scoreboard, renderer: *c.SDL_Renderer) !void {
        _ = self;
        _ = renderer;
    }

    pub fn addPlayerPoint(self: *Scoreboard) !void {
        self.playerScore += 1;
        self.hasUpdated = true;
    }

    pub fn addEnemyPoint(self: *Scoreboard) !void {
        self.enemyScore += 1;
        self.hasUpdated = true;
    }
};
