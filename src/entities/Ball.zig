const c = @import("../c.zig").c;
const SCREEN_WIDTH = @import("../main.zig").WIDTH;
const SCREEN_HEIGTH = @import("../main.zig").HEIGHT;
const whowins = @import("../constants/Enums.zig").whowins;

const std = @import("std");
const HEIGHT: c_int = 10;
const WIDTH: c_int = 10;
const Player = @import("Player.zig").Player;
const Enemy = @import("Enemy.zig").Enemy;

const PLAYERS_HEIGHT = @import("Player.zig").PLAYER_HEIGHT;
const PLAYERS_WIDTH = @import("Player.zig").PLAYER_WIDTH;

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
            .angle = 180,
        };
    }

    pub fn tick(self: *Ball, delta: c_int, player: Player, enemy: Enemy) !whowins {
        const angle_rad = self.angle * std.math.pi / 180.0;
        const fdelta = @as(f32, @floatFromInt(delta));

        self.x += @cos(angle_rad) * self.speed * fdelta;
        self.y += @sin(angle_rad) * self.speed * fdelta;

        const half_height = @as(f32, @floatFromInt(HEIGHT)) / 2.0;

        if (self.y + half_height > SCREEN_HEIGTH) {
            self.y = 2 * (SCREEN_HEIGTH - half_height) - self.y;
            self.angle = 360 - self.angle;
        } else if (self.y - half_height < 0) {
            self.y = 2 * half_height - self.y;
            self.angle = 360 - self.angle;
        }

        if (player.isHittingPLayer(self.*)) {
            const hit_pos = (self.y - @as(f32, @floatFromInt(player.y))) / @as(f32, @floatFromInt(PLAYERS_HEIGHT));
            self.angle = hit_pos * 120;
        } else if (enemy.isHittingEnemy(self.*)) {
            const hit_pos = (self.y - @as(f32, @floatFromInt(enemy.y))) / @as(f32, @floatFromInt(PLAYERS_HEIGHT));
            self.angle = 180 - (hit_pos * 120);
        }

        // por algum motivo a direção da bola está ficando com um angulo negativo ou maior do que 360
        // alguma as operações acima deve estar causando isso, mas zig é dificil de debugar e estou com preguiça de descobrir rs
        // me perdoai deus por mais uma gambiarra.. faz mto tempo que não estudo trigonometria
        if (self.angle < 0) {
            self.angle = 360 + self.angle;
        } else if (self.angle > 360) {
            self.angle = self.angle - 360;
        }

        if ((self.x - WIDTH / 2) > SCREEN_WIDTH) {
            return whowins.PLAYER;
        } else if (self.x - WIDTH / 2 < 0) {
            return whowins.ENEMY;
        }

        return whowins.NOBODY;
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
