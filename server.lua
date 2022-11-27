local tweenService = game:GetService("TweenService")

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

local animations do
	local animObj = createInstance("Folder", {Name = "Animations"}, tool)
	local r15Obj = createInstance("Folder", {Name = "R15"}, animObj)
	local r6Obj = createInstance("Folder", {Name = "R6"}, animObj)
	
	animations = {
		r15 = {
			rightSlash = createInstance("Animation", {Name = "RightSlash", AnimationId = "rbxassetid://2410679501"}, r15Obj),
			slash = createInstance("Animation", {Name = "Slash", AnimationId = "rbxassetid://2441858691"}, r15Obj),
			slashAnim = createInstance("Animation", {Name = "SlashAnim", AnimationId = "rbxassetid://2443689022"}, r15Obj)
		},
		r6 = {
			rightSlash = createInstance("Animation", {Name = "RightSlash", AnimationId = "http://www.roblox.com/Asset?ID=54611484"}, r6Obj),
			slash = createInstance("Animation", {Name = "Slash", AnimationId = "http://www.roblox.com/Asset?ID=54432537"}, r6Obj),
			slashAnim = createInstance("Animation", {Name = "SlashAnim", AnimationId = "http://www.roblox.com/Asset?ID=63718551"}, r6Obj)
		}
	}
end


local handle = createInstance("Part", {Name = "Handle", Size = Vector3.new(0.6, 5.25, 1), Reflectance = 0.4}, tool)
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
	
	while pointLight.Parent do
		for _,color in ipairs(colorCycle) do
			local tween = tweenService:Create(pointLight, lightFade, {Color = color})
			tween:Play()
			tween.Completed:Wait()
		end
	end
end)

tool.Parent = workspace
