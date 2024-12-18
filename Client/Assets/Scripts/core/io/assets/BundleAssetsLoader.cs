using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using wc.framework;

public class BundleAssetsLoader : IAssetsLoader
{
    // Start is called before the first frame update
    public override void LoadAsset<T>(string bundleName, string assetName, Action<T> callBack)  
    {
        BundleManager.Instance.GetBundle(bundleName, (bundle) => {
            if(bundle == null || bundle.bundle == null)
            {
                Log.LogError($"bundleName:{bundleName} assetName:{assetName} load fail");
            }
            BundleManager.Instance.GetAsset(bundle, assetName, (asset)=>
            {
                callBack?.Invoke(asset as T);
            });
        });


    }

}
