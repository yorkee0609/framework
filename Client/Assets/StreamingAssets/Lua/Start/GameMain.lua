GameMain = {}

-- 重加载白名单
local FileHelper = CS.wc.framework.FileHelper.Instance

local _updateFunctionTab = {}
GameMain.enter_main_flag = false
GameMain.restart_flag = false
GameMain.download_game_resources = false

local __BundlesDir = "Bundles"
local __GameLocalDataDir = FileHelper.readAndWritePath .. "/" .. __BundlesDir

function GameMain.setGameVersion(file_name, value)
    local filePath = __BundlesDir .. "/" .. file_name
    FileHelper:WriteText(filePath,tostring(value))
end

function GameMain.getGameVersion(file_name, default_value)
    local filePath = __BundlesDir.. "/".. file_name
    if FileHelper:FileExist(filePath, CS.wc.framework.FilePathType.readAndWrite) then
        local game_version = FileHelper:ReadText(filePath)
        return game_version
    end
    return default_value
end

function GameMain.start()
    GameMain.new_client = false
    GameMain.download_game_resources = false
    VersionConfig = require("Start.VersionConfig")
    if VersionConfig.IS_SERVER then
        local server = require("ServerMain")
        return;
    end
    U3DUtil = require("Util.U3DUtil")
    U3DUtil:init()
    
    --local client_verion = U3DUtil:PlayerPrefs_GetString("client_verion")
    local client_verion = GameMain.getGameVersion("client_verion", "")

    print("SAVE_CLIENT_VERSION : ", client_verion, "CLIENT_VERSION : ", VersionConfig.CLIENT_VERSION, "RESOURCES_VERION : ", VersionConfig.RESOURCES_VERION)
    
    if client_verion ~= tostring(VersionConfig.CLIENT_VERSION) then--覆盖更新,删除老版本下载的资源
        -- TODO : 删除热更目录下的资源
        print("删除热更目录下的资源")
        FileHelper:DeleteDir("Bundles")
        FileHelper:DeleteDir("LuaScripts")
        FileHelper:DeleteDir("mp4")
        FileHelper:DeleteDir("Audio")
        FileHelper:DeleteDir("tempZip")
        FileHelper:DeleteFile("file_names.txt")

        GameMain.setGameVersion("resources_verion",tostring(VersionConfig.RESOURCES_VERION))
        GameMain.setGameVersion("client_verion",tostring(VersionConfig.CLIENT_VERSION))

        if client_verion ~= nil and client_verion ~= "" then
            GameMain.new_client = true
        end
    end

    local resources_version = GameMain.getGameVersion("resources_verion", "")
	VersionConfig.RESOURCES_ORI_VERION = VersionConfig.RESOURCES_VERION --存储包内版本号，作静默下载用
    if resources_version ~= nil and resources_version ~= "" then
        VersionConfig.RESOURCES_VERION = resources_version
    end
    print("current resources_version : ", VersionConfig.RESOURCES_VERION)
    

    -- if CS.wc.framework.ResourcesHelper.useAssetBundle and CS.wt.framework.AssetLoaderHelper.Inst.isUseAsync and not CS.wt.framework.AssetLoaderHelper.Inst.isWebGL then
    --     webRequestTickHelper = require("Util.WebRequestTickHelper")
    --     webRequestTickHelper:init()
    -- end

    GameMain.init()

    Logger.log(FileHelper.readAndWritePath, "FileHelper.readAndWritePath-->")
    -- if VersionConfig.OPEN_SR_DEBUG then
    --     CS.LuaGameLaunch.Instance:OpenSRDebug()
    -- end
end

