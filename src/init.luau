--!strict
const Players = game:GetService("Players")

local RateLimiter = {}
RateLimiter.__index = RateLimiter

type PlayerData = {
	requests: number,
	lastRequestTime: number,
	tokens: number,
	lastUpdateTime: number,
}

type RateLimiterData = {
	_Players: { [Player]: PlayerData },
	_MaxRequests: number,
	_LimitType: "Token" | "HardCap",
	_TokenRefillRate: number,
	_PlayerRemovingConnection: RBXScriptConnection?,
}

export type RateLimiter = typeof(setmetatable({} :: RateLimiterData, RateLimiter))

function RateLimiter.new(maxRequests: number, limitType: "Token" | "HardCap", tokenRefillRate: number?): RateLimiter
	assert(maxRequests > 0, "maxRequests must be greater than 0")
	assert(tokenRefillRate == nil or tokenRefillRate > 0, "tokenRefillRate must be greater than 0 if provided")
	
	local self = setmetatable({} :: RateLimiterData, RateLimiter) :: RateLimiter

	self._Players = {}
	self._MaxRequests = maxRequests
	self._LimitType = limitType
	self._TokenRefillRate = tokenRefillRate or 1

	self._PlayerRemovingConnection = Players.PlayerRemoving:Connect(function(player: Player)
		self._Players[player] = nil
	end)

	return self
end

function RateLimiter.CanRequest(self: RateLimiter, player: Player): boolean
	local playerData = self._Players[player]

	if not playerData then
		local currentTime = os.clock()
		playerData = {
			requests = 0,
			lastRequestTime = currentTime,
			tokens = self._MaxRequests,
			lastUpdateTime = currentTime,
		}

		self._Players[player] = playerData
	end

	if self._LimitType == "HardCap" then
		local currentTime = os.clock()
		if currentTime - playerData.lastRequestTime >= 1 then
			playerData.requests = 0
			playerData.lastRequestTime = currentTime
		end

		if playerData.requests < self._MaxRequests then
			playerData.requests += 1
			return true
		else
			return false
		end
	elseif self._LimitType == "Token" then
		local currentTime = os.clock()
		local timeElapsed = currentTime - playerData.lastUpdateTime

		local tokensToAdd = timeElapsed * self._TokenRefillRate
		playerData.tokens = math.min(playerData.tokens + tokensToAdd, self._MaxRequests)
		playerData.lastUpdateTime = currentTime

		if playerData.tokens >= 1 then
			playerData.tokens -= 1
			return true
		end

		return false
	end

	return false
end

function RateLimiter.Destroy(self: RateLimiter)
	if self._PlayerRemovingConnection then
		self._PlayerRemovingConnection:Disconnect()
		self._PlayerRemovingConnection = nil
	end

	self._Players = {}
end

return RateLimiter
