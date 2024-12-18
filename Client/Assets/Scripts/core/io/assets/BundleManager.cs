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
            BundleObject bundleObj = null;
            if(bundleCach.ContainsKey(bundleName))
            {
                bundleObj = bundleCach[bundleName];
                bundleObj.AddRef();
                callback?.Invoke(bundleObj);
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

        private void OnBundleLoaded(BundleObject bundle)
        {
            if(loadingBundles.Contains(bundle))
                loadingBundles.Remove(bundle);
            if(bundle.Loaded)
                loadedBundles.Add(bundle);
            else
                bundleCach.Remove(bundle.bundleName);
        }

        private void DoBundleLoad()
        {
            while(loadingBundles.Count < maxLoadingBundleCount && waitloadingBundles.Count > 0)
            {
                var bundle = waitloadingBundles.Dequeue();
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
    }
}

