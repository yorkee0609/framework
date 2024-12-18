using UnityEditor;
using UnityEngine;

public class AssetsImporter : AssetPostprocessor
{
    void OnPreprocessTexture()
    {
        // 获取当前导入的纹理资源
        TextureImporter importer = this.assetImporter as TextureImporter;

        // 检查是否为纹理资源
        if (importer != null)
        {
            bool bChange = false;
            // 获取纹理的路径
            string path = importer.assetPath;

            // 检查纹理是否在 UI 文件夹下
            if (path.Contains("/UI/"))
            {
                if(importer.textureType != TextureImporterType.Sprite)
                {
                    importer.textureType = TextureImporterType.Sprite;
                    // 勾选 Alpha Transparency
                    importer.alphaIsTransparency = true;
                    bChange = true;
                }
            }
            else
            {
                // 设置纹理类型为 Default
                TextureImporter textureImporter = assetImporter as TextureImporter;
                textureImporter.textureType = TextureImporterType.Default;
            }
            TextureImporterPlatformSettings androidSetting = importer.GetPlatformTextureSettings("Android");
            if(!androidSetting.overridden)
            {
                androidSetting.format = TextureImporterFormat.ASTC_6x6;
                androidSetting.overridden = true;
                bChange = true;
                importer.SetPlatformTextureSettings(androidSetting);
            }
            TextureImporterPlatformSettings iosSetting = importer.GetPlatformTextureSettings("iOS");
            if(!iosSetting.overridden)
            {
                iosSetting.format = TextureImporterFormat.ASTC_6x6;
                iosSetting.overridden = true;
                bChange = true;
                importer.SetPlatformTextureSettings(iosSetting);
            }

              if (bChange)
                importer.SaveAndReimport();
        }
    }

    void OnPreprocessModel()
    {
        // 获取当前导入的模型
        ModelImporter modelImporter = assetImporter as ModelImporter;
        bool bChange = false;
        // 检查是否为模型资源
        if (modelImporter != null && modelImporter.materialImportMode != ModelImporterMaterialImportMode.None)
        {
            modelImporter.materialImportMode = ModelImporterMaterialImportMode.None;
            bChange = true;
        }
        string path = modelImporter.assetPath.ToLower();
        if (path.Contains("/anim/"))
        {
            //去除mesh，只保留动画
            modelImporter.avatarSetup = ModelImporterAvatarSetup.CopyFromOther;
            modelImporter.importAnimation = true;
        }
        else  if (path.Contains("/mesh/"))
        {
            //去除mesh，只保留动画
            modelImporter.avatarSetup = ModelImporterAvatarSetup.CreateFromThisModel;
            modelImporter.importAnimation = false;
        }
    }
}