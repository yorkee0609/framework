using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace wc.framework
{
    public class BundleAssetObject
    {        
        public delegate void AssetLoadCallBack(BundleAssetObject ab) ;
        public BundleObject bundle;
        public string assetName;
        public UnityEngine.Object obj;
        public List<AssetLoadCallBack> assetLoadCallBacks = new List<AssetLoadCallBack>();
        public BundleAssetObject(BundleObject bundle, string assetName)
        {
            this.bundle = bundle;
            this.assetName = assetName;
        }

        public void CheckAssetLoadedCallBack(AssetLoadCallBack callBack = null)
        {
            if(callBack == null)
            {
                return;
            }
            if(obj)
            {
                callBack(this);
            }
            else
            {
                assetLoadCallBacks.Add(callBack);
            }
        }

        public IEnumerator Load() 
        {
            if(bundle == null || bundle.bundle == null)
            {
                Log.LogError("bundle is null , can not load asset " + assetName);
                yield break;
            }
            AssetBundleRequest request = bundle.bundle.LoadAssetAsync(assetName);
            yield return request.isDone;
            obj = request.asset;
            if(obj == null)
            {
                Log.LogError("load asset " + assetName + " is null");
            }
            RaiseAsesetsCallBack();
        }

        private void RaiseAsesetsCallBack()
        {
            if(assetLoadCallBacks.Count > 0)
            {
                foreach (var cb in assetLoadCallBacks)
                {
                    cb(this);
                }
            }
            assetLoadCallBacks.Clear();
        }

    }
}