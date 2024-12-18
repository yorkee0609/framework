------------- GameVersionConfig

local M = {
	-- 游戏版本
	CLIENT_VERSION = "1.0.001",
	-- 游戏资源版本
	RESOURCES_VERION = "1.0.001",

	LUA_ROOT_PATH = "C:\\game24\\TestForAI\\Assets\\StreamingAssets\\";

	LOG_PATH = "Log\\",

	LUA_RELOAD_DEBUG = true,
	
	IS_SERVER = false,

	Debug = true,
}

M.LOG_PATH = M.LUA_ROOT_PATH.. "Log\\"
return M

