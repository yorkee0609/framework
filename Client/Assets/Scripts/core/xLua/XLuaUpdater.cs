using XLua;
using System;
using UnityEngine;  
using wc.framework;
namespace wc.framework
{
    public class XLuaUpdater
    {
        Action<float,float> luaUpdate = null;
        Action<float,float> luaLateUpdate = null;
        Action<float> luaFixedUpdate = null;
        Action<string,string> luaException = null;

        public void Init(LuaEnv luaEnv)
        {
            Restart(luaEnv);
        }

        public void Restart(LuaEnv luaEnv)
        {
            LuaTable gameMain = luaEnv.Global.Get<LuaTable>("GameMain");
            if (gameMain != null)
            {
                luaUpdate = gameMain.Get<Action<float, float>>("update");
                luaLateUpdate = gameMain.Get<Action<float, float>>("lateUpdate");
                luaFixedUpdate = gameMain.Get<Action<float>>("fixedUpdate");
                luaException = gameMain.Get<Action<string, string>>("luaExceptionError");
                gameMain.Dispose();
            }
        }

        public void Update()
        {
            if (luaUpdate != null)
            {
                try
                {
                    luaUpdate(Time.deltaTime, Time.unscaledDeltaTime);
                }
                catch (Exception ex)
                {
                    Log.LogError("Unhandled Exception: LuaScriptException: " + ex.Message + ".lua\n" + ex.StackTrace);
                    luaException?.Invoke(ex.Message, ex.StackTrace);
                }
            }
        }

        public void LateUpdate()
        {
            if (luaLateUpdate!= null)
            {
                try
                {
                    luaLateUpdate(Time.deltaTime, Time.unscaledDeltaTime);
                }
                catch (Exception ex)
                {
                    Log.LogError("Unhandled Exception: LuaScriptException: " + ex.Message + ".lua\n" + ex.StackTrace);
                    luaException?.Invoke(ex.Message, ex.StackTrace);
                }
            }
        }

        public void FixedUpdate()
        {
            if (luaFixedUpdate != null)
            {
                try
                {
                    luaFixedUpdate(Time.fixedDeltaTime);
                }
                catch (Exception ex)
                {
                    Log.LogError("Unhandled Exception: LuaScriptException: " + ex.Message + ".lua\n" + ex.StackTrace);
                    luaException?.Invoke(ex.Message, ex.StackTrace);
                }
            }
        }

        public void OnDispose()
        {
            luaUpdate = null;
            luaLateUpdate = null;
            luaFixedUpdate = null;
            luaException = null;
        }
    }
}