using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.Networking;

namespace wc.framework
{
    public enum FilePathType
    {
        Resources,
        streamingAsset,
        readAndWrite,
        online,
    }
    
    public class FileHelper:Singleton<FileHelper>
    {
        private const string xxteaKey = "@*xsj#s*@";
        public string readOnlyResPath
        {
            get;
            private set;
        }
        public string readOnlyStreamAssetPath
        {
            get;
            private set;
        }
        public string readAndWritePath
        {
            get;
            private set;
        }
        public string onlinePath    {
            get;
            private set;
        }

        private HashSet<string> fileSets = new HashSet<string>();

        public override void Init()
        {
            readOnlyResPath = Application.dataPath + "/";
            readOnlyStreamAssetPath = Application.streamingAssetsPath+ "/";
            readAndWritePath = Application.persistentDataPath+ "/";
            InitFileSets();
        }

        public void InitFileSets()
        {
            fileSets.Clear();
            UnityWebRequest request = UnityWebRequest.Get(Path.Combine(readOnlyStreamAssetPath, "FileList.txt"));
            request.SendWebRequest();
            while(!request.isDone){}
            if(request.result == UnityWebRequest.Result.Success)
            {
                MemoryStream ms = new MemoryStream(request.downloadHandler.data);
                StreamReader sr = new StreamReader(ms);
                while(sr.Peek() >= 0)
                {
                    string file = sr.ReadLine();
                    fileSets.Add(file);
                }
                sr.Close();
                ms.Close();
            }
        }

        public bool FileExist(string fileName,FilePathType filePathType)        
        {
#if !UNITY_EDITOR
#if UNITY_WEBGL
            return true;
#elif UNITY_ANDROID || UNITY_IOS
            switch (filePathType)
            {
                case FilePathType.Resources:
                    return true; //need a file list to check
                case FilePathType.streamingAsset:
                    return fileSets.Contains(fileName);
                case FilePathType.readAndWrite:
                    return File.Exists(Path.Combine(readAndWritePath, fileName));
                default:
                    return true;
            }
#endif
#else
            switch (filePathType)
            {
                case FilePathType.Resources:
                    return File.Exists(Path.Combine(readOnlyResPath, fileName));
                case FilePathType.streamingAsset:
                    return File.Exists(Path.Combine(readOnlyStreamAssetPath, fileName));//fileSets.Contains(fileName);
                case FilePathType.readAndWrite:
                    return File.Exists(Path.Combine(readAndWritePath, fileName));
                default:
                    return true;
            }
#endif
        }

        public string GetExistPath(string fileName)
        {
            string path = "";
#if UNITY_WEBGL  
            if (FileExits(fileName, FilePathType.Resources))
            {
                path = fileName;
            }
#else
            if (FileExist(fileName, FilePathType.readAndWrite))
            {
                path = Path.Combine(readAndWritePath, fileName);
            }
            else if (FileExist(fileName, FilePathType.streamingAsset))
            {
                path = Path.Combine(readOnlyStreamAssetPath, fileName);
            }
#endif
            return path;
        }

        public byte[] ReadAllByte(string fileName, bool useXxTea = false)
        {
            byte[] data = null;
#if UNITY_WEBGL
            if(!FileExits(fileName, FilePathType.Resources))
            {
                Log.LogWarning("File not found: " + fileName);
                return null;
            }
            path = System.Text.RegularExpressions.Regex.Replace(fileName, @".txt", "");                
            TextAsset t = Resources.Load<TextAsset>(path);
            if(t != null && t.bytes!= null)
            {
                data = t.bytes;
            }
#else
            if(FileExist(fileName, FilePathType.readAndWrite))
            {
                data = File.ReadAllBytes(Path.Combine(readAndWritePath, fileName));
            }
            else if(FileExist(fileName, FilePathType.streamingAsset))
            {
                UnityWebRequest request = UnityWebRequest.Get(Path.Combine(readOnlyStreamAssetPath, fileName));
                request.SendWebRequest();
                while(!request.isDone){}
                if(request.result == UnityWebRequest.Result.Success)
                {
                    data = request.downloadHandler.data;
                }
            }
#endif
            if(data == null)
            {
                Log.LogWarning("File not found: " + fileName);
            }

            if(useXxTea)
            {
               byte[] decryptData = Xxtea.XXTEA.Decrypt(data, xxteaKey);
                if (decryptData != null)
                {
                    data = GZipHelper.GzipDecompress(decryptData);
                }
            }
        
            return data;
        }

        public void DeleteFile(string fileName)
        {
            if(File.Exists(fileName))
            {
                File.Delete(fileName);
            }
        }

        public void DeleteDir(string dirPath)
        {
            if(Directory.Exists(dirPath))
            {
                Directory.Delete(dirPath, true);
            }
        }

        public void CreateDirectoryByFile(string filePath)
        {
            try{
                string dir = Path.GetDirectoryName(filePath);
                if(!Directory.Exists(dir))
                {
                    Directory.CreateDirectory(dir);
                }
            }
            catch(System.Exception ex)
            {
                Log.LogError("CreateDirectoryByFile error: " + ex.Message);
            }
        }

        public void WriteText(string fileName, string content, bool useXxTea = false)
        {
            string filePath = Path.Combine(readAndWritePath, fileName);
            CreateDirectoryByFile(filePath);
            byte[] data = System.Text.Encoding.UTF8.GetBytes(content);
            if(useXxTea)
            {
                data = GZipHelper.GzipCompress(data);
                data = Xxtea.XXTEA.Encrypt(data, xxteaKey);
            }
            File.WriteAllBytes(filePath, data);
        }

        public string ReadText(string fileName, bool useXxTea = false)
        {
            byte[] data = ReadAllByte(fileName, useXxTea);
            if(data == null)
            {
                return null;
            }
            return System.Text.Encoding.UTF8.GetString(data);
        }
    }
}

