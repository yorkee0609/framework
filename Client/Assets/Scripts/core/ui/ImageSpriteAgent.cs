using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
namespace wc.framework
{
    [RequireComponent(typeof(Image))]
    public class ImageSpriteAgent : MonoBehaviour 
    {
        public Image image;

        private Texture2D texture;
        private string bundleName;
        public void Awake()
        {
            if(image == null)
            {
                image = GetComponent<Image>();                
            }
        }



        public void SetSprite(string spriteName, string bundleName)
        {
            if(this.bundleName == bundleName)
            {
                return;
            }
            var preBundleName = this.bundleName;
            this.bundleName = bundleName;
            AssetsManager.Instance.LoadAsset<Texture2D>(bundleName,spriteName, (texture)=>
            {                
                if(this.texture != null)
                {
                    AssetsManager.Instance.UnloadAsset(preBundleName,this.texture);
                    image.sprite = null;
                                Resources.UnloadUnusedAssets();
            System.GC.Collect();
                }
                this.texture = texture;
                image.sprite = Sprite.Create(texture, new Rect(0,0,texture.width,texture.height), new Vector2(0.5f,0.5f));                
            });
        }


        public void OnDestroy()
        {
            image.sprite = null;
            if(texture != null)
            {
                AssetsManager.Instance.UnloadAsset(bundleName,texture);
            }
        }
    }
}