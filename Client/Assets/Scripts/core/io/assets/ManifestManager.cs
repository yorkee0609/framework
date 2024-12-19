using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;
using wc.framework;

namespace wc.framework
{
    public class AssetBundleData{
        public string[] dependences;
        public Hash128 hash;
    }
    public class ManifestManager : Singleton<ManifestManager>
    {
        private Dictionary<string, AssetBundleData> mainfest = new Dictionary<string, AssetBundleData>();
        public bool IsInit
        {
            get;
            private set;
        }

        public IEnumerator InitManifest()
        {
            IsInit = false;
            mainfest.Clear();
#if UNITY_ANDROID
            string platform = "Android";
#elif UNITY_IOS            
            string platform = "iOS";
#elif UNITY_STANDALONE_WIN
            string platform = "Windows";
#elif Unity_WebGL
            IsInit = true;
            yield break;
#endif
            string manifestPath =  "Bundles/" + platform + "/" + platform;

            string path = FileHelper.Instance.GetExistPath(manifestPath);

            UnityWebRequest unityWebRequest = UnityWebRequestAssetBundle.GetAssetBundle(path);

            unityWebRequest.SendWebRequest();
            
            yield return unityWebRequest.isDone;

            if(unityWebRequest.result != UnityWebRequest.Result.Success)
            {
                Log.LogError("加载manifest失败");
                yield break;
            }

            AssetBundleRequest bundlRequest = (unityWebRequest.downloadHandler as DownloadHandlerAssetBundle).assetBundle.LoadAssetAsync<AssetBundleManifest>("AssetBundleManifest");

            yield return bundlRequest.isDone;

            if(bundlRequest.asset == null)
            {
                Log.LogError("加载manifest失败");
                yield break;
            }
            AssetBundleManifest assetBundleManifest = bundlRequest.asset as AssetBundleManifest;

            foreach(string assetBundleName in assetBundleManifest.GetAllAssetBundles())
            {
                AssetBundleData assetBundleData = new AssetBundleData();
                assetBundleData.dependences = assetBundleManifest.GetAllDependencies(assetBundleName);
                assetBundleData.hash = assetBundleManifest.GetAssetBundleHash(assetBundleName);
                mainfest.Add(assetBundleName, assetBundleData);
            }

            unityWebRequest.Dispose();
            IsInit = true;
        }

        public bool HasBundle(string name)
        {
            return mainfest.ContainsKey(name);
        }

        public Hash128 GetBundleHash(string name)
        {
            if(HasBundle(name))
            {
                return mainfest[name].hash;
            }
            return new Hash128();
        }

        public string[] GetBundleDependences(string name)
        {
            if(HasBundle(name))
            {
                return mainfest[name].dependences;
            }
            return null;
        }
    }
}    

