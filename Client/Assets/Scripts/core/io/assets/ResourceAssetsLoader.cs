using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ResourceAssetsLoader : IAssetsLoader
{
    const string ResourceRootPath = "UI";
    public override void LoadAsset<T>(string bundleName, string assetName, Action<T> asset)
    {
        string resPath = Path.Combine(ResourceRootPath,bundleName.Replace("_", "/")) ;
        if(!string.IsNullOrEmpty(assetName))
        {
            resPath = Path.Combine(resPath, assetName);
        }
        UnityEngine.ResourceRequest request = Resources.LoadAsync<T>(resPath);
        request.completed += (op) =>{
            asset?.Invoke(request.asset as T);
        };
    }

    public override bool UnloadAsset(string bundleName, UnityEngine.Object asset)
    {
        if(asset != null)
            Resources.UnloadAsset(asset);
        return true;
    }

    public override void LoadScene(string sceneName,Action<float> callBack)
    {
        AsyncOperation async = SceneManager.LoadSceneAsync(sceneName);
        async.completed += (op) =>{
            callBack?.Invoke(async.progress);
        };
    }



}
