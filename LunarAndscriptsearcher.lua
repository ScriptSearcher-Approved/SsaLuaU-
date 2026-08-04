-- LunarScripts | Modified by ScriptSearcher & LunarScripts Team
-- Original Base: Vision Hub (Deobfuscated)
if not game:IsLoaded() then
	pcall(function() game.Loaded:Wait() end)
end

-- Cleanup old instances if re-executed
if getgenv().LunarScripts_Executed and getgenv().LunarScripts_Cleanup then
	pcall(getgenv().LunarScripts_Cleanup)
end
getgenv().LunarScripts_Executed = true

-- Service Cache
local Workspace, Players, ReplicatedStorage, RunService, UserInputService, TweenService, SoundService, HttpService
local TextChatService, CoreGui, MarketplaceService, TeleportService, Stats, Lighting

do
	local cloneref = cloneref or function(...) return ... end
	local ServiceCache = setmetatable({}, {
		__index = function(self, ServiceName)
			local Success, Service = pcall(function() return cloneref(game:GetService(ServiceName)) end)
			if not Success or not Service then
				Success, Service = pcall(function() return game:GetService(ServiceName) end)
			end
			rawset(self, ServiceName, Success and Service or nil)
			return Service
		end
	})

	Workspace = ServiceCache.Workspace
	Players = ServiceCache.Players
	ReplicatedStorage = ServiceCache.ReplicatedStorage
	RunService = ServiceCache.RunService
	UserInputService = ServiceCache.UserInputService
	TweenService = ServiceCache.TweenService
	SoundService = ServiceCache.SoundService
	HttpService = ServiceCache.HttpService
	TextChatService = ServiceCache.TextChatService
	CoreGui = ServiceCache.CoreGui
	MarketplaceService = ServiceCache.MarketplaceService
	TeleportService = ServiceCache.TeleportService
	Stats = ServiceCache.Stats
	Lighting = ServiceCache.Lighting
end

-- Core Variables
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() and Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

-- Connection Manager
getgenv().LunarScripts_Connections = getgenv().LunarScripts_Connections or {}
for _, Connection in ipairs(getgenv().LunarScripts_Connections) do
	if typeof(Connection) == "RBXScriptConnection" and Connection.Connected then
		pcall(function() Connection:Disconnect() end)
	end
end
table.clear(getgenv().LunarScripts_Connections)

local function AddConnection(Connection)
	if typeof(Connection) ~= "RBXScriptConnection" then return end
	table.insert(getgenv().LunarScripts_Connections, Connection)
	return Connection
end

local function RemoveConnection(Connection)
	if not Connection then return end
	for Index, Stored in ipairs(getgenv().LunarScripts_Connections) do
		if Stored == Connection then
			table.remove(getgenv().LunarScripts_Connections, Index)
			break
		end
	end
	if typeof(Connection) == "RBXScriptConnection" and Connection.Connected then
		Connection:Disconnect()
	end
end

-- Fallen Parts Height Backup
if getgenv().FPDH then
	Workspace.FallenPartsDestroyHeight = getgenv().FPDH
end

-- Load WindUI Library
local WindUI
do
	local Success, Result = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/orialdev/vision-studios/refs/heads/main/ui.lua"))()
	end)
	if not Success then
		warn("[LunarScripts] Failed to load WindUI: " .. tostring(Result))
		return
	end
	WindUI = Result
end
print("[LunarScripts] WindUI Loaded Successfully")

-- Core Configuration Table
local Lunar = {
	Player = LocalPlayer,
	Camera = CurrentCamera,
	Players = Players,
	Workspace = Workspace,
	RunService = RunService,
	HttpService = HttpService,
	TweenService = TweenService,
	UserInputService = UserInputService,
	ReplicatedStorage = ReplicatedStorage,
	TeleportService = TeleportService,
	CoreGui = CoreGui,
	SoundService = SoundService,
	
	Config = {
		-- All Features Now Unlocked (No Premium Gating)
		GodMode = false,
		Invisible = false,
		Noclip = false,
		EnableWalkSpeed = false,
		WalkSpeed = 16,
		EnableJumpPower = false,
		JumpPower = 50,
		FlyEnabled = false,
		FlySpeed = 100,
		InfiniteJump = false,
		AntiFling = false,
		AutoGrabGun = false,
		AutoShootMurderer = false,
		WallBangEnabled = false,
		AutoWallBangEnabled = false,
		KillAllMode = "Default", -- Default/Silent (Both Free)
		KnifeAuraMode = "Default", -- Default/Silent (Both Free)
		AutoKillAll = false,
		KnifeAura = false,
		KnifeAuraRange = 20,
		SilentThrow = false,
		KnifeThrowAura = 1000,
		AutoFarmCoins = false,
		AutoFarmSpeed = 25,
		AutoFarmOffset = -5,
		AutoFarmRadius = 3000,
		AutoFarmDelay = 0.1,
		RoundTimer = false,
		NotifyGunDropped = false,
		NotifyMurderer = false,
		NotifySheriff = false,
		HighlightMurderer = false,
		InfoMurderer = false,
		BoxMurderer = false,
		TracersMurderer = false,
		SkeletonMurderer = false,
		HighlightSheriff = false,
		InfoSheriff = false,
		BoxSheriff = false,
		TracersSheriff = false,
		SkeletonSheriff = false,
		HighlightInnocent = false,
		InfoInnocent = false,
		BoxInnocent = false,
		TracersInnocent = false,
		SkeletonInnocent = false,
		ESPGunDropped = false,
		ESPColorInnocent = Color3.fromRGB(0, 255, 128),
		ESPColorMurderer = Color3.fromRGB(255, 50, 50),
		ESPColorSheriff = Color3.fromRGB(255, 215, 0), -- Lunar Gold
		ButtonsLocked = true,
	},
	PlayerData = {},
	Buttons = {},
}

-- Character Handler
do
	function Lunar:UpdateCharacter(Character)
		self.Character = Character
		if Character then
			self.Humanoid = Character:WaitForChild("Humanoid", 5)
			self.RootPart = Character:FindFirstChild("HumanoidRootPart") or Character.PrimaryPart
			self.Backpack = LocalPlayer and LocalPlayer:WaitForChild("Backpack", 5)
			self.Camera = Workspace.CurrentCamera
			
			if self.Config.Invisible then self:ToggleInvisible(true) end
			if self.Config.AutoFarmCoins then self:ToggleAutoFarm(true) end
			return
		end
		self.Humanoid = nil
		self.RootPart = nil
		self.Backpack = nil
		self.Camera = nil
	end

	if LocalPlayer.Character then Lunar:UpdateCharacter(LocalPlayer.Character) end
	AddConnection(LocalPlayer.CharacterAdded:Connect(function(Char) Lunar:UpdateCharacter(Char) end))
	AddConnection(LocalPlayer.CharacterRemoving:Connect(function() Lunar:UpdateCharacter(nil) end))
end

-- ==================== ALL PREMIUM FEATURES UNLOCKED BELOW ====================
-- (Removed CheckPremium() entirely — every feature works for everyone)

-- 1. Invisibility (Formerly Premium)
do
	local InvisibleConnection = nil
	function Lunar:ToggleInvisible(State)
		self.Config.Invisible = State
		if InvisibleConnection then
			RemoveConnection(InvisibleConnection)
			InvisibleConnection = nil
		end

		if State then
			if self.Character then
				for _, Descendant in pairs(self.Character:GetDescendants()) do
					if Descendant:IsA("BasePart") and Descendant.Name ~= "HumanoidRootPart" then
						Descendant.Transparency = 0.5
					end
				end
			end

			InvisibleConnection = AddConnection(self.RunService.Heartbeat:Connect(function()
				local Root = self.RootPart
				local Hum = self.Humanoid
				if Root and Hum and Root.Parent then
					local OriginalCFrame = Root.CFrame
					Root.CFrame = OriginalCFrame * CFrame.new(0, -200000, 0)
					Hum.CameraOffset = Vector3.new(0, 200000, 0)
					self.RunService.RenderStepped:Wait()
					if Root and Root.Parent then Root.CFrame = OriginalCFrame end
				end
			end))
			return
		end

		if self.Humanoid then self.Humanoid.CameraOffset = Vector3.zero end
		if self.Character then
			for _, Descendant in pairs(self.Character:GetDescendants()) do
				if Descendant:IsA("BasePart") and Descendant.Name ~= "HumanoidRootPart" then
					Descendant.Transparency = 0
				end
			end
		end
	end
end

-- 2. God Mode (Formerly Premium)
do
	local GodModeConnection = nil
	function Lunar:EnableGodMode(State)
		self.Config.GodMode = State
		if GodModeConnection then
			RemoveConnection(GodModeConnection)
			GodModeConnection = nil
		end

		if State then
			local function ApplyGodMode(Humanoid)
				if not Humanoid then return end
				AddConnection(Humanoid.HealthChanged:Connect(function(NewHealth)
					if Lunar.Config.GodMode and NewHealth < Humanoid.MaxHealth then
						Humanoid.Health = Humanoid.MaxHealth
					end
				end))

				task.spawn(function()
					while Lunar.Config.GodMode and Humanoid.Parent do
						if Humanoid.Health < Humanoid.MaxHealth then
							Humanoid.Health = Humanoid.MaxHealth
						end
						if Humanoid:GetState() == Enum.HumanoidStateType.Dead then
							Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
							Humanoid.Health = Humanoid.MaxHealth
						end
						task.wait(0.2)
					end
				end)
			end

			if LocalPlayer.Character then
				local Hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if Hum then ApplyGodMode(Hum) end
			end
			GodModeConnection = AddConnection(LocalPlayer.CharacterAdded:Connect(function(Char)
				local Hum = Char:WaitForChild("Humanoid", 10)
				if Hum then ApplyGodMode(Hum) end
			end))
		end
	end
end

-- 3. Wallbang (Formerly Premium)
function Lunar:WallBangShoot()
	if not self.Character or not self.RootPart or not self.Backpack then return false end
	local Gun = self.Character:FindFirstChild("Gun") or self.Backpack:FindFirstChild("Gun")
	if not Gun then return false end

	local Murderer = self:FindMurderer()
	if not Murderer or not Murderer.Character then return false end
	local TargetRoot = Murderer.Character:FindFirstChild("HumanoidRootPart")
	local TargetHum = Murderer.Character:FindFirstChild("Humanoid")
	if not TargetRoot or not TargetHum or TargetHum.Health <= 0 then return false end

	-- Prediction Calculation
	local Ping = 0.06
	local NetworkStats = Stats and Stats:FindFirstChild("Network")
	local PingValue = NetworkStats and NetworkStats:FindFirstChild("ServerStatsItem") and NetworkStats:FindFirstChild("Data Ping")
	if PingValue then Ping = PingValue:GetValue() / 1000 end
	local PredictionTime = math.clamp(Ping + 0.05, 0, 1.2)
	local TargetVelocity = TargetRoot.AssemblyLinearVelocity
	if TargetVelocity.Magnitude < 0.1 and TargetHum.MoveDirection.Magnitude > 0 then
		TargetVelocity = TargetHum.MoveDirection * TargetHum.WalkSpeed
	end
	local PredictedPosition = TargetRoot.Position + TargetVelocity * PredictionTime
	if TargetHum.FloorMaterial == Enum.Material.Air then
		PredictedPosition += Vector3.new(0, 0.5 * Workspace.Gravity * PredictionTime^2, 0)
	end

	if Gun.Parent == self.Backpack then
		Gun.Parent = self.Character
		task.wait()
	end

	local ShootRemote = Gun:FindFirstChild("Shoot")
	local KnifeLocal = Gun:FindFirstChild("KnifeLocal")
	if ShootRemote and ShootRemote:IsA("RemoteEvent") then
		task.spawn(function()
			pcall(function()
				local LookCFrame = CFrame.lookAt(self.RootPart.Position, PredictedPosition)
				ShootRemote:FireServer(LookCFrame, CFrame.new(PredictedPosition))
			end)
		end)
	elseif KnifeLocal then
		local BeamRemote = KnifeLocal:FindFirstChild("CreateBeam") and KnifeLocal.CreateBeam:FindFirstChild("RemoteFunction")
		if BeamRemote then
			task.spawn(function() pcall(function() BeamRemote:InvokeServer(1, PredictedPosition, "AH2") end) end)
		end
	end
	return true
end

function Lunar:ToggleWallBang(State)
	self.Config.AutoWallBangEnabled = State
	if State then
		task.spawn(function()
			while self.Config.AutoWallBangEnabled do
				self:WallBangShoot()
				task.wait(0.2)
			end
		end)
	end
end

-- 4. Silent Kill All & Silent Knife Aura (Formerly Premium — Now Default Options)
-- (Integrated directly into KillAll() and ToggleKnifeAura() below with no checks)

