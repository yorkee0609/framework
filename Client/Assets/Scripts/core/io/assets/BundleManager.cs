using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using wc.framework;

namespace wc.framework
{
    public class BundleManager : MonoSingleton<BundleManager>
    {
        Dictionary<string, BundleObject> bundleCach = new Dictionary<string, BundleObject>();
        List<BundleObject> loadedBundles = new List<BundleObject>();
        List<BundleObject> loadingBundles = new List<BundleObject>();
        Queue<BundleObject> waitloadingBundles = new Queue<BundleObject>();

        const int maxLoadingBundleCount = 10;
        
        List<BundleAssetObject> loadingBundleAssets = new List<BundleAssetObject>();
        Queue<BundleAssetObject> waitloadingBundleAssets = new Queue<BundleAssetObject>();
        const int maxLoadingAssetsCount = 10;

        public BundleObject GetBundle(string bundleName,Action<BundleObject> callback)
        {
            bundleName = GetBundleNameWithExtension(bundleName);
            if(!MainfestManager.Instance.HasBundle(bundleName))
            {
                Log.LogError($"bundle:{bundleName} not exist");
                callback?.Invoke(null);
                return null;
            }
            BundleObject bundleObj = null;
            if(bundleCach.ContainsKey(bundleName))
            {
                bundleObj = bundleCach[bundleName];
                bundleObj.AddRef();
                bundleObj.CheckBundleLoadedCallBack((bundle)=>
                {
                    callback?.Invoke(bundle);
                });
            }
            else
            {
                bundleObj = new BundleObject(bundleName);
                bundleCach[bundleName] = bundleObj;
                waitloadingBundles.Enqueue(bundleObj);
                bundleObj.CheckBundleLoadedCallBack((bundle)=>
                {
                    OnBundleLoaded(bundle);
                    callback?.Invoke(bundle);
                });
            }
            return bundleObj;
        }
        private string GetBundleNameWithExtension(string bundleName)
        {
            //多语言会有不同的变体后缀需要额外处理
            //例如：zh-CN  zh-TW
            if(bundleName.EndsWith(".bundle"))
            {
                return bundleName;
            }
            else{
                return string.Format("{0}.bundle",  bundleName);
            }
        }

        private void OnBundleLoaded(BundleObject bundle)
        {
            if(loadingBundles.Contains(bundle))
                loadingBundles.Remove(bundle);
            if(bundle.Loaded)
                loadedBundles.Add(bundle);
            else if(bundleCach.ContainsKey(bundle.bundleName))
                bundleCach.Remove(bundle.bundleName);
        }

        private void DoBundleLoad()
        {
            while(loadingBundles.Count < maxLoadingBundleCount && waitloadingBundles.Count > 0)
            {
                var bundle = waitloadingBundles.Dequeue();
                if(bundle.refCount == 0)
                    continue;
                loadingBundles.Add(bundle);
                StartCoroutine(bundle.Load());
            }
        }

        public BundleAssetObject GetAsset(BundleObject bundle, string assetName, Action<BundleAssetObject> callback)
        {
            BundleAssetObject assetObject = bundle.GetAsset(assetName);
            if(assetObject.obj != null)
            {
                callback?.Invoke(assetObject);
            }
            else
            {
                waitloadingBundleAssets.Enqueue(assetObject);
                assetObject.CheckAssetLoadedCallBack((asset)=>
                {
                    OnAssetLoaded(asset);
                    callback?.Invoke(asset);
                });
            }
            return assetObject;
        }

        private void OnAssetLoaded(BundleAssetObject bundleAsset)
        {
            if(loadingBundleAssets.Contains(bundleAsset))
                loadingBundleAssets.Remove(bundleAsset);
        }

        private void DoAssetLoad()
        {
            while(loadingBundleAssets.Count < maxLoadingAssetsCount && waitloadingBundleAssets.Count > 0)
            {
                var bundleAsset = waitloadingBundleAssets.Dequeue();
                loadingBundleAssets.Add(bundleAsset);
                StartCoroutine(bundleAsset.Load());
            }
        }
        public void Update()
        {
            DoBundleLoad();
            DoAssetLoad();
        }

        public bool UnloadBundle(string bundleName)
        {
            bundleName = GetBundleNameWithExtension(bundleName);
            if(!bundleCach.ContainsKey(bundleName))
            {
                Log.LogWarning($"bundle:{bundleName} not exist");
                return true;
            }
            var bundle = bundleCach[bundleName];
            bundle.RemoveRef();
            if(bundle.refCount == 0)
            {
                if(loadedBundles.Contains(bundle))
                    loadedBundles.Remove(bundle);         
                bundleCach.Remove(bundleName);  
                return true;
            }  
            return false;
        }
    }
}

