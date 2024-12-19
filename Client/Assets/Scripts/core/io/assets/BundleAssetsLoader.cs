using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
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

    public override void LoadScene(string sceneName,Action<float> callBack)
    {
        BundleManager.Instance.GetBundle(sceneName, (bundle) => {
            if(bundle == null || bundle.bundle == null)
            {
                Log.LogError($"sceneName:{sceneName} load bundle fail");
                callBack?.Invoke(0);
                return;
            }
            callBack?.Invoke(0.5f);
            string[] scenePath = bundle.bundle.GetAllScenePaths();
            if(scenePath.Length < 1)
            {
                Log.LogError($"sceneName:{sceneName} load scene fail");
                callBack?.Invoke(0);
                return;
            }
            AsyncOperation async = SceneManager.LoadSceneAsync(scenePath[0],LoadSceneMode.Single);
            async.completed += (op) =>{
                if(async.isDone)
                {
                    BundleManager.Instance.UnloadBundle(sceneName);
                    callBack?.Invoke(1);
                }
                else
                    callBack?.Invoke(0.5f + async.progress * 0.5f);
            };
        });
    }



}
