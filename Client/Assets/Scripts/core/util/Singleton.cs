using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace wc.framework
{
    public abstract class Singleton<T> where T : Singleton<T>, new()
    {
        private static T _instance;
        public static T Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = new T();
                    _instance.Init();
                }
                return _instance;
            }
        }

        public virtual void Init(){}
    }
}

