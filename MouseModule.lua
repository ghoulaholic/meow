local module = {}
local player = game.Players.LocalPlayer
local normalMouse = player:GetMouse()
local camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
 
local bindable = Instance.new("BindableEvent")
local oldPos = Vector2.new()
local oldVel = Vector3.new()
 
local mouse = setmetatable({TargetFilter = {},
 
    Raycast = function(self, parameters: RaycastParams | nil, distance)
        local ray = camera:ViewportPointToRay(self.Position.X, self.Position.Y)
        return workspace:Raycast(ray.Origin, ray.Direction*(distance or 1000), parameters or RaycastParams.new())
    end,
 
    AddToFilter = function(self, obj)
        if typeof(obj) == "Instance" then
            table.insert(self.TargetFilter, obj)
        elseif typeof(obj) == "table" then
            for _, v in ipairs(obj) do
                self:AddToFilter(v)
            end
        elseif typeof(obj) == "string" then
            self:AddToFilter(CollectionService:GetTagged(obj))
        end
    end,    
 
    RemoveFromFilter = function(self, obj)
        if typeof(obj) == "Instance" then
            for i, v in ipairs(self.TargetFilter) do
                if v == obj then
                    table.remove(self.TargetFilter, i)
                end
            end
        elseif typeof(obj) == "table" then
            for _, v in ipairs(obj) do
                self:RemoveFromFilter(v)
            end
        elseif typeof(obj) == "string" then
            for _, v in ipairs(CollectionService:GetTagged(obj)) do
                self:RemoveFromFilter(v)
            end
        end
    end,
 
    IsInFilter = function(self, obj)
        local found = false
        for _, v in ipairs(self.TargetFilter) do
            if v == obj then
                found = true
                break
            end
        end
        return found
    end
 
}, 
{__index = function(mouse, prop)
    if player.Character and not mouse:IsInFilter(player.Character) then
        mouse:AddToFilter(player.Character)
    end
    
    local MAX = 1e4
    local PARAMS = RaycastParams.new()
    PARAMS.FilterDescendantsInstances = {mouse.TargetFilter}
    PARAMS.FilterType = Enum.RaycastFilterType.Blacklist
    
    local props = {
        Position = function() return UIS:GetMouseLocation() end,
        Hit = function()
            local result, otherResult = mouse:Raycast(PARAMS), camera:ViewportPointToRay(mouse.Position.X, mouse.Position.Y)
            return (result and CFrame.lookAt(result.Position, result.Position+otherResult.Direction) or CFrame.lookAt(otherResult.Origin+otherResult.Direction*MAX, otherResult.Origin+otherResult.Direction*MAX))
        end,
        Target = function()
            local result = mouse:Raycast(PARAMS, MAX)
            return result and result.Instance or nil
        end,
        Delta = function()
            return mouse.Position - oldPos
        end,
        TargetSurface = function()
            local result = mouse:Raycast(PARAMS, MAX)
            local faces = {
                [tostring(Vector3.FromNormalId(Enum.NormalId.Back))] = Enum.NormalId.Back,
                [tostring(Vector3.FromNormalId(Enum.NormalId.Front))] = Enum.NormalId.Front,
                [tostring(Vector3.FromNormalId(Enum.NormalId.Left))] = Enum.NormalId.Left,
                [tostring(Vector3.FromNormalId(Enum.NormalId.Right))] = Enum.NormalId.Right,
                [tostring(Vector3.FromNormalId(Enum.NormalId.Top))] = Enum.NormalId.Top,
                [tostring(Vector3.FromNormalId(Enum.NormalId.Bottom))] = Enum.NormalId.Bottom
            }
 
            return result and faces[tostring((mouse.Target.CFrame-mouse.Target.CFrame.Position):Inverse()*result.Normal)] or nil
        end,
        Origin = function()
            return CFrame.lookAt(camera.CFrame.Position, mouse.Hit.Position)
        end,
        UnitRay = function()
            return Ray.new(mouse.Origin.Position, (mouse.Hit.Position-camera.CFrame.Position).Unit) --deprecated but who cares
        end,
        ViewportSize = function() return camera.ViewportSize end,
        ViewSizeX = function() return mouse.ViewportSize.X end,
        ViewSizeY = function() return mouse.ViewportSize.Y end,
        Icon = function() return normalMouse.Icon end,
        Parent = function() return nil end, --this is done because normalMouse.Parent is always nil, and causes some problems with the spaghetti below
        
        -- events --
        
        Button1Down = function()
            local clone = bindable:Clone()
            UIS.InputBegan:Connect(function(inputType, gameProcessed)
                if not(gameProcessed) and inputType.UserInputType == Enum.UserInputType.MouseButton1 and inputType.UserInputState == Enum.UserInputState.Begin then
                    clone:Fire(Vector2.new(inputType.Position.X, inputType.Position.Y))
                end
            end)
            return clone.Event
        end,
 
        Button1Up = function()
            local clone = bindable:Clone()
            UIS.InputEnded:Connect(function(inputType, gameProcessed)
                if not(gameProcessed) and inputType.UserInputState == Enum.UserInputState.End and inputType.UserInputType == Enum.UserInputType.MouseButton1 then
                    clone:Fire(Vector2.new(inputType.Position.X, inputType.Position.Y))
                end
            end)
            return clone.Event
        end,
 
        Button2Down = function()
            local clone = bindable:Clone()
            UIS.InputBegan:Connect(function(inputType, gameProcessed)
                if not(gameProcessed) and inputType.UserInputType == Enum.UserInputType.MouseButton2 and inputType.UserInputState == Enum.UserInputState.Begin then
                    clone:Fire(Vector2.new(inputType.Position.X, inputType.Position.Y))
                end
            end)
            return clone.Event
        end,
 
        Button2Up = function()
            local clone = bindable:Clone()
            UIS.InputEnded:Connect(function(inputType, gameProcessed)
                if not(gameProcessed) and inputType.UserInputType == Enum.UserInputType.MouseButton2 and inputType.UserInputState == Enum.UserInputState.End then
                    clone:Fire(Vector2.new(inputType.Position.X, inputType.Position.Y))
                end
            end)
            return clone.Event
        end,
 
        Button3Down = function()
            local clone = bindable:Clone()
            UIS.InputBegan:Connect(function(inputType, gameProcessed)
                if not(gameProcessed) and inputType.UserInputType == Enum.UserInputType.MouseButton3 and inputType.UserInputState == Enum.UserInputState.Begin then
                    clone:Fire(Vector2.new(inputType.Position.X, inputType.Position.Y))
                end
            end)
            return clone.Event
        end,
 
        Button3Up = function()
            local clone = bindable:Clone()
            UIS.InputEnded:Connect(function(inputType, gameProcessed)
                if not(gameProcessed) and inputType.UserInputType == Enum.UserInputType.MouseButton3 and inputType.UserInputState == Enum.UserInputState.End then
                    clone:Fire(Vector2.new(inputType.Position.X, inputType.Position.Y))
                end
            end)
            return clone.Event
        end,
 
        Move = function()
            local clone = bindable:Clone()
            UIS.InputChanged:Connect(function(inputType, gameProcessed)
                if inputType.UserInputType == Enum.UserInputType.MouseMovement then
                    clone:Fire(mouse.Delta)         
                end
            end)
            return clone.Event
        end,
 
        WheelForward = function()
            local clone = bindable:Clone()
            UIS.InputChanged:Connect(function(inputType, gameProcessed)
                if inputType.UserInputType == Enum.UserInputType.MouseWheel and inputType.Position.Z == 1 then
                    clone:Fire()
                end
            end)
            return clone.Event
        end,
 
        WheelBackward = function()
            local clone = bindable:Clone()
            UIS.InputChanged:Connect(function(inputType, gameProcessed)
                if inputType.UserInputType == Enum.UserInputType.MouseWheel and inputType.Position.Z == -1 then
                    clone:Fire()
                end
            end)
            return clone.Event
        end,
    }
    
    local isProperty = (pcall(function() return normalMouse[prop] end))
    local isMethod = isProperty and typeof(normalMouse[prop]) == "function" and true or false
    assert(isProperty or props[prop], ("%s not a property of Mouse"):format(prop))
    return (isProperty and not props[prop]) and (isMethod and (function(...) return normalMouse[prop](normalMouse, unpack({...}, 2)) end) or normalMouse[prop]) or props[prop](normalMouse)
end,
 
__newindex = function(mouse, prop, val)
    local props = {
        Icon = function() normalMouse.Icon = val end
    }
    assert(props[prop], ("%s not a property of Mouse or a read-only property"):format(prop))
    props[prop]()
end})
 
mouse.Move:Connect(function(delta)
    oldPos = delta
end)
 
function module:GetMouse()
    return mouse
end
 
return module