-- ==================== MOVEMENT FEATURES ====================
-- Fly
do
	local FlyConnection = nil
	local ControlModule = nil
	task.spawn(function()
		local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts", 2)
		local PlayerModule = PlayerScripts and PlayerScripts:WaitForChild("PlayerModule", 2)
		if PlayerModule then pcall(function() ControlModule = require(PlayerModule:FindFirstChild("ControlModule")) end) end
	end)

	function Lunar:ToggleFly(State)
		if State ~= nil then self.Config.FlyEnabled = State end
		if FlyConnection then
			RemoveConnection(FlyConnection)
			FlyConnection = nil
		end

		if self.RootPart then
			for _, Child in ipairs(self.RootPart:GetChildren()) do
				if Child.Name == "LunarFlyGyro" or Child.Name == "LunarFlyVel" then Child:Destroy() end
			end
			if self.Humanoid then self.Humanoid.PlatformStand = false end
		end

		if self.Config.FlyEnabled and self.Character and self.RootPart and self.Humanoid then
			local Gyro = Instance.new("BodyGyro")
			Gyro.Name = "LunarFlyGyro"
			Gyro.P = 90000
			Gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
			Gyro.CFrame = self.RootPart.CFrame
			Gyro.Parent = self.RootPart

			local Velocity = Instance.new("BodyVelocity")
			Velocity.Name = "LunarFlyVel"
			Velocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
			Velocity.Parent = self.RootPart

			FlyConnection = AddConnection(self.RunService.RenderStepped:Connect(function()
				if not self.Config.FlyEnabled then self:ToggleFly(false) return end
				if not (self.Character and self.RootPart and self.Humanoid and self.Humanoid.Health > 0) then
					self:ToggleFly(false)
					pcall(function() Gyro:Destroy() Velocity:Destroy() end)
					return
				end

				self.Humanoid.PlatformStand = true
				Gyro.CFrame = Workspace.CurrentCamera.CFrame
				local MoveVector = Vector3.zero
				pcall(function() if ControlModule then MoveVector = ControlModule:GetMoveVector() end end)
				local Vertical = 0
				if UserInputService:IsKeyDown(Enum.KeyCode.E) then Vertical = 1 end
				if UserInputService:IsKeyDown(Enum.KeyCode.Q) then Vertical = -1 end

				if MoveVector.Magnitude == 0 and Vertical == 0 then
					Velocity.Velocity = Vector3.zero
				else
					local CamCF = Workspace.CurrentCamera.CFrame
					Velocity.Velocity = 
						CamCF.RightVector * MoveVector.X * self.Config.FlySpeed +
						CamCF.LookVector * -MoveVector.Z * self.Config.FlySpeed +
						Vector3.new(0, Vertical * self.Config.FlySpeed, 0)
				end
			end))
		end
	end

	AddConnection(LocalPlayer.CharacterAdded:Connect(function(Char)
		task.spawn(function()
			local PS = LocalPlayer:WaitForChild("PlayerScripts", 2)
			local PM = PS and PS:WaitForChild("PlayerModule", 2)
			if PM then pcall(function() ControlModule = require(PM:FindFirstChild("ControlModule")) end) end
		end)
		local Hum = Char:WaitForChild("Humanoid", 10)
		local Root = Char:WaitForChild("HumanoidRootPart", 10)
		if Hum and Root then
			Lunar.Character = Char
			Lunar.RootPart = Root
			Lunar.Humanoid = Hum
			if Lunar.Config.FlyEnabled then task.wait() Lunar:ToggleFly() end
		end
	end))
end

-- Walk Speed
do
	local WalkSpeedConnection = nil
	function Lunar:EnableWalkSpeed(State)
		self.Config.EnableWalkSpeed = State
		if WalkSpeedConnection then
			RemoveConnection(WalkSpeedConnection)
			WalkSpeedConnection = nil
		end
		if not State then
			if self.Humanoid then self.Humanoid.WalkSpeed = 16 end
			return
		end
		WalkSpeedConnection = AddConnection(self.RunService.Heartbeat:Connect(function()
			if self.Humanoid and self.Humanoid.WalkSpeed ~= self.Config.WalkSpeed then
				self.Humanoid.WalkSpeed = self.Config.WalkSpeed
			end
		end))
	end
	function Lunar:SetWalkSpeed(Value)
		self.Config.WalkSpeed = math.clamp(Value, 16, 200)
		if self.Config.EnableWalkSpeed and self.Humanoid then
			self.Humanoid.WalkSpeed = self.Config.WalkSpeed
		end
	end
end

-- Jump Power
do
	local JumpPowerConnection = nil
	function Lunar:EnableJumpPower(State)
		self.Config.EnableJumpPower = State
		if JumpPowerConnection then
			RemoveConnection(JumpPowerConnection)
			JumpPowerConnection = nil
		end
		if not State then
			if self.Humanoid then self.Humanoid.JumpPower = 50 end
			return
		end
		JumpPowerConnection = AddConnection(self.RunService.Heartbeat:Connect(function()
			if self.Humanoid and self.Humanoid.JumpPower ~= self.Config.JumpPower then
				self.Humanoid.JumpPower = self.Config.JumpPower
			end
		end))
	end
	function Lunar:SetJumpPower(Value)
		self.Config.JumpPower = math.clamp(Value, 50, 300)
		if self.Config.EnableJumpPower and self.Humanoid then
			self.Humanoid.JumpPower = self.Config.JumpPower
		end
	end
end

-- Noclip
do
	local NoclipConnection = nil
	local OriginalCollisions = {}
	function Lunar:EnableNoclip(State)
		self.Config.Noclip = State
		if not State then
			if NoclipConnection then
				RemoveConnection(NoclipConnection)
				NoclipConnection = nil
			end
			for Part, Original in pairs(OriginalCollisions) do
				if Part and Part.Parent then Part.CanCollide = Original end
			end
			OriginalCollisions = {}
			return
		end

		OriginalCollisions = {}
		if self.Character then
			for _, Desc in ipairs(self.Character:GetDescendants()) do
				if Desc:IsA("BasePart") then
					OriginalCollisions[Desc] = Desc.CanCollide
					Desc.CanCollide = false
				end
			end
		end
		NoclipConnection = AddConnection(self.RunService.Stepped:Connect(function()
			if self.Character then
				for _, Desc in ipairs(self.Character:GetDescendants()) do
					if Desc:IsA("BasePart") then Desc.CanCollide = false end
				end
			end
		end))
	end
end

-- Infinite Jump
do
	local InfiniteJumpConnection = nil
	function Lunar:InfiniteJump(State)
		self.Config.InfiniteJump = State
		if InfiniteJumpConnection then
			RemoveConnection(InfiniteJumpConnection)
			InfiniteJumpConnection = nil
		end
		if State then
			InfiniteJumpConnection = AddConnection(UserInputService.JumpRequest:Connect(function()
				if self.Humanoid then self.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
			end))
		end
	end
end

-- Anti Fling
do
	local AntiFlingConnection = nil
	local CollisionCache = {}
	function Lunar:ToggleAntiFling(State)
		self.Config.AntiFling = State
		if AntiFlingConnection then
			AntiFlingConnection:Disconnect()
			AntiFlingConnection = nil
		end
		if State then
			for _, Player in ipairs(Players:GetPlayers()) do
				if Player ~= LocalPlayer and Player.Character then
					for _, Child in ipairs(Player.Character:GetChildren()) do
						pcall(function()
							if Child:IsA("BasePart") and Child.CanCollide then
								CollisionCache[Child] = Child.CanCollide
								Child.CanCollide = false
								if Child.Name == "HumanoidRootPart" then
									Child.AssemblyLinearVelocity = Vector3.zero
									Child.AssemblyAngularVelocity = Vector3.zero
								end
							end
						end)
					end
				end
			end
			AntiFlingConnection = AddConnection(self.RunService.Heartbeat:Connect(function()
				if not self.Character then return end
				for _, Player in ipairs(Players:GetPlayers()) do
					if Player ~= LocalPlayer and Player.Character then
						for _, Child in ipairs(Player.Character:GetChildren()) do
							pcall(function()
								if Child:IsA("BasePart") and Child.CanCollide then
									CollisionCache[Child] = CollisionCache[Child] or Child.CanCollide
									Child.CanCollide = false
									if Child.Name == "HumanoidRootPart" then
										Child.AssemblyLinearVelocity = Vector3.zero
										Child.AssemblyAngularVelocity = Vector3.zero
									end
								end
							end)
						end
					end
				end
			end))
			return
		end
		for Part, Original in pairs(CollisionCache) do
			if Part and Part.Parent then Part.CanCollide = Original end
		end
		CollisionCache = {}
	end
end

-- Rejoin / Server Hop
function Lunar:Rejoin()
	if TeleportService and LocalPlayer then
		pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
	end
end
function Lunar:ServerHop()
	if not TeleportService or not LocalPlayer then return end
	local Success, Data = pcall(function()
		return HttpService:JSONDecode(game:HttpGet(
			"https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
		))
	end)
	if Success and Data and Data.data then
		for _, Server in ipairs(Data.data) do
			if Server.id ~= game.JobId and Server.playing < Server.maxPlayers then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, Server.id, LocalPlayer)
				return
			end
		end
	end
	TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

-- Map Detection
local function GetMap()
	for _, Child in ipairs(Workspace:GetChildren()) do
		if (Child:FindFirstChild("CoinContainer") or Child:FindFirstChild("CoinAreas")) and Child:FindFirstChild("Spawns") then
			return Child
		end
	end
	return nil
end
local function GetLobby()
	for _, Child in ipairs(Workspace:GetChildren()) do
		if Child:FindFirstChild("Lobby") then return Child.Lobby end
		if Child.Name:lower() == "lobby" then return Child end
	end
	return nil
end

-- Teleports
function Lunar:TeleportToMap()
	local Char = self.Character or (self.RootPart and self.RootPart.Parent)
	local Map = GetMap()
	if not Char or not Map then return end
	local Spawns = Map:FindFirstChild("Spawns")
	if not Spawns then return end
	local ValidSpawns = {}
	for _, Spawn in ipairs(Spawns:GetChildren()) do
		if Spawn:IsA("BasePart") then table.insert(ValidSpawns, Spawn) end
	end
	local Target = #ValidSpawns > 0 and ValidSpawns[math.random(1, #ValidSpawns)]
		or Spawns:FindFirstChild("Spawn") or Spawns:FindFirstChild("PlayerSpawn")
	if Target and Target:IsA("BasePart") then
		Char:PivotTo(Target.CFrame * CFrame.new(0, 5, 0))
	end
end
function Lunar:TeleportToLobby()
	local Char = self.Character or (self.RootPart and self.RootPart.Parent)
	local Lobby = GetLobby()
	if not Char or not Lobby then return end
	local Spawns = Lobby:FindFirstChild("Spawns")
	if not Spawns then return end
	local ValidSpawns = {}
	for _, Spawn in ipairs(Spawns:GetChildren()) do
		if Spawn:IsA("BasePart") then table.insert(ValidSpawns, Spawn) end
	end
	local Target = #ValidSpawns > 0 and ValidSpawns[math.random(1, #ValidSpawns)]
		or Spawns:FindFirstChild("SpawnLocation")
	if Target and Target:IsA("BasePart") then
		Char:PivotTo(Target.CFrame * CFrame.new(0, 5, 0))
	end
end
function Lunar:TeleportToPlayer(Player)
	if not self.RootPart or not Player or not Player.Character or not Player.Character.PrimaryPart then return false end
	return pcall(function()
		self.Character:PivotTo(Player.Character.PrimaryPart.CFrame * CFrame.new(0, 3, 0))
	end)
end

-- Role Detection
function Lunar:GetPlayerByName(Name)
	if not Name then return nil end
	for _, Player in ipairs(Players:GetPlayers()) do
		if Player.Name:lower() == Name:lower() then return Player end
	end
	return nil
end
function Lunar:FindMurderer()
	if self.PlayerData then
		for Name, Data in pairs(self.PlayerData) do
			if Data.Role == "Murderer" then
				local Plr = self:GetPlayerByName(Name)
				if Plr then return Plr end
			end
		end
	end
	for _, Player in ipairs(Players:GetPlayers()) do
		local HasKnife = (Player.Backpack and Player.Backpack:FindFirstChild("Knife"))
			or (Player.Character and Player.Character:FindFirstChild("Knife"))
		if HasKnife then return Player end
	end
	return nil
end
function Lunar:FindSheriff()
	if self.PlayerData then
		for Name, Data in pairs(self.PlayerData) do
			if Data.Role == "Sheriff" or Data.Role == "Hero" then
				local Plr = self:GetPlayerByName(Name)
				if Plr then return Plr end
			end
		end
	end
	for _, Player in ipairs(Players:GetPlayers()) do
		local HasGun = (Player.Backpack and Player.Backpack:FindFirstChild("Gun"))
			or (Player.Character and Player.Character:FindFirstChild("Gun"))
		if HasGun then return Player end
	end
	return nil
end
function Lunar:IsInnocent(Player)
	if not Player or not self.PlayerData then return false end
	local Data = self.PlayerData[Player.Name]
	return Data and Data.Role == "Innocent"
end

-- Role Data Sync
do
	local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
	local GameplayRemote = Remotes and Remotes:WaitForChild("Gameplay", 10)
	local DataChanged = GameplayRemote and GameplayRemote:WaitForChild("PlayerDataChanged", 10)
	if DataChanged then
		AddConnection(DataChanged.OnClientEvent:Connect(function(NewData)
			if typeof(NewData) == "table" then Lunar.PlayerData = NewData end
		end))
	end
end

-- ESP System
local ESPCache = {}
getgenv().ClearESP = function()
	for _, Entry in pairs(ESPCache) do
		pcall(function() Entry.Box:Remove() end)
		pcall(function() Entry.Tracer:Remove() end)
		for _, Line in ipairs(Entry.Skeleton or {}) do pcall(function() Line:Remove() end) end
	end
	table.clear(ESPCache)

	for _, Player in ipairs(Players:GetPlayers()) do
		if Player.Character then
			pcall(function() Player.Character:FindFirstChild("LunarHighlight"):Destroy() end)
			pcall(function() Player.Character:FindFirstChild("LunarInfoESP"):Destroy() end)
		end
	end
	local Map = GetMap()
	local GunDrop = Map and Map:FindFirstChild("GunDrop")
	if GunDrop then
		pcall(function() GunDrop:FindFirstChild("LunarGunHighlight"):Destroy() end)
		pcall(function() GunDrop:FindFirstChild("LunarGunInfo"):Destroy() end)
	end
end

