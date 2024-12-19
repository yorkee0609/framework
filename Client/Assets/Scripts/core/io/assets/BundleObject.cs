using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UIElements;

namespace wc.framework
{

    public class BundleObject
    {
        public delegate void BundleLoadCallBack(BundleObject ab);
        public string bundleName;
        private string bundlePath;
        public AssetBundle bundle
        {
            get;
            private set;
        }
        private List<BundleObject> depends = new List<BundleObject>();
        public int refCount
        {
            get;
            private set;
        }
        public bool Loaded
        {
            get;
            private set;
        }
        private List<BundleLoadCallBack> bundleCallBacks = new List<BundleLoadCallBack>();

        private Dictionary<string, BundleAssetObject> assetDatas = new Dictionary<string, BundleAssetObject>();

        public BundleObject(string bundleName)
        {
            this.Loaded = false;
            this.bundleName = bundleName;
            this.bundlePath = FileHelper.Instance.GetExistPath(GetBundlePath(this.bundleName));
            refCount = 1;
        }



        private string GetBundlePath(string bundleName)
        {
#if UNITY_ANDROID
            const string platform = "Android";
#elif UNITY_IOS            
            const string platform = "iOS";
#elif UNITY_STANDALONE_WIN
            const string platform = "Windows";
#elif Unity_WebGL
#endif
            return string.Format("Bundles/{0}/{1}", platform, bundleName);
        }

        public void CheckBundleLoadedCallBack(BundleLoadCallBack callBack = null)
        {
            if(callBack == null)
            {
                return;
            }
            if(Loaded)
            {
                callBack(this);
            }
            else
            {
                bundleCallBacks.Add(callBack);
            }
        }


        public void AddRef()
        {
            refCount++;
        }

        public void RemoveRef()
        {
            refCount--;
            if(refCount <= 0 && Loaded)
            {
                Unload(false);
            }
        }
        

        public IEnumerator Load()
        {
            string[] dependNames = ManifestManager.Instance.GetBundleDependences(bundleName);
            int dependCount = dependNames.Length;
            for(int i = 0; i < dependNames.Length; i++)
            {
                string dependName = dependNames[i];
                BundleObject depend = BundleManager.Instance.GetBundle(dependName, (bundle)=>{
                    dependCount--;
                });          
                depends.Add(depend);
            }
            yield return dependCount == 0;


            UnityWebRequest request = UnityWebRequestAssetBundle.GetAssetBundle(bundlePath);
            request.SendWebRequest();
            yield return request.isDone;

            if(refCount <= 0)
            {
                request.Dispose();
                Unload();
                RaiseBundleCallBack();
                yield break;
            }
            if(request.result == UnityWebRequest.Result.Success)
            {
                this.bundle = DownloadHandlerAssetBundle.GetContent(request);
            }

            request.Dispose();
            Loaded = true;
            RaiseBundleCallBack();
        }

        private void RaiseBundleCallBack()
        {
            if(bundleCallBacks.Count > 0)
            {
                foreach (var cb in bundleCallBacks)
                {
                    cb(this);
                }
            }
            bundleCallBacks.Clear();
        }

        public BundleAssetObject GetAsset(string assetName)
        {
            if(assetDatas.ContainsKey(assetName))
            {
                return assetDatas[assetName];
            }
            BundleAssetObject asset = new BundleAssetObject(this, assetName);
            assetDatas.Add(assetName, asset);
            return asset;
        }



        public void Unload(bool bForce = false)
        {
            if(bundle == null)
                return;
            foreach (var depend in depends)
            {
                BundleManager.Instance.UnloadBundle(depend.bundleName);
            }
            depends.Clear();
            if(bundle != null)
            {
                bundle.Unload(bForce);
                bundle = null;
            }
            Loaded = false;
        }
    }
}