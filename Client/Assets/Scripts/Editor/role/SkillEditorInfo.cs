using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Diagnostics.Tracing;
using System.Reflection;
using Newtonsoft.Json;

namespace wc.framework
{
    [Serializable]
    public class SkillEditorInfo
    {
        public List<SkillEditorAnimInfo> animList = new List<SkillEditorAnimInfo>();

        public SkillEditorAnimInfo GetAnimInfo(string _animName)
        {
            foreach(var animInfo in animList) {
                if(animInfo.animName == _animName) {
                    return animInfo;
                }
            }
            return null;
        }

        public static SkillEditorEventInfo GetSkillEditorEventInfo( SkillEditorEventType type)
        {
            SkillEditorEventInfo info = null;
            switch(type) {
                // case SkillEditorEventType.Hit:
                //     info = new SkillEditorHitEvent();
                //     break;
                // case SkillEditorEventType.Shoot:
                //     info = new SkillEditorShootEvent();
                //     break;
                // case SkillEditorEventType.AddBuff:
                //     info = new SkillEditorAddBuffEvent();
                //     break;
                // case SkillEditorEventType.RemoveBuff:
                //     info = new SkillEditorRemoveBuffEvent();
                //     break;  
                // case SkillEditorEventType.Summon:
                //     info = new SkillEditorSummonEvent();
                //     break;
                // case SkillEditorEventType.Dispatch:
                //     info = new SkillEditorDispatchEvent();
                //     break;

                // case SkillEditorEventType.BlackScreen:
                //     info = new SkillEditorBlackScreenEvent();
                //     break;
                // case SkillEditorEventType.Camera:
                //     info = new SkillEditorCameraEvent();
                //     break;
                case SkillEditorEventType.PlayEffect:
                    info = new SkillEditorPlayEffect();
                    break;
                // case SkillEditorEventType.PlaySound:
                //     info = new SkillEditorPlaySoundEvent();
                //     break;
            }
            info.type = type;
            return info;
        }
    }

    [Serializable]
    public class SkillEditorAnimInfo
    {
        public string animName;
        public float toTalTime;
        public List<SkillEditorEventInfo> eventList = new List<SkillEditorEventInfo>();
    }


    [JsonConverter(typeof(EnumConverter<SkillEditorEventType>))]
    public enum SkillEditorEventType
    {
        Hit,
        Shoot,
        AddBuff,
        RemoveBuff,
        Summon,
        Dispatch,
        
        //以下为view事件
        BlackScreen,
        Camera,
        PlayEffect,
        PlaySound,

    }

    [JsonConverter(typeof(EnumConverter<SkillEditorEffectBindType>))]
    public enum SkillEditorEffectBindType
    {
        Role,
        Area,
        Screen,
    }

    [JsonConverter(typeof(EnumConverter<SkillEditorEffectBindParentType>))]
    public enum SkillEditorEffectBindParentType
    {
        Root,
        Bip001_Head,
        Bip001_Spine,
        Bip001_L_Hand,
        Bip001_R_Hand,
        Bip001_L_Foot,
        Bip001_R_Foot,
        Bip001_Spine1,
        Bip001_Prop1,
    }

    [JsonConverter(typeof(EnumConverter<SkillEditorEffectDirType>))]
    public enum SkillEditorEffectDirType
    {
        Parent,
        World,
        Screen,
    }

    [JsonConverter(typeof(EnumConverter<SkillEditorEffectScaleType>))]
    public enum SkillEditorEffectScaleType
    {
        Parent,
        World,
    }

    [JsonConverter(typeof(EnumConverter<SkillEditorEffectPosType>))]
    public enum SkillEditorEffectPosType
    {
        parentLocal,
        parentWorld,
        SceneCenter,
        SceneCenterforward,
        World,

    }

    [Serializable]
    public class SkillEditorEventInfo
    {
        [NonSerialized]
        public bool isFoldout = false;
        [NonSerialized]
        public SkillEditorAnimInfo animInfo;
 
        public SkillEditorEventType type;


        [CreateEditor("事件时间",EditorType.Float,EditorColor.White)]
        public float time;

        [NonSerialized]
        private List<CreateEditorAttribute> _attrs;
        private List<CreateEditorAttribute> attrs {
            get{
                if(_attrs == null) {
                    _attrs = new List<CreateEditorAttribute>();
                    Type type = this.GetType();
                    FieldInfo[] fields = type.GetFields();
                    foreach(var field in fields) {
                        object[] attrs = field.GetCustomAttributes(typeof(CreateEditorAttribute),true);
                        if(attrs.Length > 0) {
                            CreateEditorAttribute attr = attrs[0] as CreateEditorAttribute;
                            attr.SetInfo(field,this);
                            _attrs.Add(attr);
                        }
                    }
                }   
                return _attrs;
            }
        }

        public void OnGUI()
        {
            GUILayout.BeginHorizontal();
            isFoldout = EditorGUILayout.Foldout(isFoldout,type.ToString());
            // GUILayout.Label(_type.ToString());
            if(GUILayout.Button("删除",GUILayout.Width(50)))
            {
                animInfo.eventList.Remove(this);
            }
            GUILayout.EndHorizontal();
            if(!isFoldout) {
                return;
            }
            foreach(var attr in attrs) {
                attr.OnGUI();
            }
        }

    }

    [Serializable]
    public class SkillEditorTransform
    {
        public bool isCustomize;
        [JsonConverter(typeof(Vector3Converter))]
        public Vector3 position;
        [JsonConverter(typeof(Vector3Converter))]
        public Vector3 rotation;
        [JsonConverter(typeof(Vector3Converter))]
        public Vector3 scale;
    }

    [Serializable]
    public class SkillEditorPlayEffect:SkillEditorEventInfo
    {
        [CreateEditor("特效资源",EditorType.GameObject,EditorColor.White)]
        public string objName;

        [CreateEditor("特效绑定类型",EditorType.Popup,typeof(SkillEditorEffectBindType))]
        public SkillEditorEffectBindType bindType;


        [CreateEditor("特效绑定父节点",EditorType.Popup,typeof(SkillEditorEffectBindParentType))]
        public SkillEditorEffectBindParentType bindParentType;

        [CreateEditor("特效位置类型",EditorType.Popup,typeof(SkillEditorEffectPosType))]
        public SkillEditorEffectPosType posType;
        [CreateEditor("特效方向类型",EditorType.Popup,typeof(SkillEditorEffectDirType))]
        public SkillEditorEffectDirType dirType;

        [CreateEditor("特效缩放类型",EditorType.Popup,typeof(SkillEditorEffectScaleType))]
        public SkillEditorEffectScaleType scaleType;

        [CreateEditor("自定义坐标",EditorType.Transform,EditorColor.White)]
        public SkillEditorTransform transform = new SkillEditorTransform();

    }
}