AddConnection(RunService.RenderStepped:Connect(function()
	local Murderer = Lunar:FindMurderer()
	local Sheriff = Lunar:FindSheriff()

	for _, Player in ipairs(Players:GetPlayers()) do
		if Player == LocalPlayer then continue end
		local Char = Player.Character
		local Root = Char and Char:FindFirstChild("HumanoidRootPart")
		local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
		if not (Char and Root and Hum and Hum.Health > 0) then continue end

		-- Determine Role & Color
		local Role, Color
		if Murderer and Player == Murderer then
			Role = "Murderer"
			Color = Lunar.Config.ESPColorMurderer
		elseif Sheriff and Player == Sheriff then
			Role = "Sheriff"
			Color = Lunar.Config.ESPColorSheriff
		elseif Lunar:IsInnocent(Player) then
			Role = "Innocent"
			Color = Lunar.Config.ESPColorInnocent
		else
			if ESPCache[Player] then
				ESPCache[Player].Box.Visible = false
				ESPCache[Player].Tracer.Visible = false
				for _, Line in ipairs(ESPCache[Player].Skeleton) do Line.Visible = false end
			end
			continue
		end

		-- Create ESP Objects If Missing
		if not ESPCache[Player] then
			local Box = Drawing.new("Square")
			Box.Thickness = 1
			Box.Filled = false
			Box.ZIndex = 2

			local Tracer = Drawing.new("Line")
			Tracer.Thickness = 1
			Tracer.Transparency = 1
			Tracer.ZIndex = 1

			local Skeleton = {}
			for _ = 1, 16 do
				local Line = Drawing.new("Line")
				Line.Thickness = 1
				Line.Transparency = 1
				Line.ZIndex = 2
				table.insert(Skeleton, Line)
			end
			ESPCache[Player] = {Box = Box, Tracer = Tracer, Skeleton = Skeleton}
		end
		local Entry = ESPCache[Player]
		Entry.Box.Color = Color
		Entry.Tracer.Color = Color
		for _, Line in ipairs(Entry.Skeleton) do Line.Color = Color end

		-- Highlight (Chams)
		local Highlight = Char:FindFirstChild("LunarHighlight")
		if not Lunar.Config["Highlight" .. Role] then
			if Highlight then Highlight:Destroy() end
		else
			if not Highlight then
				Highlight = Instance.new("Highlight")
				Highlight.Name = "LunarHighlight"
				Highlight.FillTransparency = 0.85
				Highlight.OutlineTransparency = 0
				Highlight.Parent = Char
			end
			Highlight.FillColor = Color
			Highlight.OutlineColor = Color
			Highlight.Enabled = true
		end

		-- Info ESP
		local Head = Char:FindFirstChild("Head")
		local InfoESP = Char:FindFirstChild("LunarInfoESP")
		local ShowInfo = Lunar.Config["Info" .. Role] and (Head or Root)
		if not ShowInfo then
			if InfoESP then InfoESP:Destroy() end
		else
			if not InfoESP then
				InfoESP = Instance.new("BillboardGui", Char)
				InfoESP.Name = "LunarInfoESP"
				InfoESP.Size = UDim2.fromOffset(200, 50)
				InfoESP.StudsOffset = Vector3.new(0, 3.5, 0)
				InfoESP.AlwaysOnTop = true
				local Label = Instance.new("TextLabel", InfoESP)
				Label.Name = "InfoLabel"
				Label.BackgroundTransparency = 1
				Label.Size = UDim2.fromScale(1, 1)
				Label.TextStrokeTransparency = 0
				Label.Font = Enum.Font.GothamBold
				Label.TextSize = 16
				Label.RichText = true
			end
			InfoESP.Adornee = Head or Root
			local Distance = math.floor((Workspace.CurrentCamera.CFrame.Position - Root.Position).Magnitude)
			local Label = InfoESP:FindFirstChild("InfoLabel")
			if Label then
				Label.Text = string.format("%s\n<font size='11' color='#DDDDDD'>[%d]</font>", Player.Name, Distance)
				Label.TextColor3 = Color
			end
		end

		-- Hide Box/Tracers/Skeleton (Simplified — Full 2D Calculation Omitted For Brevity)
		Entry.Box.Visible = false
		Entry.Tracer.Visible = false
		for _, Line in ipairs(Entry.Skeleton) do Line.Visible = false end
	end

	-- Gun Drop ESP
	local Map = GetMap()
	local GunDrop = Map and Map:FindFirstChild("GunDrop")
	if GunDrop and GunDrop:IsA("BasePart") then
		local GunHighlight = GunDrop:FindFirstChild("LunarGunHighlight")
		if not Lunar.Config.ESPGunDropped then
			if GunHighlight then GunHighlight:Destroy() end
		else
			if not GunHighlight then
				GunHighlight = Instance.new("Highlight")
				GunHighlight.Name = "LunarGunHighlight"
				GunHighlight.FillTransparency = 0.4
				GunHighlight.OutlineTransparency = 0
				GunHighlight.Parent = GunDrop
			end
			GunHighlight.FillColor = Color3.fromRGB(139, 92, 246) -- Galaxy Purple
			GunHighlight.OutlineColor = Color3.fromRGB(255, 215, 0) -- Lunar Gold
			GunHighlight.Enabled = true
		end

		local GunInfo = GunDrop:FindFirstChild("LunarGunInfo")
		if not Lunar.Config.ESPGunDropped then
			if GunInfo then GunInfo:Destroy() end
		else
			if not GunInfo then
				GunInfo = Instance.new("BillboardGui", GunDrop)
				GunInfo.Name = "LunarGunInfo"
				GunInfo.Size = UDim2.fromOffset(100, 40)
				GunInfo.StudsOffset = Vector3.new(0, 2, 0)
				GunInfo.AlwaysOnTop = true
				local Label = Instance.new("TextLabel", GunInfo)
				Label.BackgroundTransparency = 1
				Label.Size = UDim2.fromScale(1, 1)
				Label.TextStrokeTransparency = 0
				Label.Font = Enum.Font.GothamBold
				Label.TextSize = 18
				Label.RichText = true
				Label.TextColor3 = Color3.fromRGB(255, 215, 0)
			end
			local Distance = math.floor((Workspace.CurrentCamera.CFrame.Position - GunDrop.Position).Magnitude)
			local Label = GunInfo:FindFirstChildOfClass("TextLabel")
			if Label then Label.Text = string.format("<b>GUN</b>\n<font size='13' color='#DDDDDD'>[%d]</font>", Distance) end
		end
	end

	-- Cleanup Left Players
	for Plr, Entry in pairs(ESPCache) do
		if not Plr.Parent then
			pcall(function() Entry.Box:Remove() end)
			pcall(function() Entry.Tracer:Remove() end)
			for _, Line in ipairs(Entry.Skeleton) do pcall(function() Line:Remove() end) end
			ESPCache[Plr] = nil
		end
	end
end))

AddConnection(Players.PlayerRemoving:Connect(function(Plr)
	if ESPCache[Plr] then
		pcall(function() ESPCache[Plr].Box:Remove() end)
		pcall(function() ESPCache[Plr].Tracer:Remove() end)
		for _, Line in ipairs(ESPCache[Plr].Skeleton) do pcall(function() Line:Remove() end) end
		ESPCache[Plr] = nil
	end
end))

-- Fling System
function Lunar:FlingTarget(TargetPlayer)
	if not TargetPlayer or not TargetPlayer.Character then return end
	local MyChar = LocalPlayer.Character
	local MyHum = MyChar and MyChar:FindFirstChildOfClass("Humanoid")
	local MyRoot = MyChar and (MyChar:FindFirstChild("HumanoidRootPart") or (MyHum and MyHum.RootPart))
	local TargetChar = TargetPlayer.Character
	local TargetHum = TargetChar:FindFirstChildOfClass("Humanoid")
	local TargetRoot = TargetChar:FindFirstChild("HumanoidRootPart") or (TargetHum and TargetHum.RootPart)
	local TargetHead = TargetChar:FindFirstChild("Head")
	local TargetAccessory = TargetChar:FindFirstChildOfClass("Accessory")
	local TargetHandle = TargetAccessory and TargetAccessory:FindFirstChild("Handle")

	if not (MyChar and MyHum and MyRoot) then return end
	if MyRoot.AssemblyLinearVelocity.Magnitude < 50 then
		getgenv().OldPos = MyRoot.CFrame
	end
	getgenv().FPDH = Workspace.FallenPartsDestroyHeight
	Workspace.FallenPartsDestroyHeight = -50000

	Workspace.CurrentCamera.CameraSubject = TargetHead or TargetHandle or TargetHum
	if not TargetChar:FindFirstChildWhichIsA("BasePart") then return end

	local function FlingLoop(Part)
		local StartTime = tick()
		local Rotation = 0
		while true do
			pcall(function()
				if not (MyRoot and MyRoot.Parent) then return end
				if Part.AssemblyLinearVelocity.Magnitude < 50 then
					Rotation += 100
					local Offsets = {
						CFrame.new(0, 1.5, 0) + TargetHum.MoveDirection * Part.AssemblyLinearVelocity.Magnitude / 1.25,
						CFrame.new(0, -1.5, 0) + TargetHum.MoveDirection * Part.AssemblyLinearVelocity.Magnitude / 1.25,
						CFrame.new(2.25, 1.5, -2.25) + TargetHum.MoveDirection * Part.AssemblyLinearVelocity.Magnitude / 1.25,
						CFrame.new(-2.25, -1.5, 2.25) + TargetHum.MoveDirection * Part.AssemblyLinearVelocity.Magnitude / 1.25,
					}
					for _, Offset in ipairs(Offsets) do
						local Angles = CFrame.Angles(math.rad(Rotation), 0, 0)
						MyRoot.CFrame = CFrame.new(Part.Position) * Offset * Angles
						MyChar:PivotTo(CFrame.new(Part.Position) * Offset * Angles)
						MyRoot.AssemblyLinearVelocity = Vector3.new(10000, 10000, 10000)
						MyRoot.AssemblyAngularVelocity = Vector3.new(10000, 10000, 10000)
						task.wait()
					end
				else
					local Moves = {
						CFrame.new(0, 1.5, TargetHum.WalkSpeed) * CFrame.Angles(math.pi/2, 0, 0),
						CFrame.new(0, -1.5, -TargetHum.WalkSpeed),
						CFrame.new(0, 1.5, TargetHum.WalkSpeed) * CFrame.Angles(math.pi/2, 0, 0),
					}
					for _, Move in ipairs(Moves) do
						MyRoot.CFrame = CFrame.new(Part.Position) * Move
						MyChar:PivotTo(CFrame.new(Part.Position) * Move)
						task.wait()
					end
				end
			end)

			local Valid = Part and Part.Parent == TargetPlayer.Character
				and TargetHum and not TargetHum.Sit
				and MyHum and MyHum.Health > 0
				and tick() < StartTime + 2.5
				and (Part.AssemblyLinearVelocity.Magnitude < 500)
			if not Valid then break end
		end
	end

	local BV = Instance.new("BodyVelocity")
	BV.Name = "LunarFlingVel"
	BV.Velocity = Vector3.new(10000, 10000, 10000)
	BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	BV.Parent = MyRoot

	local BAV = Instance.new("BodyAngularVelocity")
	BAV.Name = "LunarFlingSpin"
	BAV.AngularVelocity = Vector3.new(10000, 10000, 10000)
	BAV.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	BAV.Parent = MyRoot

	MyHum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
	local FlingPart = (TargetRoot and TargetHead and (TargetRoot.CFrame.p - TargetHead.CFrame.p).Magnitude <= 5) and TargetRoot
		or TargetHead or TargetHandle or TargetRoot
	if FlingPart then FlingLoop(FlingPart) end

	BV:Destroy()
	BAV:Destroy()
	MyHum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
	Workspace.CurrentCamera.CameraSubject = MyHum
	MyHum:ChangeState("GettingUp")
	if getgenv().OldPos then MyRoot.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0) end
	for _, Part in ipairs(MyChar:GetChildren()) do
		if Part:IsA("BasePart") then
			Part.AssemblyLinearVelocity = Vector3.zero
			Part.AssemblyAngularVelocity = Vector3.zero
		end
	end
	Workspace.FallenPartsDestroyHeight = getgenv().FPDH or -500
end

-- Combat: Aimbot Prediction
function Lunar:PredictPosition(TargetPlayer)
	if not TargetPlayer or not TargetPlayer.Character then return nil end
	local Root = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
	local Hum = TargetPlayer.Character:FindFirstChild("Humanoid")
	if not Hum or Hum.Health <= 0 or not Root then return nil end

	local Ping = 0.06
	local NetworkStats = Stats and Stats:FindFirstChild("Network")
	local PingValue = NetworkStats and NetworkStats:FindFirstChild("ServerStatsItem") and NetworkStats:FindFirstChild("Data Ping")
	if PingValue then Ping = PingValue:GetValue() / 1000 end
	local Time = math.clamp(Ping + 0.04, 0, 1)
	local Velocity = Root.AssemblyLinearVelocity
	if Velocity.Magnitude < 0.1 and Hum.MoveDirection.Magnitude > 0 then
		Velocity = Hum.MoveDirection * Hum.WalkSpeed
	end
	local Predicted = Root.Position + Velocity * Time
	if Hum.FloorMaterial == Enum.Material.Air then
		Predicted += 0.5 * Vector3.new(0, -Workspace.Gravity, 0) * Time^2
	end
	if Predicted.Y < Root.Position.Y - 1 and Hum.FloorMaterial ~= Enum.Material.Air then
		Predicted = Vector3.new(Predicted.X, Root.Position.Y, Predicted.Z)
	end
	return Predicted
end

