local assetId = 15104766593
local InsertService = game:GetService("InsertService")
local success, model = pcall(InsertService.LoadAsset, InsertService, assetId)
if success and model then
   print("Model loaded successfully")
   model.Parent = game.workspace:FindFirstChild("mc")
else
   print("Model failed to load!")
end