function GameMain.init()
    require("Start.Init")
    -- LODUtil = require("Util.LODUtil")
    -- _updateFunctionTab = {}
    -- if GameMain.new_client then
    --     GameMain.reStart()
    --     return
    -- end
    -- GameMain.initFont(function ()
    --     SDKUtil:getPlatform(function()
    --         local __SpriteAtlasHelper = CS.wc.framework.SpriteAtlasHelper
    --         __SpriteAtlasHelper.Register("language_zh_cn")
    --         __SpriteAtlasHelper.Register("common_ui")
    --         __SpriteAtlasHelper.Register("main_ui2")
    --         __SpriteAtlasHelper.LoadAlwaysAsync(function ()
    --             LikeOO.OOControlBase:openView("Login")
    --         end)

    --     end)
    -- end)

end

-- 初始化字体
function GameMain.initFont(callback)
    U3DUtil:Set_Font(function ()
        callback()
    end );
end

-- 初始化声音
function GameMain.initSound()
    audio:init()
end

-- 初始化游戏画质,1底画质 2高画质
function GameMain.initPictureQuality()
    local flag = U3DUtil:PlayerPrefs_GetInt("picture_quality", 2)
    GameMain.setPictureQuality(flag)
end

-- 设置画质品质高低
function GameMain.setPictureQuality(flag)
    --CS.zmhx.PhoneHelper.SetUnAutoPhoneLevel(flag);
end

function GameMain.reStart()
    if static_rootControl then
        static_rootControl:closeAllViewPop()
        static_rootControl:openView("Splash.RestartSplash")
    else
        LikeOO.OOControlBase:openView("Splash.RestartSplash")
    end
end

function GameMain.update(dt, unsdt)
	for k,v in pairs(_updateFunctionTab) do
        if v.available then
            v.func(dt, unsdt)
        end
	end
    for k,v in pairs(_updateFunctionTab) do
        if not v.available then
            _updateFunctionTab[k] = nil
        end
    end

    if SceneManager ~= nil then
        SceneManager:update(dt, unsdt)
    end
    if TimeTools ~= nil then
        TimeTools:update_dt_unity(dt)
    end
end

function GameMain.fixedUpdate(fdt)
    if SceneManager ~= nil then
        --Logger.log(" fdt -------- >>>> [ "..fdt.." ]");
        SceneManager:fixedUpdate(fdt);
    end
end

function GameMain.lateUpdate(dt, unsdt)
    if SceneManager ~= nil then
        SceneManager:lateUpdate(dt, unsdt);
    end
end

function GameMain.onDestroy()
    
end

function GameMain.addUpdate(key, updateFunction)
    if not _updateFunctionTab[key] then
        _updateFunctionTab[key] = {name = key, func = updateFunction, available = true}
    else
        _updateFunctionTab[key].available = true;
        _updateFunctionTab[key].func = updateFunction
    end
end

function GameMain.removeUpdate(key)
    if _updateFunctionTab[key] then
        _updateFunctionTab[key].available = false
    end
end

function GameMain.removeAllUpdate()
    _updateFunctionTab = {}
end

function GameMain.hasUpdate(key)
    return _updateFunctionTab[key] ~= nil
end

function GameMain.onApplicationQuit()
    if Logger then
        Logger.log("OnApplicationQuit")
    end
end

local enter_background_time = os.time()

function GameMain.onApplicationFocus(focus)
    if Logger then
        Logger.log("OnApplicationFocus : " .. tostring(focus))
    end
    if EventDispatcher then
        EventDispatcher:dipatchEvent("onApplication", focus);
    end
    if SceneManager ~= nil then
        if focus == true then
            SceneManager.delayFrame = 3;
            local diff_time = os.time() - enter_background_time
            if EventDispatcher then
                EventDispatcher:addjustTimer(diff_time)
                EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.ON_APPLICATION_WAKE_UP, {total_time = diff_time})
            end
        else
            enter_background_time = os.time()
        end
        SceneManager.start = focus;
    end
end

function GameMain.luaExceptionError(mssage, stack_trace)
    if GameUtil then
        GameUtil:sendLuaError(mssage, stack_trace)
    end
end

return GameMain