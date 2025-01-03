using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;


namespace wc.framework
{
    public class EditorUIUtil{
        public static void LocationTargetPathInEditor(string path)
        {
            if(Directory.Exists(path) || File.Exists(path))
            {
                UnityEngine.Object obj = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(path);
                EditorGUIUtility.PingObject(obj);
                Selection.activeObject = obj;
            }
        }

        public static void CreateDirectory(string path)
        {
            if(!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
        }

        public static T EnsureComponant<T>(GameObject go) where T:Component
        {
            if(go.GetComponent<T>() == null)
            {
                go.AddComponent<T>();
            }
            return go.GetComponent<T>();            
        }

        public static GameObject EnsuireGameObject(string objName)
        {
            GameObject go = GameObject.Find(objName);
            if(go == null)
            {
                go = new GameObject(objName);
            }
            return go;
        }
    }
}