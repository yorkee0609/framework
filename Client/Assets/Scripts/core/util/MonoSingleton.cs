using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace wc.framework
{
    public abstract class MonoSingleton<T> : MonoBehaviour where T : MonoSingleton<T>
    {
        private static T _instance;
        public static T Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = FindObjectOfType<T>();
                    if (_instance == null)
                    {
                        GameObject obj = new GameObject();
                        obj.name = typeof(T).Name;
                        _instance = obj.AddComponent<T>();
                        GameObject parent = GameObject.Find("core");
                        if(parent == null)
                        {
                            parent = new GameObject();
                            parent.name = "core";
                            DontDestroyOnLoad(parent);
                        }
                        if(parent!= null)
                        {
                            obj.transform.parent = parent.transform;
                        }
                    }
                }
                return _instance;
            }
        }

        public void Startup()
        {

        }
        protected virtual void Awake()
        {
            if (_instance == null)
            {
                _instance = this as T;
            }
            DontDestroyOnLoad(this.gameObject);
            Init();
        }

        protected virtual void Init()
        {

        }
        public void DestroySelf()
        {
            Dispose();
            MonoSingleton<T>._instance = null;
            UnityEngine.Object.Destroy(gameObject);
        }

        public virtual void Dispose()
        {

        }
    }
}