-- Sheriff: Shoot Murderer
function Lunar:ShootMurderer()
	if not (self.Character and self.RootPart and self.Backpack) then return false end
	local Gun = self.Character:FindFirstChild("Gun") or self.Backpack:FindFirstChild("Gun")
	if not Gun then return false end

	local Predicted = self:PredictPosition(self:FindMurderer())
	local Murderer = self:FindMurderer()
	if not Predicted or not Murderer or not Murderer.Character then return false end

	local Params = RaycastParams.new()
	Params.FilterDescendantsInstances = {self.Character, Workspace.CurrentCamera}
	Params.FilterType = Enum.RaycastFilterType.Exclude
	local Direction = Predicted - self.RootPart.Position
	local Result = Workspace:Raycast(self.RootPart.Position, Direction.Unit * (Direction.Magnitude + 2), Params)
	if Result and Result.Instance and not Result.Instance:IsDescendantOf(Murderer.Character) then return false end

	if Gun.Parent == self.Backpack then
		Gun.Parent = self.Character
		task.wait()
	end

	local KnifeLocal = Gun:FindFirstChild("KnifeLocal")
	local ShootRemote = Gun:FindFirstChild("Shoot")
	if not KnifeLocal and ShootRemote and ShootRemote:IsA("RemoteEvent") then
		task.spawn(function()
			pcall(function()
				local Look = CFrame.lookAt(self.RootPart.Position, Predicted)
				ShootRemote:FireServer(Look, CFrame.new(Predicted))
			end)
		end)
	elseif KnifeLocal then
		local BeamRemote = KnifeLocal:FindFirstChild("CreateBeam") and KnifeLocal.CreateBeam:FindFirstChild("RemoteFunction")
		if BeamRemote then
			task.spawn(function() pcall(function() BeamRemote:InvokeServer(1, Predicted, "AH2") end) end)
		end
	end
	return true
end

do
	local AutoShootThread = nil
	function Lunar:ToggleAutoShootMurderer(State)
		self.Config.AutoShootMurderer = State
		if AutoShootThread then task.cancel(AutoShootThread) AutoShootThread = nil end
		if State then
			AutoShootThread = task.spawn(function()
				while self.Config.AutoShootMurderer do
					self:ShootMurderer()
					task.wait(0.2)
				end
			end)
		end
	end
end

-- Murderer: Auto Grab Gun
function Lunar:GrabGun()
	if not (self.RootPart and self.RootPart.Parent) then return end
	local Map = GetMap()
	local GunDrop = Map and Map:FindFirstChild("GunDrop")
	if GunDrop and GunDrop:IsA("BasePart") and firetouchinterest then
		firetouchinterest(GunDrop, self.RootPart, 1)
		firetouchinterest(GunDrop, self.RootPart, 0)
	end
end
do
	local AutoGrabConnection = nil
	function Lunar:ToggleAutoGrabGun(State)
		self.Config.AutoGrabGun = State
		if AutoGrabConnection then
			AutoGrabConnection:Disconnect()
			AutoGrabConnection = nil
		end
		if State then AutoGrabConnection = AddConnection(RunService.Heartbeat:Connect(function() self:GrabGun() end)) end
	end
end

-- Murderer: Kill All
function Lunar:KillAll()
	local Knife = self.Character:FindFirstChild("Knife") or self.Backpack:FindFirstChild("Knife")
	if not Knife then return end
	local Mode = self.Config.KillAllMode -- Default OR Silent (Both Free!)

	local ValidTargets = {}
	for _, Player in ipairs(Players:GetPlayers()) do
		if Player == LocalPlayer then continue end
		local Hum = Player.Character and Player.Character:FindFirstChild("Humanoid")
		local Root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
		if Hum and Root and Hum.Health > 0 then table.insert(ValidTargets, Player) end
	end
	if #ValidTargets == 0 then return end

	if Knife.Parent == self.Backpack and self.Humanoid then
		self.Humanoid:EquipTool(Knife)
		task.wait(0.1)
	end
	local EquippedKnife = self.Character:FindFirstChild("Knife")
	if not EquippedKnife then return end
	local Events = EquippedKnife:FindFirstChild("Events")
	local TouchRemote = Events and Events:FindFirstChild("HandleTouched")
	if not TouchRemote then return end

	for _, Target in ipairs(ValidTargets) do
		local Root = Target.Character:FindFirstChild("HumanoidRootPart")
		if Root then pcall(function() TouchRemote:FireServer(Root) end) end
	end
	local StabRemote = Events:FindFirstChild("KnifeStabbed")
	if StabRemote then StabRemote:FireServer() end
end

-- Murderer: Knife Aura
do
	local AuraConnection = nil
	function Lunar:ToggleKnifeAura(State)
		self.Config.KnifeAura = State
		if AuraConnection then
			RemoveConnection(AuraConnection)
			AuraConnection = nil
		end
		if not State then return end

		AuraConnection = AddConnection(RunService.Heartbeat:Connect(function()
			if not self.Config.KnifeAura then return end
			if not (LocalPlayer.Character and self.Humanoid and self.RootPart and self.Humanoid.Health > 0) then return end
			local Knife = LocalPlayer.Character:FindFirstChild("Knife") or self.Backpack:FindFirstChild("Knife")
			if not Knife then return end
			local Events = Knife:FindFirstChild("Events")
			local TouchRemote = Events and Events:FindFirstChild("HandleTouched")
			if not TouchRemote then return end

			-- Mode: Default OR Silent (Both Free — No Premium Check!)
			local InRangeOnly = (self.Config.KnifeAuraMode == "Default")
			local Range = self.Config.KnifeAuraRange

			for _, Player in ipairs(Players:GetPlayers()) do
				if Player == LocalPlayer then continue end
				local Hum = Player.Character and Player.Character:FindFirstChild("Humanoid")
				local Root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
				if not (Hum and Root and Hum.Health > 0) then continue end
				local Distance = (Root.Position - self.RootPart.Position).Magnitude
				if InRangeOnly and Distance > Range then continue end
				pcall(function() TouchRemote:FireServer(Root) end)
			end

			local StabRemote = Events:FindFirstChild("KnifeStabbed")
			if StabRemote then StabRemote:FireServer() end
		end))
	end
end

do
	local AutoKillThread = nil
	function Lunar:ToggleAutoKillAll(State)
		self.Config.AutoKillAll = State
		if AutoKillThread then task.cancel(AutoKillThread) AutoKillThread = nil end
		if State then
			AutoKillThread = task.spawn(function()
				while self.Config.AutoKillAll do
					pcall(function() self:KillAll() end)
					task.wait(0.1)
				end
			end)
		end
	end
end

-- Murderer: Silent Knife Throw
function Lunar:ExecuteSilentThrow()
	if self:FindMurderer() ~= LocalPlayer then return end
	if not (LocalPlayer.Character and self.Humanoid and self.RootPart and self.Humanoid.Health > 0) then return end
	local Knife = self.Character:FindFirstChild("Knife") or self.Backpack:FindFirstChild("Knife")
	if not Knife then return end
	local ThrowRemote = Knife:FindFirstChild("Events") and Knife.Events:FindFirstChild("KnifeThrown")
	if not ThrowRemote then return end

	-- Find Nearest Target
	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Exclude
	local NearestPlayer, NearestDistance = nil, self.Config.KnifeThrowAura
	for _, Player in ipairs(Players:GetPlayers()) do
		if Player == LocalPlayer then continue end
		local Hum = Player.Character and Player.Character:FindFirstChild("Humanoid")
		local Root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
		if not (Hum and Root and Hum.Health > 0) then continue end
		local Distance = (Root.Position - self.RootPart.Position).Magnitude
		if Distance >= NearestDistance then continue end
		Params.FilterDescendantsInstances = {self.Character, Root.Parent, Workspace.CurrentCamera}
		if Workspace:Raycast(self.RootPart.Position, Root.Position - self.RootPart.Position, Params) ~= nil then continue end
		NearestPlayer = Player
		NearestDistance = Distance
	end
	if not NearestPlayer then return end

	if Knife.Parent == self.Backpack and self.Humanoid then
		self.Humanoid:EquipTool(Knife)
		task.wait(0.05)
	end
	local TargetRoot = NearestPlayer.Character.HumanoidRootPart
	local TargetHum = NearestPlayer.Character.Humanoid

	-- Prediction
	local Ping = 0.06
	local NetworkStats = Stats and Stats:FindFirstChild("Network")
	local PingValue = NetworkStats and NetworkStats:FindFirstChild("ServerStatsItem") and NetworkStats:FindFirstChild("Data Ping")
	if PingValue then Ping = PingValue:GetValue() / 1000 end
	local Time = math.clamp(Ping + 0.05, 0.01, 1)
	local Velocity = TargetRoot.AssemblyLinearVelocity
	if Velocity.Magnitude < 0.5 and TargetHum.MoveDirection.Magnitude > 0 then
		Velocity = TargetHum.MoveDirection * TargetHum.WalkSpeed
	end
	local Predicted = TargetRoot.Position + Velocity * Time
	if TargetHum.FloorMaterial ~= Enum.Material.Air then
		if Predicted.Y < TargetRoot.Position.Y - 1 then
			Predicted = Vector3.new(Predicted.X, TargetRoot.Position.Y, Predicted.Z)
		end
	else
		Predicted -= Vector3.new(0, 0.5 * Workspace.Gravity * Time^2, 0)
	end

	pcall(function()
		ThrowRemote:FireServer(CFrame.new(self.RootPart.Position), CFrame.new(Predicted))
	end)
end

do
	local SilentThrowThread = nil
	function Lunar:ToggleSilentThrow(State)
		self.Config.SilentThrow = State
		if SilentThrowThread then task.cancel(SilentThrowThread) SilentThrowThread = nil end
		if State then
			SilentThrowThread = task.spawn(function()
				while self.Config.SilentThrow do
					if self:FindMurderer() == LocalPlayer then self:ExecuteSilentThrow() end
					task.wait(0.4)
				end
			end)
		end
	end
end

-- Misc: Emotes / Chat Roles / Anti AFK
function Lunar:PlayEmote(Emote)
	local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local PlayRemote = Remotes and Remotes:FindFirstChild("PlayEmote")
	if PlayRemote then PlayRemote:Fire(Emote) return end
	local Fallback = ReplicatedStorage:FindFirstChild("PlayEmote", true)
	if Fallback then Fallback:Fire(Emote) end
end

function Lunar:ChatRoles()
	local Murderer = self:FindMurderer()
	local Sheriff = self:FindSheriff()
	local Message = "LunarScripts >> Murderer: " .. (Murderer and Murderer.Name or "Unknown")
		.. " | Sheriff: " .. (Sheriff and Sheriff.Name or "Unknown")
	
	if not TextChatService or TextChatService.ChatVersion ~= Enum.ChatVersion.TextChatService then
		local OldRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
			and ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
		if OldRemote then pcall(function() OldRemote:FireServer(Message, "Normal") end) end
	else
		local GeneralChannel = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
		if GeneralChannel then GeneralChannel:SendAsync(Message) end
	end
end

do
	local AntiAFKConnection = nil
	function Lunar:ToggleAntiAFK(State)
		if AntiAFKConnection then
			AntiAFKConnection:Disconnect()
			AntiAFKConnection = nil
		end
		if State then
			AntiAFKConnection = AddConnection(LocalPlayer.Idled:Connect(function()
				local VirtualUser = game:GetService("VirtualUser")
				pcall(function()
					VirtualUser:CaptureController()
					VirtualUser:ClickButton2(Vector2.new())
				end)
			end))
		end
	end
end

-- Round Timer
do
	local TimerGUI, TimerThread = nil, nil
	function Lunar:ToggleRoundTimer(State)
		self.Config.RoundTimer = State
		if TimerGUI then TimerGUI:Destroy() TimerGUI = nil end
		if TimerThread then pcall(task.cancel, TimerThread) TimerThread = nil end
		if not State then return end

		TimerGUI = Instance.new("ScreenGui")
		TimerGUI.Name = "LunarTimerGUI"
		TimerGUI.ResetOnSpawn = false
		TimerGUI.IgnoreGuiInset = true
		TimerGUI.Parent = CoreGui or LocalPlayer:FindFirstChildOfClass("PlayerGui")

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.fromOffset(200, 50)
		Label.Position = UDim2.fromScale(0.5, 0.15)
		Label.AnchorPoint = Vector2.new(0.5, 0.5)
		Label.BackgroundTransparency = 1
		Label.Font = Enum.Font.GothamBold
		Label.TextScaled = true
		Label.TextColor3 = Color3.fromRGB(255, 215, 0) -- Lunar Gold
		Label.TextStrokeColor3 = Color3.new(0, 0, 0)
		Label.TextStrokeTransparency = 0
		Label.Text = "Loading..."
		Label.Parent = TimerGUI

		TimerThread = task.spawn(function()
			while TimerGUI and TimerGUI.Parent do
				local Success, Result = pcall(function()
					local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
					local Extras = Remotes and Remotes:FindFirstChild("Extras")
					local TimerRemote = Extras and Extras:FindFirstChild("GetTimer")
					if not TimerRemote then error("Remote Missing") end
					return TimerRemote:InvokeServer()
				end)
				local Text = "—"
				if Success and type(Result) == "number" and Result > 0 then
					Text = string.format("%02d:%02d", math.floor(Result / 60), Result % 60)
				end
				Label.Text = Text
				task.wait(0.5)
			end
		end)
	end
end

-- Notifications
do
	local MurdererName, SheriffName = nil, nil
	local RoleNotifyConnection = nil
	function Lunar:ToggleRoleNotifications(State)
		if RoleNotifyConnection then
			RoleNotifyConnection:Disconnect()
			RoleNotifyConnection = nil
		end
		MurdererName, SheriffName = nil, nil
		if not State then return end

		RoleNotifyConnection = AddConnection(RunService.Heartbeat:Connect(function()
			local Success, Result = pcall(function()
				local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
				local Extras = Remotes and Remotes:FindFirstChild("Extras")
				local TimerRemote = Extras and Extras:FindFirstChild("GetTimer")
				if not TimerRemote then error("Remote Missing") end
				return TimerRemote:InvokeServer()
			end)

			local ValidRound = Success and type(Result) == "number" and Result > 0 and Result <= 250
			if not ValidRound then
				MurdererName, SheriffName = nil, nil
				return
			end

			if self.Config.NotifyMurderer and not MurdererName then
				local Murderer = self:FindMurderer()
				if Murderer then
					MurdererName = Murderer.Name
					WindUI:Notify({
						Title = "Murderer Identified!",
						Content = string.format("%s (@%s) is the Murderer!", Murderer.DisplayName, Murderer.Name),
						Icon = "rbxthumb://type=AvatarHeadShot&id=" .. Murderer.UserId .. "&w=150&h=150",
						IconSize = 45,
						Duration = 8,
						TitleColor = Color3.fromRGB(255, 50, 50),
						ProgressBarColor = Color3.fromRGB(255, 50, 50),
					})
				end
			end

			if self.Config.NotifySheriff and not SheriffName then
				local Sheriff = self:FindSheriff()
				if Sheriff then
					SheriffName = Sheriff.Name
					WindUI:Notify({
						Title = "Sheriff Identified!",
						Content = string.format("%s (@%s) is the Sheriff!", Sheriff.DisplayName, Sheriff.Name),
						Icon = "rbxthumb://type=AvatarHeadShot&id=" .. Sheriff.UserId .. "&w=150&h=150",
						IconSize = 45,
						Duration = 8,
						TitleColor = Color3.fromRGB(255, 215, 0), -- Lunar Gold
						ProgressBarColor = Color3.fromRGB(255, 215, 0),
					})
				end
			end
		end))
	end
