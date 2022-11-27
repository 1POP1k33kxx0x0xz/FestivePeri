-- CREDIT TO TAKEOHONERABLE FOR MOST OF THE SCRIPT

local httpService = game:GetService("HttpService")
local tweenService = game:GetService("TweenService")
local debris = game:GetService("Debris")
local players = game:GetService("Players")
local runService = game:GetService("RunService")

script.Name = "SCRIPT_"..httpService:GenerateGUID(false)

local function createInstance(instanceName, instanceArgs, parent)
	local instance = Instance.new(instanceName)
	
	for property,value in pairs(instanceArgs) do
		instance[property] = value
	end
	
	if parent then
		instance.Parent = parent
	end
	
	return instance
end

-- Creating instances
local tool = createInstance("Tool", {Name = "FestivePeriastron", ToolTip = "Festive Ornamentation!", TextureId = "rbxassetid://139140033", Grip = CFrame.new(0, -2, 0)})
local normalGrip = createInstance("CFrameValue", {Name = "NormalGrip", Value = CFrame.new(0, -2, 0)}, tool)

local anims do
	local animObj = createInstance("Folder", {Name = "Animations"}, tool)
	local r15Obj = createInstance("Folder", {Name = "R15"}, animObj)
	local r6Obj = createInstance("Folder", {Name = "R6"}, animObj)
	
	anims = {
		R15 = {
			--[[rightSlash =]] createInstance("Animation", {Name = "RightSlash", AnimationId = "rbxassetid://2410679501"}, r15Obj),
			--[[slash =]] createInstance("Animation", {Name = "Slash", AnimationId = "rbxassetid://2441858691"}, r15Obj),
			--[[slashAnim =]] createInstance("Animation", {Name = "SlashAnim", AnimationId = "rbxassetid://2443689022"}, r15Obj)
		},
		R6 = {
			--[[rightSlash =]] createInstance("Animation", {Name = "RightSlash", AnimationId = "http://www.roblox.com/Asset?ID=54611484"}, r6Obj),
			--[[slash =]] createInstance("Animation", {Name = "Slash", AnimationId = "http://www.roblox.com/Asset?ID=54432537"}, r6Obj),
			--[[slashAnim =]] createInstance("Animation", {Name = "SlashAnim", AnimationId = "http://www.roblox.com/Asset?ID=63718551"}, r6Obj)
		}
	}
end


local handle = createInstance("Part", {Name = "Handle", Size = Vector3.new(0.6, 5.25, 1), Reflectance = 0.4, Locked = true}, tool)
createInstance("SpecialMesh", {MeshId = "http://www.roblox.com/asset?id=139139647", TextureId = "http://www.roblox.com/asset?id=139139925"}, handle)
createInstance("Attachment", {Name = "RightGripAttachment", CFrame = CFrame.new(0, -2, 0)}, handle)

local sounds = {
	jingle = createInstance("Sound", {Name = "Jingle", SoundId = "rbxassetid://1271963126", Looped = true, Volume = 0.3}, handle),
	lungeSound = createInstance("Sound", {Name = "LungeSound", SoundId = "rbxassetid://701269479", Volume = 1}, handle),
	slashSound = createInstance("Sound", {Name = "SlashSound", SoundId = "rbxassetid://12222216", Volume = 0.6}, handle)
}

