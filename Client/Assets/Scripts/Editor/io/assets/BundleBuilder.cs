using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using System.Linq.Expressions;

public class BundleBuilder
{
     public static string Res_Path = "Assets/Resources/Res/";
    public static string bundle_Path = Application.streamingAssetsPath + "/Bundles";
 
    [MenuItem("WC/Bundle/Set Bundle Name")]
    public static void SetBundleName()
    {
        EditorUtility.ClearProgressBar();
        string[] guids = AssetDatabase.FindAssets("t:Object", new string[] { "Assets/Resources/Res" });
        int index = 0;
        foreach (string guid in guids)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            if(!File.Exists(path))
            {
                continue;
            }
            Object obj = AssetDatabase.LoadAssetAtPath<Object>(path);
            if (obj != null)
            {
                string name = path.Replace(Path.GetExtension(path),"").Replace(Res_Path, "").ToLower();
                string[] dirs = name.Split("/");
                if(dirs.Length < 2)
                {
                    Debug.LogError("路径错误：" + path);
                    continue;
                }
                string flag = dirs[0];
                string bundleName = name.Replace("/","_");
                string variant = "bundle";
                switch (flag.ToLower())
                {
                    case "ui":
                    break;
                    case "role":
                    break;
                    case "fx":
                    break;
                    case "atlas":
                    break;
                    case "scene":
                    break;
                    case "texture":
                    break;
                    case "font":
                        bundleName = "fonts";
                    break;
                    case "shader":
                        bundleName = "shaders";
                    break;
                }


                AssetImporter assetImporter = AssetImporter.GetAtPath(path);
                assetImporter.assetBundleName = bundleName;
                assetImporter.assetBundleVariant = variant;
                EditorUtility.DisplayProgressBar(index.ToString() + "/" + guids.Length,
                                                                    obj.name, index++ * 1.0f / guids.Length);
            }
        }
        AssetDatabase.Refresh();
        EditorUtility.ClearProgressBar();
        Debug.Log("bundle设置完成");
    }

    [MenuItem("WC/Bundle/Clear Bundle Name")]
    public static void ClearAllBundleName()
    {
        bool result = EditorUtility.DisplayDialog("提示", "是否清除所有Bundle名字?", "确定", "取消");
        if(result)
        {
            EditorUtility.ClearProgressBar();
            string[] abNames = AssetDatabase.GetAllAssetBundleNames();
            int len = abNames.Length;
            for (int i = 0; i < len; i++)
            {
                EditorUtility.DisplayProgressBar("清除AB名字", "清除" + abNames[i] + "中..." + i + "/" + len,
                    (float)i / (float)len);
                AssetDatabase.RemoveAssetBundleName(abNames[i], true);
            }

            EditorUtility.ClearProgressBar();
        }

    }

    [MenuItem("WC/Bundle/Android/Full Build")]
    public static void BuildFullAndroid()
    {
        ClearAllBundleName();
        SetBundleName();
        BuildBundles(BuildTarget.Android);
    }

    [MenuItem("WC/Bundle/Android/Set And Build")]
    public static void BuildSetAndAndroid()
    {
        SetBundleName();
        BuildBundles(BuildTarget.Android);
    }
    [MenuItem("WC/Bundle/Android/Only Build")]
    public static void BuildOnlyAndroid()
    {
        BuildBundles(BuildTarget.Android);
    }

    public static void BuildBundles(BuildTarget target)
    {
        if(
#if UNITY_STANDALONE_WIN
            target != BuildTarget.StandaloneWindows64
#endif
#if UNITY_ANDROID
            target != BuildTarget.Android
#endif
#if UNITY_IOS
            target != BuildTarget.iOS
#endif
            )
        {
            EditorUtility.DisplayDialog("错误", "当前平台不是" + target.ToString(), "确定");
        }
        if (!Directory.Exists(bundle_Path))
        {
            Directory.CreateDirectory(bundle_Path);
        }
        string bundle_target_path = bundle_Path + "/" + target.ToString();
        if (!Directory.Exists(bundle_target_path))
        {
            Directory.CreateDirectory(bundle_target_path);
        }
        if(BuildPipeline.BuildAssetBundles(bundle_target_path, BuildAssetBundleOptions.ChunkBasedCompression | BuildAssetBundleOptions.DeterministicAssetBundle, target))
        {
            Debug.Log("打包完成");
        }
        else
        {
            Debug.Log("打包失败");
        }
    }
}