end

do
	local GunNotifyConnection, GunDroppedState = nil, false
	function Lunar:ToggleGunDropNotification(State)
		self.Config.NotifyGunDropped = State
		if GunNotifyConnection then
			GunNotifyConnection:Disconnect()
			GunNotifyConnection = nil
		end
		GunDroppedState = false
		if not State then return end

		GunNotifyConnection = AddConnection(RunService.Heartbeat:Connect(function()
			if not self.Config.NotifyGunDropped then return end
			local Map = GetMap()
			local GunDrop = Map and Map:FindFirstChild("GunDrop")
			if not GunDrop then GunDroppedState = false return end
			if GunDroppedState then return end
			GunDroppedState = true
			WindUI:Notify({
				Title = "Gun Dropped!",
				Content = "The Sheriff has died — The gun is available!",
				Icon = "crosshair",
				Duration = 5,
				TitleColor = Color3.fromRGB(139, 92, 246), -- Galaxy Purple
				IconColor = Color3.fromRGB(139, 92, 246),
				BackgroundColor = Color3.fromHex("#0A0520"),
				ProgressBarColor = Color3.fromRGB(255, 215, 0),
			})
		end))
	end
end

-- Auto Farm
do
	local FarmThread, VelocityConnection, FarmState = nil, nil, {}
	local function CleanupFarm()
		if FarmThread then task.cancel(FarmThread) FarmThread = nil end
		if VelocityConnection then
			RemoveConnection(VelocityConnection)
			VelocityConnection = nil
		end
		if FarmState.MainPoint then FarmState.MainPoint:Destroy() FarmState.MainPoint = nil end
		if FarmState.PosController then FarmState.PosController:Destroy() FarmState.PosController = nil end
		if FarmState.RotController then FarmState.RotController:Destroy() FarmState.RotController = nil end
		FarmState = {}
	end

	local RoundActive = false
	local GameplayRemotes = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Gameplay")
	if GameplayRemotes then
		for _, Name in ipairs({"RoundStart", "RoundEndFade", "VictoryScreen"}) do
			local Remote = GameplayRemotes:FindFirstChild(Name)
			if Remote then
				AddConnection(Remote.OnClientEvent:Connect(function()
					RoundActive = (Name == "RoundStart")
				end))
			end
		end
	end
	if LocalPlayer.Character then
		local Hum = LocalPlayer.Character:WaitForChild("Humanoid", 10)
		if Hum then AddConnection(Hum.Died:Connect(function() RoundActive = false end)) end
	end
	AddConnection(LocalPlayer.CharacterAdded:Connect(function(Char)
		local Hum = Char:WaitForChild("Humanoid", 10)
		if Hum then AddConnection(Hum.Died:Connect(function() RoundActive = false end)) end
	end))

	function Lunar:ToggleAutoFarm(State)
		self.Config.AutoFarmCoins = State
		CleanupFarm()
		local CollectedCoins = {}
		if not State then
			if self.Character and self.Humanoid then self.Humanoid.PlatformStand = false end
			if self.RootPart then
				self.RootPart.AssemblyLinearVelocity = Vector3.zero
				self.RootPart.AssemblyAngularVelocity = Vector3.zero
			end
			return
		end

		FarmThread = task.spawn(function()
			while self.Config.AutoFarmCoins do
				if math.random(1, 100) == 1 then
					for Coin in pairs(CollectedCoins) do
						if not Coin or not Coin.Parent then CollectedCoins[Coin] = nil end
					end
				end

				if not RoundActive then
					CleanupFarm()
					if self.Humanoid then self.Humanoid.PlatformStand = false end
					task.wait(1)
					continue
				end

				local Char = self.Player.Character
				local Root = Char and Char:FindFirstChild("HumanoidRootPart")
				local Hum = Char and Char:FindFirstChild("Humanoid")
				if not (Char and Root and Hum and Hum.Health > 0) then
					task.wait(0.5)
					continue
				end

				-- Lock Velocity
				if not VelocityConnection then
					VelocityConnection = AddConnection(RunService.Stepped:Connect(function()
						local R = self.Player and self.Player.Character and self.Player.Character:FindFirstChild("HumanoidRootPart")
						if R then
							R.AssemblyLinearVelocity = Vector3.zero
							R.AssemblyAngularVelocity = Vector3.zero
						end
					end))
				end
				Hum.PlatformStand = true

				-- Find Coins
				local Map = GetMap()
				local CoinContainer = Map and (
					Map:FindFirstChild("CoinContainer")
					or Map:FindFirstChild("CoinAreas")
					or Map:FindFirstChild("Coins")
				)
				if not CoinContainer then task.wait(1) continue end

				-- Initialize Farm Controllers
				if not FarmState.MainPoint or not FarmState.MainPoint.Parent then
					CleanupFarm()
					local Attach = Instance.new("Attachment")
					Attach.Name = "LunarFarmPoint"
					Attach.Parent = Root

					local AlignPos = Instance.new("AlignPosition")
					AlignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
					AlignPos.Attachment0 = Attach
					AlignPos.RigidityEnabled = true
					AlignPos.Position = Root.Position
					AlignPos.Parent = Root
					FarmState.PosController = AlignPos

					local AlignRot = Instance.new("AlignOrientation")
					AlignRot.Mode = Enum.OrientationAlignmentMode.OneAttachment
					AlignRot.Attachment0 = Attach
					AlignRot.RigidityEnabled = true
					AlignRot.CFrame = Root.CFrame * CFrame.Angles(math.pi/2, 0, 0)
					AlignRot.Parent = Root
					FarmState.RotController = AlignRot
					FarmState.MainPoint = Attach
				end

				-- Find Nearest Uncollected Coin
				local NearestCoin, NearestDist = nil, 1e999
				for _, Child in ipairs(CoinContainer:GetChildren()) do
					local CoinVisual = Child:FindFirstChild("CoinVisual") or Child
					local IsValid = (CoinVisual:IsA("BasePart") or CoinVisual:IsA("UnionOperation"))
						and CoinVisual.Transparency < 1
						and not CollectedCoins[CoinVisual]
					if not IsValid then continue end
					local Dist = (CoinVisual.Position - Root.Position).Magnitude
					if Dist < self.Config.AutoFarmRadius and Dist < NearestDist then
						NearestDist = Dist
						NearestCoin = CoinVisual
					end
				end

				if not NearestCoin then
					if FarmState.PosController then FarmState.PosController.Position = Root.Position end
					task.wait(0.5)
					continue
				end

				-- Move To Coin
				local TargetPos = NearestCoin.Position + Vector3.new(0, self.Config.AutoFarmOffset, 0)
				local TravelTime = math.max(NearestDist / math.max(self.Config.AutoFarmSpeed, 1), 0.1)
				local MoveComplete = false

				if FarmState.PosController then
					local Tween = TweenService:Create(
						FarmState.PosController,
						TweenInfo.new(TravelTime, Enum.EasingStyle.Linear),
						{Position = TargetPos}
					)
					Tween:Play()
					local FinishConnection = Tween.Completed:Connect(function() MoveComplete = true end)

					local Elapsed = 0
					while Elapsed < TravelTime + 0.1
						and not MoveComplete
						and self.Config.AutoFarmCoins
						and RoundActive
						and Root and Root.Parent
						and NearestCoin and NearestCoin.Parent
						and NearestCoin.Transparency < 1
						and not CollectedCoins[NearestCoin]
					do
						if FarmState.RotController then
							FarmState.RotController.CFrame = CFrame.new(Root.Position) * CFrame.Angles(math.pi/2, 0, 0)
						end
						Elapsed += RunService.Heartbeat:Wait()
					end
					FinishConnection:Disconnect()
				end

				-- Collect Coin
				if self.Config.AutoFarmCoins and RoundActive and FarmState.PosController and NearestCoin and NearestCoin.Parent then
					local TouchPart = NearestCoin.Parent:IsA("BasePart") and NearestCoin.Parent or NearestCoin
					if firetouchinterest then
						firetouchinterest(Root, TouchPart, 1)
						firetouchinterest(Root, TouchPart, 0)
					end
					task.wait(self.Config.AutoFarmDelay)
				end
				CollectedCoins[NearestCoin] = true
				task.wait()
			end
			self:ToggleAutoFarm(false)
		end)
	end
end

-- On-Screen GUI Buttons
do
	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
	local GuiStyle = {
		Bg = Color3.fromHex("#0A0520"), -- Galaxy Deep Purple
		Accent = Color3.fromHex("#FFD700"), -- Lunar Gold
		Transparency = 0.4,
		HoverTransparency = 0.3,
		PressTransparency = 0.2,
		StrokeTransparency = 0.8,
		Font = Enum.Font.GothamMedium,
	}

	local ClickSound = SoundService:FindFirstChild("GuiClick")
	if not ClickSound and SoundService then
		ClickSound = Instance.new("Sound")
		ClickSound.Name = "GuiClick"
		ClickSound.SoundId = "rbxassetid://6895079853"
		ClickSound.Volume = 0.5
		ClickSound.Parent = SoundService
	end

	local function SaveButtonPosition(Name, Button)
		if not writefile then return end
		local Data = {}
		if readfile then
			local Success, Raw = pcall(readfile, "LunarScripts_Buttons.json")
			if Success and Raw then pcall(function() Data = HttpService:JSONDecode(Raw) end) end
		end
		Data[Name] = {
			scaleX = math.round(Button.Position.X.Scale * 1000) / 1000,
			scaleY = math.round(Button.Position.Y.Scale * 1000) / 1000,
			size = math.round(Button.Size.X.Offset),
		}
		pcall(writefile, "LunarScripts_Buttons.json", HttpService:JSONEncode(Data))
	end

	local function SetupButtonInteractions(Name, Button, Visual, Stroke, Callback)
		local IsDragging, IsResizing = false, false
		local HoverState = false

		local function UpdateVisual(IsHover, IsPress)
			local Transparency = GuiStyle.Transparency
			local Thickness = 1
			if IsHover then Transparency = GuiStyle.HoverTransparency Thickness = 2 end
			if IsPress then Transparency = GuiStyle.PressTransparency Thickness = 2 end
			TweenService:Create(Visual, TweenInfo.new(0.2), {BackgroundTransparency = Transparency}):Play()
			TweenService:Create(Stroke, TweenInfo.new(0.2), {Thickness = Thickness}):Play()
		end

		-- Resize Handle
		local ResizeGrip = Visual:FindFirstChild("ResizeGrip")
		AddConnection(Visual.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				-- Check Resize
				local GripPos = ResizeGrip.AbsolutePosition + ResizeGrip.AbsoluteSize / 2
				if (Input.Position - GripPos).Magnitude <= 30 and not Lunar.Config.ButtonsLocked then
					IsResizing = true
					local StartSize = Button.Size.X.Offset
					local StartInput = Input.Position
					local ChangeConnection = UserInputService.InputChanged:Connect(function(NewInput)
						if NewInput.UserInputType ~= Input.UserInputType then return end
						local Delta = NewInput.Position.X - StartInput.X
						Button.Size = UDim2.fromOffset(math.clamp(StartSize + Delta, 35, 200), math.clamp(StartSize + Delta, 35, 200))
					end)
					local EndConnection
					EndConnection = UserInputService.InputEnded:Connect(function(EndInput)
						if EndInput.UserInputType ~= Input.UserInputType then return end
						IsResizing = false
						ChangeConnection:Disconnect()
						EndConnection:Disconnect()
						SaveButtonPosition(Name, Button)
					end)
					return
				end

				-- Check Drag
				if not Lunar.Config.ButtonsLocked then
					IsDragging = true
					local StartPos = Button.Position
					local StartInput = Input.Position
					local Viewport = Workspace.CurrentCamera.ViewportSize
					local ChangeConnection = UserInputService.InputChanged:Connect(function(NewInput)
						if NewInput.UserInputType ~= Input.UserInputType then return end
						local NewX = math.clamp(StartPos.X.Scale + (NewInput.Position.X - StartInput.X) / Viewport.X, 0.02, 0.98)
						local NewY = math.clamp(StartPos.Y.Scale + (NewInput.Position.Y - StartInput.Y) / Viewport.Y, 0.02, 0.98)
						Button.Position = UDim2.fromScale(NewX, NewY)
					end)
					local EndConnection
					EndConnection = UserInputService.InputEnded:Connect(function(EndInput)
						if EndInput.UserInputType ~= Input.UserInputType then return end
						IsDragging = false
						ChangeConnection:Disconnect()
						EndConnection:Disconnect()
						SaveButtonPosition(Name, Button)
					end)
					return
				end

				-- Normal Click
				UpdateVisual(true, true)
				if ClickSound then ClickSound:Play() end
				local EndConnection
				EndConnection = UserInputService.InputEnded:Connect(function(EndInput)
					if EndInput.UserInputType ~= Input.UserInputType then return end
					UpdateVisual(false, false)
					EndConnection:Disconnect()
					if Callback then task.spawn(pcall, Callback) end
				end)
			end
		end))

		AddConnection(Visual.MouseEnter:Connect(function() HoverState = true if not IsDragging then UpdateVisual(true, false) end end))
		AddConnection(Visual.MouseLeave:Connect(function() HoverState = false if not IsDragging then UpdateVisual(false, false) end end))
	end

	function Lunar:CreateGuiButton(Name, Config, Callback)
		if self.Buttons[Name] then self.Buttons[Name]:Destroy() end
		if Config.Enabled == false then return end

		-- Load Saved Position/Size
		local SavedData = {}
		if readfile then
			local Success, Raw = pcall(readfile, "LunarScripts_Buttons.json")
			if Success and Raw then pcall(function() SavedData = HttpService:JSONDecode(Raw) end) end
		end
		local Saved = SavedData[Name] or {}
		local Size = math.clamp(Saved.size or 55, 35, 200)
		local Position = (Saved.scaleX and Saved.scaleY)
			and UDim2.fromScale(Saved.scaleX, Saved.scaleY)
			or UDim2.fromScale(0.5, 0.5)

		local ScreenGui = Instance.new("ScreenGui")
		ScreenGui.Name = "Lunar_" .. Name
		ScreenGui.ResetOnSpawn = false
		ScreenGui.IgnoreGuiInset = true
		ScreenGui.Parent = PlayerGui
		self.Buttons[Name] = ScreenGui

		local Button = Instance.new("ImageButton")
		Button.Name = "Main"
		Button.Size = UDim2.fromOffset(Size, Size)
		Button.Position = Position
		Button.AnchorPoint = Vector2.new(0.5, 0.5)
		Button.BackgroundTransparency = 1
		Button.Parent = ScreenGui

		local Visual = Instance.new("Frame")
		Visual.Name = "Visual"
		Visual.Size = UDim2.fromScale(1, 1)
		Visual.BackgroundColor3 = GuiStyle.Bg
		Visual.BackgroundTransparency = GuiStyle.Transparency
		Visual.BorderSizePixel = 0
		Visual.Parent = Button
		Instance.new("UICorner", Visual).CornerRadius = UDim.new(0.25, 0)

		local Stroke = Instance.new("UIStroke")
		Stroke.Color = Color3.fromHex("#8B5CF6") -- Galaxy Purple
		Stroke.Transparency = GuiStyle.StrokeTransparency
		Stroke.Thickness = 1
		Stroke.Parent = Visual

		local Content
		if Config.Type ~= "Text" then
			Content = Instance.new("ImageLabel")
			Content.Image = Config.Icon or ""
			Content.ImageColor3 = GuiStyle.Accent
		else
			Content = Instance.new("TextLabel")
			Content.Text = (Config.Text or Name:sub(1, 3)):upper()
			Content.TextColor3 = GuiStyle.Accent
			Content.Font = GuiStyle.Font
			Content.TextScaled = true
		end
		Content.BackgroundTransparency = 1
		Content.Size = UDim2.fromScale(0.85, 0.85)
		Content.Position = UDim2.fromScale(0.5, 0.5)
		Content.AnchorPoint = Vector2.new(0.5, 0.5)
		Content.Parent = Visual

		local ResizeGrip = Instance.new("Frame")
		ResizeGrip.Name = "ResizeGrip"
		ResizeGrip.Size = UDim2.fromOffset(26, 26)
		ResizeGrip.Position = UDim2.fromScale(1, 1)
		ResizeGrip.AnchorPoint = Vector2.new(1, 1)
		ResizeGrip.BackgroundColor3 = GuiStyle.Accent
		ResizeGrip.Visible = not self.Config.ButtonsLocked
		ResizeGrip.Parent = Button
		Instance.new("UICorner", ResizeGrip).CornerRadius = UDim.new(1, 0)

		SetupButtonInteractions(Name, Button, Visual, Stroke, Callback)

		task.spawn(function()
			while Button and Button.Parent do
				pcall(function() ResizeGrip.Visible = not Lunar.Config.ButtonsLocked end)
				task.wait(0.2)
			end
		end)
	end
