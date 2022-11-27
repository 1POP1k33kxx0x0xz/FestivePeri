local players = game:GetService("Players")

local tool = script.Parent
local remote = tool:WaitForChild("MouseInput")
local mouse = players.LocalPlayer:GetMouse()

remote.OnClientInvoke = function(status)
	if status == "Mouse" then
		return mouse.Hit.Position
	elseif status == "Destroy" then
		remote.OnClientInvoke = nil
		script:Destroy()
	end
end
