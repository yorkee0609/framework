using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

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
}