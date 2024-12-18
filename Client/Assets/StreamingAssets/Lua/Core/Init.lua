Mathf		= require("Core.UnityEngine.Mathf")
Vector3 	= require("Core.UnityEngine.Vector3")
Vector2		= require("Core.UnityEngine.Vector2")
Vector4		= require("Core.UnityEngine.Vector4")
Quaternion	= require("Core.UnityEngine.Quaternion")
Color		= require("Core.UnityEngine.Color")
ColorHexHelper		= require("Core.UnityEngine.ColorHexHelper")
Ray			= require("Core.UnityEngine.Ray")
Bounds		= require("Core.UnityEngine.Bounds")
RaycastHit	= require("Core.UnityEngine.RaycastHit")
Touch		= require("Core.UnityEngine.Touch")
LayerMask	= require("Core.UnityEngine.LayerMask")
Plane		= require("Core.UnityEngine.Plane")
Time		= require("Core.UnityEngine.Time")
require("Core.UnityEngine.Object")

require("Core.Commom.Functions")
require("Core.Commom.IoUtil")
require("Core.Commom.StringUtil")
require("Core.Commom.TableUtil")
List = require("Core.Commom.List")
ListMap = require("Core.Commom.ListMap")
Utf8 = require("Core.Commom.Utf8")
TimeUtil = require("Core.Commom.TimeUtil")

if VersionConfig.IS_SERVER == false then
	LuaCSharpArr = require("Core.Commom.LuaCSharpArr")
end



Logger = require("Core.Commom.Logger")
Json = require("Core.Commom.Json")
MemLeakCheckTools = require("Core.Commom.MemLeakCheckTools")
EventDispatcher = require("Core.Commom.EventDispatcher")
--表池类
TablePoolUtil = require("Core.Commom.TablePoolUtil")
TablePoolUtil:init();



GlobalTools = require("Core.Tool.GlobalTools")

WRandom = require("Core.Tool.WRandom")

VectorHelper = require("Core.Tool.VectorHelper")
FixVector3 = require("Core.Tool.FixVector3")
FixQuaternion = require("Core.Tool.FixQuaternion")
TimeTools = require("Core.Tool.TimeTools")
TimeTools:init()


function LuaReload( moduleName )
    package.loaded[moduleName] = nil
    return require(moduleName)
end

function CustomRequire( moduleName )
	if VersionConfig.LUA_RELOAD_DEBUG then
		return LuaReload(moduleName)
	else
		return require(moduleName)
	end
end