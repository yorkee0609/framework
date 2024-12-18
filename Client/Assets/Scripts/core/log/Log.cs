using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace wc.framework
{
    public class Log
    {
        public static void LogInfo(string msg)
        {
            Debug.Log(msg);
        }

        public static void LogError(string msg)
        {
            Debug.LogError(msg);
        }
        public static void LogWarning(string msg)
        {
            Debug.LogWarning(msg);
        }

    }
}