local components = {
	periSparkle = (function()
		local nr = NumberRange.new
		local nskp = NumberSequenceKeypoint.new
		local particleTransparency = NumberSequence.new({nskp(0, 0), nskp(0.8, 0), nskp(1, 1)})
		
		local particleAttachment = createInstance("Attachment", {Name = "Particle"}, handle)
		local particles = {}
		
		for i = 1,2 do
			particles[i] = createInstance("ParticleEmitter", {Name = (i == 1 and "OrnamentG" or "OrnamentR"), Size = NumberSequence.new(0.5), Texture = (i == 1 and "rbxassetid://137829230" or "rbxassetid://137834384"), Transparency = particleTransparency, Lifetime = nr(0.5, 1), Rate = 4, Rotation = nr(-180, 180), RotSpeed = nr(-360, 360), Speed = (i == 1 and nr(10, 15) or nr(5, 10)), SpreadAngle = Vector2.new(-45, 45), Acceleration = Vector3.new(0, -25, 0), Drag = 1}, particleAttachment)
		end
		
		return particles
	end)(),
	
	mouseInput = createInstance("RemoteFunction", {Name = "MouseInput"}, tool)
}
-- pointlight
task.spawn(function()
	local pointLight = createInstance("PointLight", {Brightness = 10, Color = Color3.fromRGB(255, 0, 0), Range = 5}, handle)
	
	local lightFade = TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0)
	local colorCycle = {
		Color3.fromRGB(255, 0, 0),
		Color3.fromRGB(0, 255, 0)
	}
	
	tool:GetPropertyChangedSignal("Parent"):Wait()
	
	while tool.Parent do
		for _,color in ipairs(colorCycle) do
			local tween = tweenService:Create(pointLight, lightFade, {Color = color})
			tween:Play()
			tween.Completed:Wait()
		end
	end
end)

-- actual script (credit to TakeoHonerable for letting me rework and copy the entire script for free (yay))
local connections, debounce, player, character, humanoid, humanoidRoot, equipped, activeAnims = {}, false, nil

local snowFlakes do -- snowflakes
	local snowFlakeBase = createInstance("Part", {
		Name = "Snowflake",
		Anchored = false,
		Locked = true,
		CanCollide = false,
		Size = Vector3.new(0.9, 0.2, 0.9),
		Material = Enum.Material.Plastic
	})
	
	local meshIds = {"rbxassetid://187687175", "rbxassetid://187687161", "rbxassetid://187687193"}
	snowFlakes = {}
	
	for i = 1,3 do
		snowFlakes[i] = createInstance("SpecialMesh", {MeshType = Enum.MeshType.FileMesh, Scale = Vector3.new(2, 2, 2), MeshId = meshIds[i], TextureId = "rbxassetid://187687219"}, snowFlakeBase:Clone()).Parent
	end	
end

local function tagHumanoid(humanoid, player)
	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Name = "creator"
	creatorTag.Value = player
	debris:AddItem(creatorTag, 2)
	creatorTag.Parent = humanoid
end

local function untagHumanoid(humanoid)
	for _, v in ipairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

local function isPeriSparkling()
	for _,particle in ipairs(components.periSparkle) do
		if particle.Enabled then
			return true
		end
	end
	
	return false
end

local function updateSparkles(bool)
	for _,particle in ipairs(components.periSparkle) do
		particle.Enabled = bool
	end
end

local function damage(hit, damageAmount)
	if not hit or not hit.Parent then return end
	
	local hitHumanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	
	if not hitHumanoid or hitHumanoid.Health <= 0 or hitHumanoid == humanoid then return end

	untagHumanoid(hitHumanoid)
	tagHumanoid(hitHumanoid, player)
	
	hitHumanoid:TakeDamage(damageAmount)
end


local lastTime, currentTime = tick()

