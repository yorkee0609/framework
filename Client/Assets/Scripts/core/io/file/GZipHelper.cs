using System.IO;
using UnityEngine;
using System;
using System.Text;
using ICSharpCode.SharpZipLib.GZip;

namespace wc.framework
{
    public sealed class GZipHelper {

        private GZipHelper() {
        }

        // 压缩
        public static byte[] GzipCompress(byte[] binary)
        {
            byte[] press = null;
            try
            {
                MemoryStream outStream = new MemoryStream();
                GZipOutputStream gzip = new GZipOutputStream(outStream);
                gzip.Write(binary, 0, binary.Length);
                gzip.Close();
                press = outStream.ToArray();
                outStream.Close();
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
            }
            return press;
        }

        // 解压
        public static byte[] GzipDecompress(byte[] outBytes)
        {
            byte[] depress = null;
            try
            {    
                MemoryStream inStream = new MemoryStream(outBytes);
                GZipInputStream gzi = new GZipInputStream(inStream);
                MemoryStream outStream = new MemoryStream();
                int count=0;
                byte[] data=new byte[4096];
                while ((count = gzi.Read(data, 0, data.Length)) != 0)
                {
                    outStream.Write(data,0,count);
                }
                gzi.Close();
                inStream.Close();
                depress = outStream.ToArray();
                outStream.Close();
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
            }
            return depress;
        }
    }


    public class LuaZipHelper : Singleton<LuaZipHelper>
    {


        // 先压缩再加密
        public string GzipCompressAndEncrypt(string content, string encrypt_key)
        {
            string eOutStr = null;
            try
            {
                byte[] binary = Encoding.UTF8.GetBytes(content);                
                byte[] press = GZipHelper.GzipCompress(binary);
                if( press != null )
                    eOutStr = Xxtea.XXTEA.EncryptToBase64String(press, encrypt_key);
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
            }
            return eOutStr;
        }

        // 先解密再解压
        public string GzipDecompressAndDecrypt(string content, string decrypt_key)
        {
            string outStr = null;
            try
            {
                byte[] outBytes = Xxtea.XXTEA.DecryptBase64String(content, decrypt_key);
                byte[] depress = GZipHelper.GzipDecompress(outBytes);
                if( depress != null )
                    outStr = Encoding.UTF8.GetString(depress);
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
            }
            return outStr;
        }
        
        // 还原原始配置文件内容(上面书写格式会让配置内容加入空格和换行内容，需要清理还原)
        String TrimSdkCfgText(String cfg)
        {
            return cfg.Trim().Replace("\n", "").Replace(" ","").Replace("\t","").Replace("\r","");
        }
        
        String BytesHexString(byte[] bytes, UInt32 len)
        {
            return BitConverter.ToString(bytes,0,(int)len).Replace("-","");
        }
        

    }
}

