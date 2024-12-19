M = {}
local _AssetManager = CS.wc.framework.AssetManager.Instance
local _ManifestManager = CS.wc.framework.ManifestManager.Instance

function M:GetGameObject(bundleName,assetName,callBack)
    _AssetManager:LoadAssetAsync(bundleName,assetName,callBack)    
end