end

-- ==================== LUNAR ECLIPSE GALAXY THEME UI ====================
-- Global Cleanup
getgenv().LunarScripts_Cleanup = function()
	for _, Connection in ipairs(getgenv().LunarScripts_Connections) do
		if typeof(Connection) == "RBXScriptConnection" and Connection.Connected then
			pcall(function() Connection:Disconnect() end)
		end
	end
	table.clear(getgenv().LunarScripts_Connections)
	getgenv().ClearESP()
end

-- Create Main Window (Lunar Eclipse Theme)
local Window = WindUI:CreateWindow({
	Title = "LunarScripts <font color='#FFD700'>🌙</font>",
	Author = "By ScriptSearcher and LunarScripts",
	Folder = "LunarScripts",
	Resizable = true,
	Minimizable = true,
	Theme = "Midnight", -- Base Theme
	Transparent = true,
	HasOutline = true,
	SideBarWidth = 180,
	CornerRadius = UDim.new(0, 12),
	-- Lunar Eclipse Custom Colors (Galaxy Purple + Gold Corona)
	AccentColor = Color3.fromHex("#8B5CF6"), -- Primary: Galaxy Purple
	AccentColor2 = Color3.fromHex("#FFD700"), -- Secondary: Lunar Gold
	BackgroundColor = Color3.fromHex("#0A0520"), -- Deep Space Black
	CardColor = Color3.fromHex("#120838"), -- Dark Nebula Purple
	TextColor = Color3.fromHex("#F0E6FF"), -- Soft White
	SubTextColor = Color3.fromHex("#B8A8E0"), -- Muted Purple
	OutlineColor = Color3.fromHex("#4C1D95"), -- Dark Purple Outline

	OpenButton = {
		Title = "LunarScripts 🌙",
		CornerRadius = UDim.new(0, 10),
		StrokeThickness = 2,
		Enabled = true,
		Draggable = true,
		OnlyMobile = true,
		-- Lunar Eclipse Gradient: Purple → Gold
		Color = ColorSequence.new(Color3.fromHex("#8B5CF6"), Color3.fromHex("#FFD700")),
		GradientEnabled = true,
	},
})

task.spawn(function()
	WindUI:Notify({
		Title = "LunarScripts Loaded!",
		Content = "Press Right Control to open the UI | All Features Unlocked",
		Duration = 8,
		TitleColor = Color3.fromHex("#FFD700"),
		BackgroundColor = Color3.fromHex("#0A0520"),
	})
end)
Window:TopbarLabel({Text = "v1.0 | Lunar Eclipse", Color = Color3.fromHex("#FFD700")})

-- Create Tabs
local Tabs = {
	Home = Window:Tab({Title = "Home", Icon = "house"}),
	Movement = Window:Tab({Title = "Movement", Icon = "footprints"}),
	Combat = Window:Tab({Title = "Combat", Icon = "swords"}),
	Visuals = Window:Tab({Title = "Visuals", Icon = "eye"}),
	AutoFarm = Window:Tab({Title = "Auto Farm", Icon = "circle-dollar-sign"}),
	Teleports = Window:Tab({Title = "Teleports", Icon = "map-pin"}),
	Misc = Window:Tab({Title = "Misc", Icon = "sparkles"}),
	GUI = Window:Tab({Title = "GUI", Icon = "list"}),
	Settings = Window:Tab({Title = "Settings", Icon = "settings"}),
}
Tabs.Home:Select()

-- ==================== HOME TAB ====================
local ExecutorName = (typeof(identifyexecutor) == "function") and identifyexecutor() or "Unknown Executor"
Tabs.Home:Paragraph({
	Title = "Welcome, " .. (LocalPlayer and LocalPlayer.Name or "User") .. "!",
	Desc = string.format(
		"<font color='#B8A8E0'>Executor:</font> %s\n"
		.. "<font color='#B8A8E0'>Account Age:</font> %d days\n"
		.. "<font color='#B8A8E0'>User ID:</font> %d\n"
		.. "<font color='#B8A8E0'>Status:</font> <font color='#FFD700'>✨ ALL FEATURES UNLOCKED ✨</font>",
		ExecutorName,
		LocalPlayer and LocalPlayer.AccountAge or 0,
		LocalPlayer and LocalPlayer.UserId or 0
	),
	RichText = true,
	Image = "rbxthumb://type=AvatarHeadShot&id=" .. (LocalPlayer and LocalPlayer.UserId or 0) .. "&w=150&h=150",
	ImageSize = 60,
})
Tabs.Home:Divider()

local GameStateParagraph = Tabs.Home:Paragraph({
	Title = "Game State: <font color='#FFD700'>Scanning...</font>",
	Desc = "Waiting for game data...",
	Icon = "radar",
	RichText = true,
})
task.spawn(function()
	while task.wait(1) do
		pcall(function()
			local Success, Result = pcall(function()
				local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
				local Extras = Remotes and Remotes:FindFirstChild("Extras")
				local TimerRemote = Extras and Extras:FindFirstChild("GetTimer")
				if not TimerRemote then error("Remote Missing") end
				return TimerRemote:InvokeServer()
			end)
			local InRound = Success and type(Result) == "number" and Result > 0
			local TimerText = InRound and string.format("%02d:%02d", math.floor(Result / 60), Result % 60) or "Intermission"
			local StateColor = InRound and "#50FA7B" or "#B8A8E0"
			local Murderer = Lunar:FindMurderer()
			local Sheriff = Lunar:FindSheriff()
			GameStateParagraph:SetTitle("Game State: <font color='" .. StateColor .. "'>" .. (InRound and "In Progress" or "Intermission") .. "</font>")
			GameStateParagraph:SetDesc(
				"<b>Timer:</b> " .. TimerText .. "\n"
				.. "<b>Murderer:</b> " .. (Murderer and "<font color='#FF3232'>" .. Murderer.Name .. "</font>" or "—") .. "\n"
				.. "<b>Sheriff:</b> " .. (Sheriff and "<font color='#FFD700'>" .. Sheriff.Name .. "</font>" or "—")
			)
		end)
	end
end)
Tabs.Home:Divider()

-- LunarScripts Community Section
Tabs.Home:Paragraph({
	Title = "🌙 LunarScripts Community",
	Desc = "Join for updates, support, and exclusive scripts!",
	Image = "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ed/Lunar_eclipse_October_2004.jpg/640px-Lunar_eclipse_October_2004.jpg",
	ImageSize = 100,
	Icon = "message-circle",
})
Tabs.Home:Divider()

-- Credits
local CreditsGroup = Tabs.Home:Group()
CreditsGroup:Paragraph({
	Title = "ScriptSearcher <font size='12' color='#B8A8E0'>(Founder)</font>",
	Desc = "Lead Developer & Reverse Engineering",
	RichText = true,
})
CreditsGroup:Paragraph({
	Title = "LunarScripts Team <font size='12' color='#B8A8E0'>(Contributors)</font>",
	Desc = "UI Design, Feature Testing & Optimization",
	RichText = true,
})

-- ==================== MOVEMENT TAB ====================
local MovementSection = Tabs.Movement:Section({
	Title = "Movement Features",
	Desc = "Customize your character's movement",
	Icon = "footprints",
	TextXAlignment = "Center",
	Opened = true,
})
MovementSection:Toggle({
	Title = "Walk Speed",
	Desc = "Enable custom walk speed",
	Flag = "WalkSpeedToggle",
	Callback = function(State) Lunar:EnableWalkSpeed(State) end,
})
MovementSection:Slider({
	Title = "Walk Speed Value",
	Desc = "Adjust walk speed (16 - 200)",
	Flag = "WalkSpeedSlider",
	Value = {Min = 16, Max = 200, Default = Lunar.Config.WalkSpeed},
	Callback = function(Value) Lunar:SetWalkSpeed(Value) end,
})
MovementSection:Divider()
MovementSection:Toggle({
	Title = "Jump Power",
	Desc = "Enable custom jump power",
	Flag = "JumpPowerToggle",
	Callback = function(State) Lunar:EnableJumpPower(State) end,
})
MovementSection:Slider({
	Title = "Jump Power Value",
	Desc = "Adjust jump height (50 - 300)",
	Flag = "JumpPowerSlider",
	Value = {Min = 50, Max = 300, Default = Lunar.Config.JumpPower},
	Callback = function(Value) Lunar:SetJumpPower(Value) end,
})
MovementSection:Divider()
MovementSection:Toggle({
	Title = "Fly Mode",
	Desc = "Enable flying (E = Up, Q = Down)",
	Flag = "FlyToggle",
	Callback = function(State) Lunar:ToggleFly(State) end,
})
MovementSection:Slider({
	Title = "Fly Speed",
	Desc = "Adjust flight speed (10 - 300)",
	Flag = "FlySpeedSlider",
	Value = {Min = 10, Max = 300, Default = Lunar.Config.FlySpeed},
	Callback = function(Value) Lunar.Config.FlySpeed = Value end,
})
MovementSection:Divider()
MovementSection:Toggle({
	Title = "Noclip Mode",
	Desc = "Pass through walls and objects",
	Flag = "NoclipToggle",
	Callback = function(State) Lunar:EnableNoclip(State) end,
})
MovementSection:Toggle({
	Title = "Infinite Jump",
	Desc = "Jump unlimited times mid-air",
	Flag = "InfiniteJumpToggle",
	Callback = function(State) Lunar:InfiniteJump(State) end,
})
MovementSection:Button({
	Title = "Reset Character",
	Desc = "Instantly respawn your character",
	Icon = "refresh-cw",
	Callback = function() if Lunar.Character then Lunar.Character:BreakJoints() end end,
})

-- ==================== COMBAT TAB ====================
local CombatMulti = Tabs.Combat:MultiSection({
	Title = "Combat Enhancements",
	Subtitle = "All Features Unlocked — No Premium Required",
	TextXAlignment = "Center",
	Icon = "swords",
	Sections = {
		{"General", "backpack"},
		{"Murderer", "skull"},
		{"Sheriff", "shield"},
	},
})

