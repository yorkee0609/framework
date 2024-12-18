#if USE_UNI_LUA
using LuaAPI = UniLua.Lua;
using RealStatePtr = UniLua.ILuaState;
using LuaCSFunction = UniLua.CSharpFunctionDelegate;
#else
using LuaAPI = XLua.LuaDLL.Lua;
using RealStatePtr = System.IntPtr;
using LuaCSFunction = XLua.LuaDLL.lua_CSFunction;
#endif

using XLua;
using System.Collections.Generic;


namespace XLua.CSObjectWrap
{
    using Utils = XLua.Utils;
    
    public class UnityEngineAnimatorUpdateModeWrap
    {
		public static void __Register(RealStatePtr L)
        {
		    ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
		    Utils.BeginObjectRegister(typeof(UnityEngine.AnimatorUpdateMode), L, translator, 0, 0, 0, 0);
			Utils.EndObjectRegister(typeof(UnityEngine.AnimatorUpdateMode), L, translator, null, null, null, null, null);
			
			Utils.BeginClassRegister(typeof(UnityEngine.AnimatorUpdateMode), L, null, 4, 0, 0);

            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "Normal", UnityEngine.AnimatorUpdateMode.Normal);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "AnimatePhysics", UnityEngine.AnimatorUpdateMode.AnimatePhysics);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "UnscaledTime", UnityEngine.AnimatorUpdateMode.UnscaledTime);
            

			Utils.RegisterFunc(L, Utils.CLS_IDX, "__CastFrom", __CastFrom);
            
            Utils.EndClassRegister(typeof(UnityEngine.AnimatorUpdateMode), L, translator);
        }
		
		[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CastFrom(RealStatePtr L)
		{
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			LuaTypes lua_type = LuaAPI.lua_type(L, 1);
            if (lua_type == LuaTypes.LUA_TNUMBER)
            {
                translator.PushUnityEngineAnimatorUpdateMode(L, (UnityEngine.AnimatorUpdateMode)LuaAPI.xlua_tointeger(L, 1));
            }
			
            else if(lua_type == LuaTypes.LUA_TSTRING)
            {

			    if (LuaAPI.xlua_is_eq_str(L, 1, "Normal"))
                {
                    translator.PushUnityEngineAnimatorUpdateMode(L, UnityEngine.AnimatorUpdateMode.Normal);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "AnimatePhysics"))
                {
                    translator.PushUnityEngineAnimatorUpdateMode(L, UnityEngine.AnimatorUpdateMode.AnimatePhysics);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "UnscaledTime"))
                {
                    translator.PushUnityEngineAnimatorUpdateMode(L, UnityEngine.AnimatorUpdateMode.UnscaledTime);
                }
				else
                {
                    return LuaAPI.luaL_error(L, "invalid string for UnityEngine.AnimatorUpdateMode!");
                }

            }
			
            else
            {
                return LuaAPI.luaL_error(L, "invalid lua type for UnityEngine.AnimatorUpdateMode! Expect number or string, got + " + lua_type);
            }

            return 1;
		}
	}
    
}