using System;
using System.Collections.Generic;
using System.Collections;
using UnityEngine;
using UnityEditor;
using System.Reflection;

namespace wc.framework
{
    public enum EditorType{
        GameObject,
        Float,
        Int,
        Text,
        Label,
        Toggle,
        Popup,
        Range,
        Transform,
        InputText,
        Vector2,
        Vector3,
    }

    public enum EditorColor{
        Red,
        Green,
        Yellow,
        White,
    }

    public class CreateEditorAttribute:Attribute,OnGuiInterface{
        private FieldInfo _field;
        private SkillEditorEventInfo _info;
        public string _name;
        public EditorType _type;
        public Color _color = Color.white;

        //gameObject
        public GameObject _gameObject;

        //popup
        public string[] _popPupOptions;
        public int _popupIndex;

        //range
        public float _min;
        public float _max;

        private GUISkin _skin;
        private GUISkin skin{
            get{
                if(_skin == null) {
                    _skin = GUISkin.CreateInstance<GUISkin>();
                }
                return _skin;
            }
        }

        public void SetInfo(FieldInfo field,SkillEditorEventInfo info){
            _field = field;
            _info = info;
            switch(_type) {
                case EditorType.GameObject:
                    string objName = _field.GetValue(_info) as string;
                    if(objName == null) {
                        _gameObject = null;
                        break;
                    }
                    string assetGUID = objName.Substring(objName.LastIndexOf("_")+1);
                    string assetHash = AssetDatabase.GUIDToAssetPath(assetGUID);
                    _gameObject = AssetDatabase.LoadAssetAtPath<GameObject>(assetHash);
                    break;
                case EditorType.Float:
                    break;
                case EditorType.Int:
                    break;
                case EditorType.Text:
                    break;
                case EditorType.Label:
                    break;
                case EditorType.Toggle:
                    break;
                case EditorType.Popup:
                    break;
                case EditorType.Range:
                    break;
                case EditorType.Transform:
                    break;
                case EditorType.InputText:
                    break;
                case EditorType.Vector2:
                    break;
                case EditorType.Vector3:
                    break;
            }
        }


        public CreateEditorAttribute(string name,EditorType type) {
            _name = name;
            _type = type;
        }
        public CreateEditorAttribute(string name,EditorType type,EditorColor color) {
            _name = name;
            _type = type;
            switch(color) {
                case EditorColor.Red:
                    _color = Color.red;
                    break;
                case EditorColor.Green:
                    _color = Color.green;
                    break;
                case EditorColor.Yellow:
                    _color = Color.yellow;
                    break;
                case EditorColor.White:
                    _color = Color.white;
                    break;
            }
        }

        public CreateEditorAttribute(string name,EditorType type,Type typeObj) {
            _name = name;
            _type = type;
            if(type == EditorType.Popup)
            {
                _popPupOptions = Enum.GetNames(typeObj);
            }
        }
        public CreateEditorAttribute(string name,EditorType type,string[] popPupOptions) {
            _name = name;
            _type = type;
            _popPupOptions = popPupOptions;
        }


        public void OnGUI()
        {
            Color preColor = GUI.color;
            GUI.color = _color;
            GUILayout.BeginHorizontal();
            GUILayout.Label(_name,GUILayout.Width(150));
            switch(_type) {
                case EditorType.GameObject:
                    GameObject newObj = EditorGUILayout.ObjectField(_gameObject,typeof(GameObject),true,GUILayout.Width(250)) as GameObject;
                    if(newObj != _gameObject) {
                        _gameObject = newObj;
                        string assetGUID = AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(_gameObject));
                        _field.SetValue(_info,_gameObject.name + "_" + assetGUID);
                    }
                    break;
                case EditorType.Float:
                    float oldFloat = (float)_field.GetValue(_info);
                    float newFloat = EditorGUILayout.FloatField(oldFloat);
                    if(newFloat != oldFloat) {
                        _field.SetValue(_info,newFloat);
                    }
                    break;
                case EditorType.Int:
                    int oldInt = (int)_field.GetValue(_info);
                    int newInt = EditorGUILayout.IntField(oldInt);
                    if(newInt!= oldInt) {
                        _field.SetValue(_info,newInt);
                    }
                    break;
                case EditorType.Text:
                    string oldText = (string)_field.GetValue(_info);
                    string newText = EditorGUILayout.TextField(oldText);
                    if(newText!= oldText) {
                        _field.SetValue(_info,newText);
                    }
                    break;
                case EditorType.Label:
                    break;
                case EditorType.Toggle:
                    bool oldToggle = (bool)_field.GetValue(_info);
                    bool newToggle = EditorGUILayout.Toggle(oldToggle);
                    if(newToggle!= oldToggle) {
                        _field.SetValue(_info,newToggle);
                    }
                    break;
                case EditorType.Popup:
                    int oldPopup = (int)_field.GetValue(_info);
                    int newPopup = EditorGUILayout.Popup(oldPopup,_popPupOptions);
                    if(newPopup!= oldPopup) {
                        _field.SetValue(_info,newPopup);
                    }
                    break;
                case EditorType.Range:
                    float oldRange = (float)_field.GetValue(_info);
                    float newRange = EditorGUILayout.Slider(oldRange,_min,_max);
                    if(newRange!= oldRange) {
                        _field.SetValue(_info,newRange);
                    }
                    break;
                case EditorType.Transform:
                    SkillEditorTransform oldT = (SkillEditorTransform)_field.GetValue(_info);
                    oldT.isCustomize = EditorGUILayout.Toggle("",oldT.isCustomize);
                    if(oldT.isCustomize) {
                        GUILayout.EndHorizontal();
                        GUILayout.BeginVertical();
                        oldT.position = EditorGUILayout.Vector3Field("postion",oldT.position);
                        oldT.rotation = EditorGUILayout.Vector3Field("rotation",oldT.rotation);
                        oldT.scale = EditorGUILayout.Vector3Field("scale",oldT.scale);
                        GUILayout.EndVertical();
                        GUILayout.BeginHorizontal();
                    }
                    _field.SetValue(_info,oldT);
                    break;
                case EditorType.Vector2:
                    Vector2 oldVector2 = (Vector2)_field.GetValue(_info);
                    Vector2 newVector2 = EditorGUILayout.Vector2Field("",oldVector2);
                    if(newVector2!= oldVector2) {
                        _field.SetValue(_info,newVector2);
                    }
                    break;
                case EditorType.Vector3:
                    Vector3 oldVector3 = (Vector3)_field.GetValue(_info);
                    Vector3 newVector3 = EditorGUILayout.Vector3Field("",oldVector3);
                    if(newVector3!= oldVector3) {
                        _field.SetValue(_info,newVector3);
                    }
                    break;
            }
            GUILayout.EndHorizontal();
            GUI.color = preColor;
        }
    }
}