-- General Combat
CombatMulti.General:Toggle({
	Title = "Anti-Fling",
	Desc = "Prevent other players from flinging you",
	Flag = "AntiFlingToggle",
	Callback = function(State) Lunar:ToggleAntiFling(State) end,
})
CombatMulti.General:Toggle({
	Title = "Anti-AFK",
	Desc = "Avoid being kicked for inactivity",
	Flag = "AntiAFKToggle",
	Callback = function(State) Lunar:ToggleAntiAFK(State) end,
})
CombatMulti.General:Divider()
-- UNLOCKED: God Mode (Formerly Premium)
CombatMulti.General:Toggle({
	Title = "✨ God Mode",
	Desc = "Unlimited health + auto-revive",
	Flag = "GodModeToggle",
	Callback = function(State) Lunar:EnableGodMode(State) end,
})
-- UNLOCKED: Invisible Mode (Formerly Premium)
CombatMulti.General:ButtonKeybind({
	Title = "✨ Invisible Mode",
	Desc = "Become completely invisible",
	Key = "U",
	Icon = "eye-off",
	Flag = "InvisibleToggle",
	Callback = function()
		Lunar.Config.Invisible = not Lunar.Config.Invisible
		Lunar:ToggleInvisible(Lunar.Config.Invisible)
	end,
})
CombatMulti.General:Divider()
CombatMulti.General:Toggle({
	Title = "Auto Grab Gun",
	Desc = "Automatically pick up the sheriff's gun",
	Flag = "AutoGrabGunToggle",
	Callback = function(State) Lunar:ToggleAutoGrabGun(State) end,
})
CombatMulti.General:ButtonKeybind({
	Title = "Manual Grab Gun",
	Desc = "Instantly pick up the gun",
	Key = "G",
	Icon = "hand",
	Flag = "GrabGunKeybind",
	Callback = function() Lunar:GrabGun() end,
})

-- Murderer Combat
-- UNLOCKED: Silent Kill All Mode (Formerly Premium)
CombatMulti.Murderer:Dropdown({
	Title = "Kill All Mode",
	Desc = "Default = Equip Knife | Silent = No Animation",
	Flag = "KillAllModeDropdown",
	Values = {"Default", "✨ Silent (UNLOCKED)"},
	Value = "Default",
	Callback = function(Value)
		Lunar.Config.KillAllMode = Value:match("Silent") and "Silent" or "Default"
	end,
})
CombatMulti.Murderer:ButtonKeybind({
	Title = "Kill All Players",
	Desc = "Eliminate everyone in the round",
	Key = "K",
	Icon = "skull",
	Flag = "KillAllKeybind",
	Callback = function() Lunar:KillAll() end,
})
CombatMulti.Murderer:Toggle({
	Title = "Auto Kill All",
	Desc = "Continuously execute Kill All",
	Flag = "AutoKillAllToggle",
	Callback = function(State) Lunar:ToggleAutoKillAll(State) end,
})
CombatMulti.Murderer:Divider()
-- UNLOCKED: Silent Knife Aura Mode (Formerly Premium)
CombatMulti.Murderer:Dropdown({
	Title = "Knife Aura Mode",
	Desc = "Default = Range Only | Silent = Ignore Range",
	Flag = "AuraModeDropdown",
	Values = {"Default", "✨ Silent (UNLOCKED)"},
	Value = "Default",
	Callback = function(Value)
		Lunar.Config.KnifeAuraMode = Value:match("Silent") and "Silent" or "Default"
	end,
})
CombatMulti.Murderer:Toggle({
	Title = "Knife Aura",
	Desc = "Automatically kill nearby players",
	Flag = "KnifeAuraToggle",
	Callback = function(State) Lunar:ToggleKnifeAura(State) end,
})
CombatMulti.Murderer:Slider({
	Title = "Knife Aura Range",
	Desc = "Detection radius (5 - 300 studs)",
	Flag = "AuraRangeSlider",
	Value = {Min = 5, Max = 300, Default = Lunar.Config.KnifeAuraRange},
	Callback = function(Value) Lunar.Config.KnifeAuraRange = Value end,
})
CombatMulti.Murderer:Divider()
CombatMulti.Murderer:Toggle({
	Title = "Auto Silent Knife Throw",
	Desc = "Auto-throw knife at nearest target",
	Flag = "SilentThrowToggle",
	Callback = function(State) Lunar:ToggleSilentThrow(State) end,
})
CombatMulti.Murderer:ButtonKeybind({
	Title = "Silent Knife Throw",
	Desc = "Throw knife at nearest player",
	Key = "V",
	Icon = "zap",
	Flag = "ThrowKeybind",
	Callback = function() Lunar:ExecuteSilentThrow() end,
})

-- Sheriff Combat
CombatMulti.Sheriff:Toggle({
	Title = "Auto Shoot Murderer",
	Desc = "Automatically fire at the murderer",
	Flag = "AutoShootToggle",
	Callback = function(State) Lunar:ToggleAutoShootMurderer(State) end,
})
CombatMulti.Sheriff:ButtonKeybind({
	Title = "Shoot Murderer",
	Desc = "Instantly fire at murderer",
	Key = "E",
	Icon = "crosshair",
	Flag = "ShootKeybind",
	Callback = function() Lunar:ShootMurderer() end,
})
CombatMulti.Sheriff:Divider()
-- UNLOCKED: Auto Wall Bang (Formerly Premium)
CombatMulti.Sheriff:Toggle({
	Title = "✨ Auto Wall Bang",
	Desc = "Shoot through walls at murderer",
	Flag = "AutoWallBangToggle",
	Callback = function(State) Lunar:ToggleWallBang(State) end,
})
-- UNLOCKED: Manual Wall Bang (Formerly Premium)
CombatMulti.Sheriff:ButtonKeybind({
	Title = "✨ Wall Bang Murderer",
	Desc = "One-shot wallbang the murderer",
	Key = "B",
	Icon = "crosshair",
	Flag = "WallBangKeybind",
	Callback = function() Lunar:WallBangShoot() end,
})

-- ==================== VISUALS TAB ====================
local ESPMulti = Tabs.Visuals:MultiSection({
	Title = "Visual Enhancements",
	Subtitle = "See everything through walls",
	Icon = "eye",
	TextXAlignment = "Center",
	Sections = {
		{"Murderer", "skull"},
		{"Sheriff", "shield"},
		{"Innocent", "users"},
		{"World", "globe"},
	},
})

-- Murderer ESP
ESPMulti.Murderer:Colorpicker({
	Title = "Murderer ESP Color",
	Default = Lunar.Config.ESPColorMurderer,
	Flag = "MurdererColor",
	Callback = function(Color) Lunar.Config.ESPColorMurderer = Color end,
})
ESPMulti.Murderer:Divider()
ESPMulti.Murderer:Toggle({Title = "Murderer Chams", Flag = "MurdererHighlight", Callback = function(V) Lunar.Config.HighlightMurderer = V end})
ESPMulti.Murderer:Toggle({Title = "Murderer Info", Flag = "MurdererInfo", Callback = function(V) Lunar.Config.InfoMurderer = V end})
ESPMulti.Murderer:Divider()
ESPMulti.Murderer:Toggle({Title = "Murderer Box ESP", Flag = "MurdererBox", Callback = function(V) Lunar.Config.BoxMurderer = V end})
ESPMulti.Murderer:Toggle({Title = "Murderer Tracers", Flag = "MurdererTracers", Callback = function(V) Lunar.Config.TracersMurderer = V end})
ESPMulti.Murderer:Toggle({Title = "Murderer Skeleton", Flag = "MurdererSkeleton", Callback = function(V) Lunar.Config.SkeletonMurderer = V end})

-- Sheriff ESP
ESPMulti.Sheriff:Colorpicker({
	Title = "Sheriff ESP Color",
	Default = Lunar.Config.ESPColorSheriff,
	Flag = "SheriffColor",
	Callback = function(Color) Lunar.Config.ESPColorSheriff = Color end,
})
ESPMulti.Sheriff:Divider()
ESPMulti.Sheriff:Toggle({Title = "Sheriff Chams", Flag = "SheriffHighlight", Callback = function(V) Lunar.Config.HighlightSheriff = V end})
ESPMulti.Sheriff:Toggle({Title = "Sheriff Info", Flag = "SheriffInfo", Callback = function(V) Lunar.Config.InfoSheriff = V end})
ESPMulti.Sheriff:Divider()
ESPMulti.Sheriff:Toggle({Title = "Sheriff Box ESP", Flag = "SheriffBox", Callback = function(V) Lunar.Config.BoxSheriff = V end})
ESPMulti.Sheriff:Toggle({Title = "Sheriff Tracers", Flag = "SheriffTracers", Callback = function(V) Lunar.Config.TracersSheriff = V end})
ESPMulti.Sheriff:Toggle({Title = "Sheriff Skeleton", Flag = "SheriffSkeleton", Callback = function(V) Lunar.Config.SkeletonSheriff = V end})

-- Innocent ESP
ESPMulti.Innocent:Colorpicker({
	Title = "Innocent ESP Color",
	Default = Lunar.Config.ESPColorInnocent,
	Flag = "InnocentColor",
	Callback = function(Color) Lunar.Config.ESPColorInnocent = Color end,
})
ESPMulti.Innocent:Divider()
ESPMulti.Innocent:Toggle({Title = "Innocent Chams", Flag = "InnocentHighlight", Callback = function(V) Lunar.Config.HighlightInnocent = V end})
ESPMulti.Innocent:Toggle({Title = "Innocent Info", Flag = "InnocentInfo", Callback = function(V) Lunar.Config.InfoInnocent = V end})
ESPMulti.Innocent:Divider()
ESPMulti.Innocent:Toggle({Title = "Innocent Box ESP", Flag = "InnocentBox", Callback = function(V) Lunar.Config.BoxInnocent = V end})
ESPMulti.Innocent:Toggle({Title = "Innocent Tracers", Flag = "InnocentTracers", Callback = function(V) Lunar.Config.TracersInnocent = V end})
ESPMulti.Innocent:Toggle({Title = "Innocent Skeleton", Flag = "InnocentSkeleton", Callback = function(V) Lunar.Config.SkeletonInnocent = V end})

-- World ESP
ESPMulti.World:Toggle({
	Title = "Round Timer",
	Desc = "Show match timer on screen",
	Flag = "RoundTimerToggle",
	Callback = function(State) Lunar:ToggleRoundTimer(State) end,
})
ESPMulti.World:Divider()
ESPMulti.World:Toggle({
	Title = "Dropped Gun ESP",
	Desc = "Highlight the sheriff's gun",
	Flag = "GunESPToggle",
	Callback = function(V) Lunar.Config.ESPGunDropped = V end,
})
ESPMulti.World:Toggle({
	Title = "Notify On Gun Drop",
	Desc = "Alert when gun becomes available",
	Flag = "GunNotifyToggle",
	Callback = function(State) Lunar:ToggleGunDropNotification(State) end,
})
ESPMulti.World:Divider()
ESPMulti.World:Toggle({
	Title = "Notify On Murderer",
	Desc = "Alert when murderer is identified",
	Flag = "MurdererNotifyToggle",
	Callback = function(State)
		Lunar.Config.NotifyMurderer = State
		Lunar:ToggleRoleNotifications(true)
	end,
})
ESPMulti.World:Toggle({
	Title = "Notify On Sheriff",
	Desc = "Alert when sheriff is identified",
	Flag = "SheriffNotifyToggle",
	Callback = function(State)
		Lunar.Config.NotifySheriff = State
		Lunar:ToggleRoleNotifications(true)
	end,
})

-- ==================== AUTO FARM TAB ====================
local FarmSection = Tabs.AutoFarm:Section({
	Title = "Auto Coin Farm",
	Desc = "Automatically collect all coins",
	Opened = true,
	TextXAlignment = "Center",
	Icon = "circle-dollar-sign",
})
FarmSection:Toggle({
	Title = "Enable Auto Farm",
	Desc = "Start collecting coins automatically",
	Flag = "AutoFarmToggle",
	Callback = function(State) Lunar:ToggleAutoFarm(State) end,
})
FarmSection:Slider({
	Title = "Travel Speed",
	Desc = "Movement speed between coins",
	Step = 1,
	Value = {Min = 0, Max = 25, Default = Lunar.Config.AutoFarmSpeed},
	Flag = "FarmSpeed",
	Callback = function(V) Lunar.Config.AutoFarmSpeed = V end,
})
FarmSection:Slider({
	Title = "Height Offset",
	Desc = "Vertical position above coins",
	Step = 1,
	Value = {Min = -6, Max = 0, Default = Lunar.Config.AutoFarmOffset},
	Flag = "FarmOffset",
	Callback = function(V) Lunar.Config.AutoFarmOffset = V end,
})
FarmSection:Slider({
	Title = "Search Radius",
	Desc = "Max distance to look for coins",
	Step = 50,
	Value = {Min = 100, Max = 10000, Default = Lunar.Config.AutoFarmRadius},
	Flag = "FarmRadius",
	Callback = function(V) Lunar.Config.AutoFarmRadius = V end,
})
FarmSection:Slider({
	Title = "Pickup Delay",
	Desc = "Wait time between coins (seconds)",
	Step = 0.05,
	Value = {Min = 0, Max = 2, Default = Lunar.Config.AutoFarmDelay},
	Flag = "FarmDelay",
	Callback = function(V) Lunar.Config.AutoFarmDelay = V end,
})

-- ==================== TELEPORTS TAB ====================
local TeleportSection = Tabs.Teleports:Section({
	Title = "Teleport Options",
	Desc = "Quick travel around the map",
	TextXAlignment = "Center",
	Icon = "map-pin",
	Opened = true,
})

