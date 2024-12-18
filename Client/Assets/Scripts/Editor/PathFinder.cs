using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using System.Linq;
using System;

namespace wc.framework
{
    public class PathFinder 
    {
        [MenuItem("WC/Path/Persistent Dir")]
		static void OpenPersistentDir()
		{
			EditorUtility.RevealInFinder(Application.persistentDataPath);
		}

        [MenuItem("WC/Path/Streaming Dir")]
		static void OpenStreamingAssetsDir()
		{
			EditorUtility.RevealInFinder(Application.streamingAssetsPath);
		}

        [MenuItem("WC/Path/Resource Dir")]
		static void OpenResourceDir()
		{
			EditorUtility.RevealInFinder(Application.dataPath);
		}

        [MenuItem("WC/Path/Temp Dir")]
		static void OpenTempDir()
		{
			EditorUtility.RevealInFinder(Application.temporaryCachePath);
		}

        [MenuItem("WC/Path/Delete Persistent Dir")]
		static void DeletePersistentDir()
		{
            Directory.Delete(Application.persistentDataPath, true);
		}

        [MenuItem("WC/Path/List Streaming Files")]
		static void ListStreamingFiles()
		{
            // 使用 DirectoryInfo 来获取目录信息
            DirectoryInfo directoryInfo = new DirectoryInfo(Application.streamingAssetsPath);

            // 使用 GetFiles 方法并指定搜索选项来排除特定后缀名的文件
            FileInfo[] files = directoryInfo.GetFiles("*.*", SearchOption.AllDirectories)
               .Where(file =>!file.Extension.Equals(".meta", StringComparison.OrdinalIgnoreCase) &&
                              !file.Extension.Equals(".manifest", StringComparison.OrdinalIgnoreCase) &&
                               !file.Name.Equals("FileList.txt", StringComparison.OrdinalIgnoreCase))
               .ToArray();

            string savePath = Path.Combine(Application.streamingAssetsPath, "FileList.txt");
            using (StreamWriter writer = new StreamWriter(savePath))
            {
                foreach (FileInfo file in files)
                {
                    string relativePath = file.FullName.Substring(Application.streamingAssetsPath.Length + 1);
                    writer.WriteLine(relativePath);
                }
            }

            Debug.Log("Streaming files paths saved to: " + savePath);
            AssetDatabase.Refresh();
		}
    }
}

