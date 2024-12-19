using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class IAssetsLoader 
{
    public abstract void LoadAsset<T>(string bundleName, string assetName ,Action<T> asset) where T : UnityEngine.Object;

    public abstract bool UnloadAsset(string bundleName, UnityEngine.Object asset);

}
