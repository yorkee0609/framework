using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using wc.framework;

namespace wc.framework
{
    public class AssetsManager : MonoSingleton<AssetsManager>
    {
        public bool UseBundle = true;
        private IAssetsLoader assetLoader;

        public Transform poolRoot
        {
            get;
            private set;
        }
        protected override void Init()
        {
            if(UseBundle)
            {
                assetLoader = new BundleAssetsLoader();
            }
            else
            {
                assetLoader = new ResourceAssetsLoader();
            }

            poolRoot = new GameObject("pool").transform;
            poolRoot.SetParent(transform);
            poolRoot.gameObject.SetActive(false);
        }

        Dictionary<string,Dictionary<string,AssetPool>> ObjPool = new Dictionary<string, Dictionary<string, AssetPool>>();
        public void LoadAsset<T>(string bundleName, string assetsName, Action<T> callBack) where T : UnityEngine.Object
        {
            if(typeof(T) == typeof(UnityEngine.GameObject))
            {
                GameObject obj = GetAssetPool(bundleName,assetsName);
                if(obj != null)
                {
                    callBack?.Invoke(obj as T);
                    return;
                }
            }
            assetLoader.LoadAsset<T>(bundleName,assetsName,callBack);
        }


        private GameObject GetAssetPool(string bundleName, string assetsName) 
        {
            if(!ObjPool.ContainsKey(bundleName))
                return null;
            if(!ObjPool[bundleName].ContainsKey(assetsName))
                return null;
            return ObjPool[bundleName][assetsName].Get();
        }

        private GameObject AddAssetPool(string bundleName, string assetsName, GameObject obj)
        {
            if(!ObjPool.ContainsKey(bundleName))
                ObjPool.Add(bundleName,new Dictionary<string, AssetPool>());
            if(!ObjPool[bundleName].ContainsKey(assetsName))
                ObjPool[bundleName].Add(assetsName,new AssetPool(bundleName + "-" + assetsName,obj));
            return ObjPool[bundleName][assetsName].Get();
        }

        public void ReturnAsset(GameObject obj)
        {
            if(obj == null)
                return;
            if(obj.transform.parent != null)
                obj.transform.SetParent(null);  
            string[] path = obj.name.Split('-');
            if(path.Length < 2)
                return;
            if(!ObjPool.ContainsKey(path[0]))
                return;
            if(!ObjPool[path[0]].ContainsKey(path[1]))
                return;
            ObjPool[path[0]][path[1]].Return(obj);
        }

    }
}

