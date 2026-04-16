const SCREEN_WIDTH = @import("../main.zig").WIDTH;
const SCREEN_HEIGHT = @import("../main.zig").HEIGHT;
const std = @import("std");
const c = @import("../c.zig").c;
const WHITE: c.SDL_Color = .{ .a = 255, .r = 255, .g = 255, .b = 255 };

const Player = @import("Player.zig").Player;
const Enemy = @import("Enemy.zig").Enemy;
const Ball = @import("Ball.zig").Ball;
const whowins = @import("../constants/Enums.zig").whowins;

pub const Scoreboard = struct {
    playerScore: u4,
    enemyScore: u4,
    scoreLimit: u4,
    hasUpdated: bool = true,
    textTexture: ?*c.SDL_Texture,
    font: ?*c.TTF_Font,
    allocator: std.mem.Allocator,
    renderer: *c.SDL_Renderer,
    width: c_int,
    height: c_int,

    pub fn init(allocator: std.mem.Allocator, renderer: *c.SDL_Renderer) !Scoreboard {
        const fonte = c.TTF_OpenFont("res/font/Fenix-Regular.ttf", 20);

        if (fonte == null) {
            std.debug.print("Erro ao carregar a fenix font -> {s}\n", .{c.TTF_GetError()});
            return error.ErroAoCriarAFonteScoreBoard;
        }

        return .{
            .playerScore = 0,
            .enemyScore = 0,
            .scoreLimit = 3,
            .textTexture = undefined,
            .font = fonte,
            .allocator = allocator,
            .renderer = renderer,
            .width = 0,
            .height = 0,
        };
    }

    pub fn tick(self: *Scoreboard, wins: whowins) !void {
        if (wins == whowins.NOBODY and self.hasUpdated == false) {
            return;
        }

        if (wins == whowins.ENEMY) {
            self.addEnemyPoint();
            self.hasUpdated = true;
        }

        if (wins == whowins.PLAYER) {
            self.addPlayerPoint();
            self.hasUpdated = true;
        }

        if (self.hasUpdated) {
            self.hasUpdated = false;
            if (self.textTexture != null) {
                c.SDL_DestroyTexture(self.textTexture);
                self.textTexture = null;
            }

            const text = try std.fmt.allocPrintSentinel(self.allocator, "Player: {}  Enemy: {}", .{ self.playerScore, self.enemyScore }, 0);
            defer self.allocator.free(text);

            const surface = c.TTF_RenderText_Blended(self.font.?, text, WHITE);
            self.width = surface.*.w;
            self.height = surface.*.h;

            defer c.SDL_FreeSurface(surface);

            self.textTexture = c.SDL_CreateTextureFromSurface(self.renderer, surface);
        }
    }

    pub fn render(self: Scoreboard) !void {
        var rect: c.SDL_Rect = .{ .x = 0, .y = 0, .w = self.width, .h = self.height };
        _ = c.SDL_RenderCopy(self.renderer, self.textTexture, null, &rect);
    }

    pub fn addPlayerPoint(self: *Scoreboard) void {
        self.playerScore += 1;
        self.hasUpdated = true;
    }

    pub fn addEnemyPoint(self: *Scoreboard) void {
        self.enemyScore += 1;
        self.hasUpdated = true;
    }

    pub fn deinit(self: *Scoreboard) void {
        c.SDL_DestroyTexture(self.textTexture.?);
    }
};
