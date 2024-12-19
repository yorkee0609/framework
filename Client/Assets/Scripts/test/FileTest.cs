using UnityEngine;
using wc.framework;
public class FileTest:MonoBehaviour
{
    
     private void Awake() {
        XLuaManager.Instance.OnInit();
        // byte[] data = FileHelper.Instance.ReadAllByte("Main.lua",true);
        // string str = System.Text.Encoding.UTF8.GetString(data);
        // Log.LogInfo(str);
    }
}