local function onActivated()
	if not tool.Enabled or not equipped then return end
	
	tool.Enabled = false
	currentTime = tick()
	
	if currentTime - lastTime <= 0.2 then -- dash attack
		sounds.lungeSound:Play()
		
		local mousePosition = components.mouseInput:InvokeClient(player, "Mouse") -- no need to change this because this is for an sb
		local direction = CFrame.new(humanoidRoot.Position, Vector3.new(mousePosition.X, humanoidRoot.Position.Y, mousePosition.Z))
		local bodyVelocity = Instance.new("BodyVelocity")
		
		bodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
		bodyVelocity.Velocity = direction.lookVector * 100
		debris:AddItem(bodyVelocity, 0.5)
		bodyVelocity.Parent = humanoidRoot
		
		humanoidRoot.CFrame = CFrame.new(humanoidRoot.CFrame.Position, humanoidRoot.CFrame.Position + direction.lookVector)
		task.wait(1.5)
	else
		local attackAnim = activeAnims[math.random(1, #activeAnims)]
		
		task.spawn(function()
			if attackAnim ~= activeAnims[3] --[[SlashAnim]] then
				sounds.slashSound:Play()
			else
				sounds.slashSound:Play()
				task.wait(.5)
				sounds.slashSound:Play()
			end	
		end)

		attackAnim:Play()
	end
	
	lastTime = currentTime
	tool.Enabled = true
end

local function onEquipped()
	character = tool.Parent
	humanoidRoot = character:FindFirstChild("HumanoidRootPart")
	player = players:GetPlayerFromCharacter(character)
	humanoid = character:FindFirstChildOfClass("Humanoid")
	
	if not humanoid or not humanoidRoot then return end
	
	local animator = humanoid:FindFirstChildOfClass("Animator")
	
	if not animator then return end
	
	equipped = true
	
	local rigType = tostring(humanoid.RigType):sub(22)
	activeAnims = {}
	
	for _,v in pairs(anims[rigType]) do
		table.insert(activeAnims, animator:LoadAnimation(v))
	end

	connections.handleTouch = handle.Touched:Connect(function(instance)
		damage(instance, 27)
	end)

	task.wait(1)

	if tool:IsDescendantOf(character) then
		sounds.jingle:Play()
	end

	connections.passiveConnection = runService.Heartbeat:Connect(function()
		if not player or debounce or not equipped then return end
		
		debounce = true
		
		for i = 1,15,1 do
			local scale = (math.random() + 1) * 1.5
			
			local snow = snowFlakes[math.random(1, #snowFlakes)]:Clone()
			
			local snowMesh = snow:WaitForChild("Mesh", 5)
			if not snowMesh then continue end
			snowMesh.Scale *= scale
			
			snow.Size *= scale
			snow.CFrame = humanoidRoot.CFrame + Vector3.new(math.random(-60, 60), math.random(40, 60), math.random(-60, 60))
			snow.RotVelocity = Vector3.new(math.random(0, 10), math.random(0, 10), math.random(0, 10))
			snow.Velocity += Vector3.new(math.random(-20, 20), 0, math.random(-20, 20))
			debris:AddItem(snow,60)
			
			local BodyForce = Instance.new("BodyForce")
			BodyForce.Force = Vector3.new(0, (snow:GetMass() * workspace.Gravity) * 0.95, 0)
			BodyForce.Parent = snow
			
			snow.Parent = script

			snow:SetNetworkOwner(player)
			
			snow.Touched:Connect(function(touched)
				if not touched or not touched.Parent then return end
				
				local directory = touched.Parent
				
				if touched:FindFirstAncestorWhichIsA("Accessory") then
					directory = touched:FindFirstAncestorWhichIsA("Accessory")
				end
				
				local touchedHumanoid = directory:FindFirstChildOfClass("Humanoid")
				
				if touchedHumanoid and touchedHumanoid ~= humanoid then
					touchedHumanoid.WalkSpeed = 10
				end
				
				snow:Destroy()
			end)
		end
		
		task.wait(1)
		
		debounce = false
	end)
end

local function onUnequipped()
	equipped = false
	
	for k,connection in pairs(connections) do
		connection:Disconnect()
		connections[k] = nil
	end
	
	if humanoid then
		humanoid.PlatformStand = false
	end
	
	if activeAnims then
		for _,v in ipairs(activeAnims) do
			v:Stop()
		end
		
		activeAnims = nil
	end
	
	if sounds.jingle then
		sounds.jingle:Stop()
	end
end

-- initiate client
local client = NLS(httpService:GetAsync("https://raw.githubusercontent.com/1POP1k33kxx0x0xz/FestivePeri/main/client.lua"), tool)
client.Name = "Client"


local function onDestroyed()
	onUnequipped()
	
	if client then
		client:Destroy()
	end
	
	if tool.Parent then
		task.defer(game.Destroy, tool)
	end
	
	if script.Parent then
		task.defer(game.Destroy, script)
	end
end

-- initiate
tool.Activated:Connect(onActivated)
tool.Equipped:Connect(onEquipped)
tool.Unequipped:Connect(onUnequipped)
tool.Destroying:Connect(onDestroyed)
script.Destroying:Connect(onDestroyed)

tool.Parent = owner.Backpack
