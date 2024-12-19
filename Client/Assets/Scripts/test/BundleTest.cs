using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;
using wc.framework;
public class BundleTest : MonoBehaviour
{
    public Image image;
    public Canvas canvas;

    BundleObject ShaderBundle;
    // Start is called before the first frame update
    IEnumerator Start()
    {
        yield return ManifestManager.Instance.InitManifest();
        yield return null;

        ShaderBundle = BundleManager.Instance.GetBundle("shaders",null);
        yield return ShaderBundle.Loaded;
    }

    void OnGUI()
    {
        if (GUI.Button(new Rect(100,100,100,50),"Load texture"))
        {
            AssetsManager.Instance.LoadAsset<Texture2D>("texture_ui_loading_a_dl_bg2","a_dl_bg2",(asset)=>{
                image.sprite = Sprite.Create(asset,new Rect(0,0,asset.width,asset.height),new Vector2(0.5f,0.5f));
                image.gameObject.SetActive(true);
                image.SetNativeSize();
            });
        }

        if (GUI.Button(new Rect(100,200,100,50),"unload texture"))
        {
            AssetsManager.Instance.UnloadAsset("texture_ui_loading_a_dl_bg2",image.sprite);
            image.sprite = null;
            image.gameObject.SetActive(false);
            Resources.UnloadUnusedAssets();
            System.GC.Collect();
        }

        if (GUI.Button(new Rect(100,300,100,50),"load loading"))
        {
            AssetsManager.Instance.LoadAsset<GameObject>("ui_loading_loading","loading",(obj)=>{
                obj.transform.SetParent(canvas.transform,false);
                obj.transform.SetAsFirstSibling();
                obj.SetActive(true);
            });               
        }

        if (GUI.Button(new Rect(100,400,100,50),"unload loading"))
        {
            GameObject loading = canvas.transform.GetChild(0).gameObject;        
            AssetsManager.Instance.UnloadAsset("ui_loading_loading",loading);                        
            Resources.UnloadUnusedAssets();
            System.GC.Collect();
        }

        if (GUI.Button(new Rect(100,500,100,50),"replace loading img"))
        {
            GameObject loading = canvas.transform.GetChild(0).gameObject;      
            ImageSpriteAgent img = loading.transform.Find("Image").GetComponent<ImageSpriteAgent>();  
            img.SetSprite("a_dl_bg","texture_ui_loading_a_dl_bg");                

        }


       if (GUI.Button(new Rect(100,600,100,50),"load scene"))
        {
            AssetsManager.Instance.LoadScene("scene_scene1", (progress) =>
            {
                Debug.Log(progress);
                if(progress == 1)
                {
                    Resources.UnloadUnusedAssets();
                    System.GC.Collect();
                }
            });
        }

        if (GUI.Button(new Rect(100,700,100,50),"load scene empty"))
        {
            AssetsManager.Instance.LoadScene("scene_empty", (progress) =>
            {
                Debug.Log(progress);
                if(progress == 1)
                {
                    Resources.UnloadUnusedAssets();
                    System.GC.Collect();
                }
            });               
        }

    }

}
