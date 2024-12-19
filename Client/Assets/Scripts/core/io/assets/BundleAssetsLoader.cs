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
                Log.LogError($"bundleName:{bundleName} assetName:{assetName} load bundle fail");
                callBack?.Invoke(null);
                return;
            }
            BundleManager.Instance.GetAsset(bundle, assetName, (asset)=>
            {
                if(asset == null || asset.obj == null)
                {
                    Log.LogError($"bundleName:{bundleName} assetName:{assetName} load asset fail");
                }
                callBack?.Invoke(asset.obj as T);
            });
        });


    }

    public override bool UnloadAsset(string bundleName, UnityEngine.Object asset)
    {
        return BundleManager.Instance.UnloadBundle(bundleName);
    }
}
