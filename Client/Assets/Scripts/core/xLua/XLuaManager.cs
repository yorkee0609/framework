using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using wc.framework;
using XLua;

namespace wc.framework
{
    [LuaCallCSharp]
    public class XLuaManager: MonoSingleton<XLuaManager>
    {
        public const string luaDir = "Lua";
        private const string mainScriptName = "Main";
        private XLua.LuaEnv luaEnv;
        private const int luaGCFrameStep = 7200;
        private XLuaUpdater luaUpdater;

        public bool useXxTea = false;

        public bool HasGameStart
        {
            get;
            private set;
        }

        protected override  void Init()
        {
            base.Init();
            InitLuaEnv();
        }

        private void InitLuaEnv()
        {
            luaEnv = new XLua.LuaEnv();
            LuaArrAccessAPI.RegisterPinFunc(luaEnv.L);

            HasGameStart = false;
            if(luaEnv != null)
            {
                luaEnv.AddBuildin("rapidjson", XLua.LuaDLL.Lua.LoadRapidJson);
                luaEnv.AddLoader(CustomLoader);
            }
        }

        private byte[] CustomLoader(ref string fileName)
        {
            if ("emmy_core".EndsWith(fileName))
                return null;
            fileName = fileName.Replace('.', '/');
            byte[] content = FileHelper.Instance.ReadAllByte(luaDir + "/" + fileName + ".lua",useXxTea);
            return content;
        }

        void LoadScript(string scriptName)
        {
            SafeDoString(string.Format("require('{0}')", scriptName));
        }

        public void SafeDoString(string scriptContent)
        {
            if (luaEnv != null)
            {
                try
                {
                    luaEnv.DoString(scriptContent);
                }
                catch (System.Exception ex)
                {
                    string msg = string.Format("xLua exception : {0}\n {1}", ex.Message, ex.StackTrace);
                    Log.LogError(msg);
                }
            }
        }

        public void OnInit()
        {
            if (luaEnv != null)
            {
                LoadScript(mainScriptName);
                
                if (luaUpdater == null)
                {
                    luaUpdater = new XLuaUpdater();
                    
                }
                luaUpdater.Init(luaEnv);
                HasGameStart = true;
            }
        }

        private void Update()
        {
            if (luaEnv != null)
            {
                luaEnv.Tick();
                if (Time.frameCount % luaGCFrameStep == 0)
                {
                    luaEnv.FullGc();
                }
            }
        }

        public void LuaFullGc()
        {
            if (luaEnv != null)
            {
                luaEnv.FullGc();
            }
        }

        private void OnApplicationQuit()
        {
            if (luaEnv != null && HasGameStart)
            {
                SafeDoString("GameMain.onApplicationQuit()");
            }
        }

        private void OnApplicationFocus(bool focus)
        {
            if (luaEnv != null && HasGameStart)
            {
                if (focus)
                {
                    SafeDoString("GameMain.onApplicationFocus(true)");
                }
                else
                {
                    SafeDoString("GameMain.onApplicationFocus(false)");
                }
            }
        }
        public override void Dispose()
        {
            if (luaUpdater != null)
            {
                luaUpdater.OnDispose();
            }
            if (luaEnv != null)
            {
                try
                {
                    luaEnv.Dispose();
                    luaEnv = null;
                }
                catch (System.Exception ex)
                {
                    string msg = string.Format("xLua exception : {0}\n {1}", ex.Message, ex.StackTrace);
                    Log.LogError(msg);
                }
            }
        }
    }
}