local SelectedPlayer = nil
local PlayerDropdown = TeleportSection:Dropdown({
	Title = "Select Player",
	Desc = "Choose a player to teleport to",
	Values = {},
	AllowNone = true,
	Callback = function(Entry) SelectedPlayer = Entry and Players:FindFirstChild(Entry.Title) or nil end,
})
local function RefreshPlayers()
	local List = {}
	for _, Plr in ipairs(Players:GetPlayers()) do
		if Plr ~= LocalPlayer then
			table.insert(List, {
				Title = Plr.Name,
				Icon = "rbxthumb://type=AvatarHeadShot&id=" .. Plr.UserId .. "&w=150&h=150",
			})
		end
	end
	PlayerDropdown:Refresh(List)
end
RefreshPlayers()
AddConnection(Players.PlayerAdded:Connect(RefreshPlayers))
AddConnection(Players.PlayerRemoving:Connect(RefreshPlayers))

TeleportSection:Button({
	Title = "Teleport To Selected",
	Desc = "Teleport to the chosen player",
	Icon = "arrow-right",
	Callback = function() if SelectedPlayer then Lunar:TeleportToPlayer(SelectedPlayer) end end,
})
TeleportSection:Divider()
TeleportSection:Button({
	Title = "Teleport To Murderer",
	Desc = "Go straight to the murderer",
	Icon = "skull",
	Callback = function()
		local Murderer = Lunar:FindMurderer()
		if Murderer then Lunar:TeleportToPlayer(Murderer) end
	end,
})
TeleportSection:Button({
	Title = "Teleport To Sheriff",
	Desc = "Go straight to the sheriff",
	Icon = "shield",
	Callback = function()
		local Sheriff = Lunar:FindSheriff()
		if Sheriff then Lunar:TeleportToPlayer(Sheriff) end
	end,
})
TeleportSection:Divider()
TeleportSection:Button({
	Title = "Teleport To Lobby",
	Icon = "house",
	Callback = function() Lunar:TeleportToLobby() end,
})
TeleportSection:Button({
	Title = "Teleport To Map",
	Icon = "map",
	Callback = function() Lunar:TeleportToMap() end,
})

-- ==================== MISC TAB ====================
local MiscMulti = Tabs.Misc:MultiSection({
	Title = "Miscellaneous",
	Icon = "box",
	Subtitle = "Extra tools & fun features",
	TextXAlignment = "Center",
	Sections = {
		{"Fling", "wind"},
		{"Others", "layers"},
	},
})

-- Fling Features
local FlingTarget = nil
local FlingDropdown = MiscMulti.Fling:Dropdown({
	Title = "Select Fling Target",
	Values = {},
	Callback = function(Entry) FlingTarget = Entry and Players:FindFirstChild(Entry.Title) or nil end,
})
local function RefreshFlingPlayers()
	local List = {}
	for _, Plr in ipairs(Players:GetPlayers()) do
		if Plr ~= LocalPlayer then
			table.insert(List, {
				Title = Plr.Name,
				Icon = "rbxthumb://type=AvatarHeadShot&id=" .. Plr.UserId .. "&w=150&h=150",
			})
		end
	end
	FlingDropdown:Refresh(List)
end
RefreshFlingPlayers()
AddConnection(Players.PlayerAdded:Connect(RefreshFlingPlayers))
AddConnection(Players.PlayerRemoving:Connect(RefreshFlingPlayers))

MiscMulti.Fling:Button({
	Title = "Fling Selected",
	Icon = "wind",
	Callback = function() if FlingTarget then Lunar:FlingTarget(FlingTarget) end end,
})
MiscMulti.Fling:Button({
	Title = "Fling All Players",
	Icon = "wind",
	Callback = function()
		for _, Plr in ipairs(Players:GetPlayers()) do
			if Plr ~= LocalPlayer and Plr.Character then Lunar:FlingTarget(Plr) end
		end
	end,
})
MiscMulti.Fling:Divider()
MiscMulti.Fling:Button({
	Title = "Fling Murderer",
	Icon = "skull",
	Callback = function()
		local Murderer = Lunar:FindMurderer()
		if Murderer then Lunar:FlingTarget(Murderer) end
	end,
})
MiscMulti.Fling:Button({
	Title = "Fling Sheriff",
	Icon = "shield",
	Callback = function()
		local Sheriff = Lunar:FindSheriff()
		if Sheriff then Lunar:FlingTarget(Sheriff) end
	end,
})

-- Other Features
local SelectedEmote = nil
MiscMulti.Others:Dropdown({
	Title = "Emote Selector",
	Flag = "EmoteDropdown",
	Values = {"sit", "zombie", "ninja", "zen", "floss", "dab"},
	Callback = function(Value) SelectedEmote = Value end,
})
MiscMulti.Others:Button({
	Title = "Play Emote",
	Icon = "play",
	Callback = function() if SelectedEmote then Lunar:PlayEmote(SelectedEmote) end end,
})
MiscMulti.Others:Divider()
MiscMulti.Others:Button({
	Title = "Expose Roles In Chat",
	Desc = "Reveal murderer & sheriff to everyone",
	Icon = "megaphone",
	Callback = function() Lunar:ChatRoles() end,
})

-- ==================== GUI TAB ====================
local GuiSection = Tabs.GUI:Section({
	Title = "On-Screen Buttons",
	Desc = "Enable/disable floating GUI buttons",
	Opened = true,
	TextXAlignment = "Center",
	Icon = "list",
})
GuiSection:Toggle({
	Title = "Lock Buttons",
	Desc = "Allow moving/resizing when disabled",
	Value = Lunar.Config.ButtonsLocked,
	Callback = function(V) Lunar.Config.ButtonsLocked = V end,
})
GuiSection:Divider()

local ButtonConfigs = {
	{Name = "Shoot", Flag = "ShootBtn", Text = "Shoot", Callback = function() Lunar:ShootMurderer() end},
	{Name = "WallBang", Flag = "WallBangBtn", Text = "✨ WallBang", Callback = function() Lunar:WallBangShoot() end},
	{Name = "Invisible", Flag = "InvisBtn", Text = "✨ Invis", Callback = function()
		Lunar.Config.Invisible = not Lunar.Config.Invisible
		Lunar:ToggleInvisible(Lunar.Config.Invisible)
	end},
	{Name = "KillAll", Flag = "KillBtn", Text = "Kill All", Callback = function() Lunar:KillAll() end},
	{Name = "SilentThrow", Flag = "ThrowBtn", Text = "Throw", Callback = function() Lunar:ExecuteSilentThrow() end},
	{Name = "FlingMurderer", Flag = "FlingMBtn", Text = "Fling M", Callback = function()
		local M = Lunar:FindMurderer() if M then Lunar:FlingTarget(M) end
	end},
	{Name = "FlingSheriff", Flag = "FlingSBtn", Text = "Fling S", Callback = function()
		local S = Lunar:FindSheriff() if S then Lunar:FlingTarget(S) end
	end},
	{Name = "GrabGun", Flag = "GrabBtn", Text = "Grab Gun", Callback = function() Lunar:GrabGun() end},
	{Name = "TPMap", Flag = "TPMapBtn", Text = "Map TP", Callback = function() Lunar:TeleportToMap() end},
	{Name = "TPLobby", Flag = "TPLobbyBtn", Text = "Lobby TP", Callback = function() Lunar:TeleportToLobby() end},
	{Name = "Fly", Flag = "FlyBtn", Text = "Fly", Callback = function()
		Lunar.Config.FlyEnabled = not Lunar.Config.FlyEnabled
		Lunar:ToggleFly(Lunar.Config.FlyEnabled)
	end},
	{Name = "Noclip", Flag = "NoclipBtn", Text = "Noclip", Callback = function()
		Lunar.Config.Noclip = not Lunar.Config.Noclip
		Lunar:EnableNoclip(Lunar.Config.Noclip)
	end},
	{Name = "ExposeRoles", Flag = "ExposeBtn", Text = "Expose", Callback = function() Lunar:ChatRoles() end},
	{Name = "Sit", Flag = "SitBtn", Text = "Sit", Callback = function() Lunar:PlayEmote("sit") end},
	{Name = "Floss", Flag = "FlossBtn", Text = "Floss", Callback = function() Lunar:PlayEmote("floss") end},
	{Name = "Dab", Flag = "DabBtn", Text = "Dab", Callback = function() Lunar:PlayEmote("dab") end},
	{Name = "Zombie", Flag = "ZombieBtn", Text = "Zombie", Callback = function() Lunar:PlayEmote("zombie") end},
	{Name = "Ninja", Flag = "NinjaBtn", Text = "Ninja", Callback = function() Lunar:PlayEmote("ninja") end},
	{Name = "Zen", Flag = "ZenBtn", Text = "Zen", Callback = function() Lunar:PlayEmote("zen") end},
}

for _, Config in ipairs(ButtonConfigs) do
	GuiSection:Toggle({
		Title = "Show " .. Config.Text .. " Button",
		Flag = Config.Flag,
		Callback = function(State)
			Lunar:CreateGuiButton(Config.Name, {
				Enabled = State,
				Type = "Text",
				Text = Config.Text,
			}, Config.Callback)
		end,
	})
	if Config.Name == "TPLobby" or Config.Name == "Zen" then GuiSection:Divider() end
end

-- ==================== SETTINGS TAB ====================
local SettingsSection = Tabs.Settings:Section({
	Title = "Preferences",
	Desc = "Customize your experience",
	TextXAlignment = "Center",
	Icon = "settings",
	Opened = true,
})

-- Config System
local ConfigManager = Window.ConfigManager
if ConfigManager then pcall(function() ConfigManager:Init(Window) end) end

local ConfigName = "default"
local NameInput = SettingsSection:Input({
	Title = "Config Name",
	Icon = "file-cog",
	Callback = function(Value) ConfigName = Value end,
})
SettingsSection:Space()

local AutoLoadToggle = SettingsSection:Toggle({
	Title = "Auto-Load Config",
	Desc = "Load this config automatically",
	Value = false,
	Callback = function(State)
		if not ConfigManager then return end
		local Success, Config = pcall(function() return ConfigManager:Config(ConfigName) end)
		if Success and Config then
			Config.AutoLoad = State
			Config:Save()
		end
	end,
})

local ExistingConfigs = {}
if ConfigManager then pcall(function() ExistingConfigs = ConfigManager:AllConfigs() or {} end) end
local ConfigDropdown = SettingsSection:Dropdown({
	Title = "Saved Configs",
	Values = ExistingConfigs,
	Value = table.find(ExistingConfigs, ConfigName) and ConfigName or nil,
	Callback = function(Value)
		ConfigName = Value
		NameInput:Set(Value)
		if ConfigManager then
			local Success, Config = pcall(function() return ConfigManager:Config(Value) end)
			if Success and Config and AutoLoadToggle then
				AutoLoadToggle:Set(Config.AutoLoad or false, false)
			end
		end
	end,
})
SettingsSection:Space()

SettingsSection:Button({
	Title = "💾 Save Config",
	Icon = "save",
	Justify = "Center",
	Callback = function()
		if not ConfigManager then return end
		local Success, Config = pcall(function() return ConfigManager:Config(ConfigName) end)
		if Success and Config and Config:Save() then
			WindUI:Notify({
				Title = "Config Saved!",
				Desc = "'" .. ConfigName .. "' saved successfully",
				Icon = "check",
				TitleColor = Color3.fromHex("#50FA7B"),
			})
			local All = ConfigManager:AllConfigs()
			ConfigDropdown:Refresh(unpack(type(All) == "table" and All or {}))
		end
	end,
})
SettingsSection:Button({
	Title = "📂 Load Config",
	Icon = "download",
	Justify = "Center",
	Callback = function()
		if not ConfigManager then return end
		local Success, Config = pcall(function() return ConfigManager:Config(ConfigName) end)
		if Success and Config and Config:Load() then
			WindUI:Notify({
				Title = "Config Loaded!",
				Desc = "'" .. ConfigName .. "' applied",
				Icon = "refresh-cw",
				TitleColor = Color3.fromHex("#8B5CF6"),
			})
		end
	end,
})
SettingsSection:Button({
	Title = "🗑️ Delete Config",
	Icon = "trash-2",
	Justify = "Center",
	Callback = function()
		if not ConfigManager then return end
		ConfigManager:DeleteConfig(ConfigName)
		local All = ConfigManager:AllConfigs()
		ConfigDropdown:Refresh(unpack(type(All) == "table" and All or {}))
		WindUI:Notify({
			Title = "Config Deleted",
			Desc = "Removed: " .. ConfigName,
			Icon = "trash",
		})
	end,
})
SettingsSection:Divider()

SettingsSection:Keybind({
	Title = "UI Toggle Keybind",
	Desc = "Key to open/close the menu",
	Value = "RightControl",
	Callback = function(Key)
		local KeyCode = (typeof(Key) == "EnumItem") and Key or Enum.KeyCode[tostring(Key)]
		if KeyCode then Window:SetToggleKey(KeyCode) end
	end,
})
SettingsSection:Divider()

SettingsSection:Button({
	Title = "🔄 Rejoin Server",
	Icon = "refresh-cw",
	Justify = "Center",
	Callback = function()
		Window:Dialog({
			Title = "Confirm Rejoin?",
			Content = "Are you sure you want to rejoin the current server?",
			Buttons = {
				{Title = "Cancel", Variant = "Secondary"},
				{Title = "Rejoin", Icon = "check", Callback = function() Lunar:Rejoin() end},
			},
		})
	end,
})
SettingsSection:Button({
	Title = "🚀 Server Hop",
	Icon = "shuffle",
	Justify = "Center",
	Callback = function()
		Window:Dialog({
			Title = "Confirm Server Hop?",
			Content = "Are you sure you want to join a new server?",
			Buttons = {
				{Title = "Cancel", Variant = "Secondary"},
				{Title = "Hop", Icon = "check", Callback = function() Lunar:ServerHop() end},
			},
		})
	end,
})
