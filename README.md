# RateLimiter

A lightweight Roblox rate limiter with independent limits for each player. Use it on the server to limit remote requests or repeated actions.

## Installation

Add this to your Wally dependencies, run `wally install`, and map `Packages` into your Rojo project:

```toml
[dependencies]
RateLimiter = "grunionnn/ratelimiter@1.0.0"
```

## Usage

This example assumes `Packages` is in `ReplicatedStorage`:

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RateLimiter = require(ReplicatedStorage.Packages.RateLimiter)

-- Allow a burst of 10 requests, refilling 2 tokens per second.
local limiter = RateLimiter.new(10, "Token", 2)

ReplicatedStorage.Action.OnServerEvent:Connect(function(player)
	if not limiter:CanRequest(player) then
		return
	end

	-- Handle the allowed action here.
end)
```

Replace `Action` with your RemoteEvent.

## API

- `RateLimiter.new(maxRequests, limitType, tokenRefillRate?)` creates a limiter. Use a positive integer for `maxRequests`.
- `"Token"` starts each player with a full bucket. Each allowed request spends one token. Tokens refill up to `maxRequests` at the specified rate, which defaults to 1 token per second.
- `"HardCap"` allows up to `maxRequests` in each player's fixed one-second window. The refill rate is unused. Requests can burst across window boundaries, so this is not a rolling-second limit.
- `limiter:CanRequest(player)` returns whether the request is allowed and consumes allowance when it succeeds.
- `limiter:Destroy()` disconnects cleanup and clears player data. Call it when finished and stop using that limiter.

Player data is automatically removed when a player leaves. Each limiter instance tracks its own limits.

## Types

The module exports `RateLimiter.RateLimiter`. For named types through Wally's generated wrappers, run [wally-package-types](https://github.com/JohnnyMorganz/wally-package-types) in your consuming project after installation:

```sh
rojo sourcemap default.project.json --output sourcemap.json
wally-package-types --sourcemap sourcemap.json Packages/
```

## License

[MIT](LICENSE) by Grunionnn.
