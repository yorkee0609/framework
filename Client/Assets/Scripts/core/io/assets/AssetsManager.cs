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
                }
                else{
                    assetLoader.LoadAsset<T>(bundleName,assetsName,(obj)=>{
                        if(obj == null)
                        {
                            callBack?.Invoke(null);
                            return;
                        }
                        GameObject newObj = AddAssetPool(bundleName,assetsName,obj as GameObject);
                        callBack?.Invoke(newObj as T);
                    });
                }                
                return;
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
            if(path.Length < 2 || !ObjPool.ContainsKey(path[0]) || !ObjPool[path[0]].ContainsKey(path[1]))
            {
                Destroy(obj);
                return;
            }
            ObjPool[path[0]][path[1]].Return(obj);
        }

        public void UnloadAsset(string bundleName,UnityEngine.Object obj) 
        {

            bool unload = assetLoader.UnloadAsset(bundleName,obj);
            if(unload)
            {
                if(obj is GameObject)
                {
                    ReturnAsset(obj as GameObject);
                    if(ObjPool.ContainsKey(bundleName))
                    {
                        foreach (var item in ObjPool[bundleName])
                        {
                            item.Value.Clear();
                        }
                        ObjPool[bundleName].Clear();
                    }
                    ObjPool.Remove(bundleName);
                }
            }
        }



        public void GetGameObject(string bundleName, string assetsName, Action<GameObject> callBack)
        {
            LoadAsset<GameObject>(bundleName,assetsName,callBack);
        }

        public void GetTexture(string bundleName, string assetsName, Action<Texture> callBack)
        {
            LoadAsset<Texture>(bundleName,assetsName,callBack);
        }

        public void GetTexture2D(string bundleName, string assetsName, Action<Texture2D> callBack)
        {
            LoadAsset<Texture2D>(bundleName,assetsName,callBack);
        }

        public void LoadScene(string sceneName,Action<float> callBack)
        {
            assetLoader.LoadScene(sceneName,callBack);
        }


    }
}

