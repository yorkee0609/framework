local debug_path = nil
if CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.WindowsEditor then
    debug_path = CS.UnityEngine.Application.streamingAssetsPath .. "/../../luaDebugger/emmy/windows/x64/?.dll"
elseif CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.OSXEditor then
    debug_path = CS.UnityEngine.Application.streamingAssetsPath .. "/../../luaDebugger/emmy/mac/?.dylib"
end
if debug_path then
    local function debugFunc()
        package.cpath = package.cpath .. ';' .. debug_path
        local dbg = require('emmy_core')
        dbg.tcpConnect('127.0.0.1', 9966)
    end
    local ok ,e = pcall(debugFunc)
    print(e)
    local breakSocketHandle,debugXpCall = require("LuaDebugjit")("localhost",7003)
end

function __G__TRACKBACK__(msg)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    CS.UnityEngine.Debug.LogError("Unhandled Exception: LuaScriptException: " .. tostring(msg) .. ".lua\n".. debug.traceback())
    print("----------------------------------------")

    

    if GameUtil then
        local traceback_msg = debug.traceback("", 2)
        GameUtil:sendLuaError(msg, traceback_msg)
    end
end

local function main()
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    require("Start.GameMain").start()
end

-- 类似C#的
-- try catch 异常捕获
xpcall(main, __G__TRACKBACK__)

 --local server = require("ServerMain")
