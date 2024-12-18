------------------- AnimUtil

local M = {}

function M:setSpine(spine_obj, spine_name, spine_ab)
    if not IsNull(spine_obj) then
        local sg = spine_obj:GetComponent("SkeletonGraphic")
        ResourceUtil:GetSkAsync(spine_name, spine_ab,function(skeletonDataAsset)
            sg.skeletonDataAsset = skeletonDataAsset
            sg:Initialize(true)
        end)
        return sg
    end
end

function M:setSpineAnimation(spine_obj, track_index, animation_name, loop)
    if not IsNull(spine_obj) then
        if loop == nil then
            loop = true
        end
        local sg = spine_obj:GetComponent("SkeletonGraphic")
        if not IsNull(sg.AnimationState) then
            sg.AnimationState:SetAnimation(track_index or 0, animation_name or "animation", loop)
        else
            Logger.logWarning("setSpineAnimation AnimationState is null")
        end
        return sg
    end
end

return M
