using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditor.Animations;
using System.IO;
using Newtonsoft.Json;
namespace wc.framework
{
    public class SkillEditorWindow:EditorWindow{
        private GameObject _root;
        private GameObject _hero;
        private AnimationClip[] _heroAnims;
        private const string PrefabPath = "Assets/Resources/Res/Role/";
        private SearchBar _bar;
        private int roleSelect = -1;
        private List<string> roleList = new List<string>();
        private List<NormalButton> roleButtonList = new List<NormalButton>();
        private List<NormalButton> searchRoleButtonList = new List<NormalButton>();
        private int animSelect = -1;
        private List<NormalButton> animButtonList = new List<NormalButton>();
        private float animTime = 0;
        private double preTime = 0;
        private float timeScale = 0;
        private SkillEditorInfo _info;
        private SkillEditorAnimInfo _animInfo;

        private GUIContent[] _skilEventContents;
        private GUIContent[] skillEventContents
        {
            get{
                if(_skilEventContents == null) {
                    List<string> eventNames = new List<string>(Enum.GetNames(typeof(SkillEditorEventType)));
                    _skilEventContents = new GUIContent[eventNames.Count];
                    for(int i = 0; i < eventNames.Count; i++) {
                        _skilEventContents[i] = new GUIContent(eventNames[i]);
                    }
                }
                return _skilEventContents;
            }
        }

        [MenuItem("WC/技能编辑器 %F2")]
        public static void Open() {
            SkillEditorWindow window = GetWindow<SkillEditorWindow>();
            window.titleContent = new GUIContent("技能编辑器");
            window.position = new Rect(300,600,870,550);
            window.Init();

            window._root = EditorUIUtil.EnsuireGameObject("Root");
        }

        private void OnDestroy() {
            if(_hero != null)
            {
                GameObject.DestroyImmediate(_hero);
                _hero = null;
            }
        }
        void Init()
        {
            roleList.Clear();
            roleList.Add("W_BaD");
            roleList.Add("W_LvB");

            roleButtonList.Clear();
            for(int i = 0; i < roleList.Count; i++) {
                NormalButton button = new NormalButton(roleList[i],i,200);
                button.OnClick += (obj)=>{
                    NormalButton button = obj as NormalButton;
                    roleSelect = button._index;
                    foreach(var otherBtn in roleButtonList) {
                        otherBtn.ClearSelected();
                    }
                };
                roleButtonList.Add(button);
                searchRoleButtonList.Add(button);
            }

            _bar = new SearchBar();
            _bar.OnSearchBarChangedInvoke += (str)=>{
                searchRoleButtonList.Clear();
                for(int i = 0; i < roleList.Count; i++) {
                    if(string.IsNullOrEmpty(str) || roleList[i].Contains(str)) {
                        searchRoleButtonList.Add(roleButtonList[i]);
                    }
                }
            };
        }
        void OnGUI()
        {
            GUILayout.BeginHorizontal();
            GUILayout.BeginVertical("box",GUILayout.Width(200));
            _bar.OnGUI();
            string curRoleName = roleSelect >= 0 && roleSelect < roleList.Count ? roleList[roleSelect] : "";
            GUILayout.Label($"当前选择角色:{curRoleName}");
            if(GUILayout.Button("选择角色", GUILayout.Width(200)))
            {
                CreateRole();
            }

            GUILayout.Space(10);
            GUILayout.BeginScrollView(  Vector2.zero, GUILayout.Height(200));
            foreach(var button in searchRoleButtonList) {
                button.OnGUI();
            }
            GUILayout.EndScrollView();
            GUILayout.EndVertical();

            GUILayout.BeginVertical();
            if(roleSelect >= 0 && roleSelect < roleList.Count) {
                ShowRoleAnim();
            }
            GUILayout.EndVertical();

            GUILayout.BeginVertical("box");
            ShowAnimClip();
            GUILayout.EndVertical();

            GUILayout.EndHorizontal();
        }

        void CreateRole()
        {
            if(_hero != null) {
                GameObject.DestroyImmediate(_hero);
                _hero = null;
                _heroAnims = null;
                _info = null;
            }
            string prefabPath = PrefabPath + roleList[roleSelect] + "/" + roleList[roleSelect] + ".prefab";
            GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);
            if(prefab != null) {
                _hero = GameObject.Instantiate(prefab);
                _hero.name = roleList[roleSelect];
                _hero.transform.SetParent(_root.transform);
                Animator animator = _hero.GetComponentInChildren<Animator>();
                RuntimeAnimatorController animatorController = animator.runtimeAnimatorController;
                _heroAnims = animatorController.animationClips;
                animButtonList.Clear();
                for(int i = 0; i < _heroAnims.Length; i++) {
                    NormalButton button = new NormalButton(_heroAnims[i].name,i,200);
                    animButtonList.Add(button);
                    button.OnClick += (obj)=>{
                        NormalButton button = obj as NormalButton;
                        animSelect = button._index;
                        animTime = 0;
                        _animInfo = _info.GetAnimInfo(_heroAnims[animSelect].name);
                        if(_animInfo== null)
                        {
                            _animInfo = new SkillEditorAnimInfo()
                            {
                                animName = _heroAnims[animSelect].name,
                                toTalTime = _heroAnims[animSelect].length
                            };
                            _info.animList.Add(_animInfo);
                        }
                        else{
                            foreach(var eventInfo in _animInfo.eventList)
                            {
                                eventInfo.animInfo = _animInfo;
                            }
                        }
                        foreach(var otherBtn in animButtonList) {
                            otherBtn.ClearSelected();
                        }
                    };
                }

                string skillInfoPath = PrefabPath + roleList[roleSelect] + "/" + roleList[roleSelect] + "_SkillInfo.asset";

                TextAsset skillTxtAsset = AssetDatabase.LoadAssetAtPath<TextAsset>(skillInfoPath);
                if(skillTxtAsset!= null)
                {
                    string skillInfoTxt = skillTxtAsset.text;
                    var settings = new JsonSerializerSettings
                    {
                        TypeNameHandling = TypeNameHandling.Auto,
                        ReferenceLoopHandling = ReferenceLoopHandling.Ignore

                    };
                    _info = Newtonsoft.Json.JsonConvert.DeserializeObject<SkillEditorInfo>(skillInfoTxt,settings);
                }
                else{
                    _info = new SkillEditorInfo();
                }
            }
        }

        void ShowRoleAnim() {
            if(_hero != null){
                GUI.color = Color.yellow;
                if(GUILayout.Button("保存当前角色技能",GUILayout.Width(200)))
                {
                    SaveRoleSkill();
                }
                GUI.color = Color.white;
                GUILayout.Space(10);

                GUILayout.Label($"选择技能动画");
                GUILayout.BeginScrollView(  Vector2.zero);
                foreach(var button in animButtonList) {
                    button.OnGUI();
                }
                GUILayout.EndScrollView();
            }
        }

        void SaveRoleSkill()
        {
            if(_info!= null)
            {
                string skillInfoPath = PrefabPath + roleList[roleSelect] + "/" + roleList[roleSelect] + "_SkillInfo.asset";
                var settings = new JsonSerializerSettings
                {
                    TypeNameHandling = TypeNameHandling.Auto
                };
                string skillInfoTxt = Newtonsoft.Json.JsonConvert.SerializeObject(_info,settings);
                TextAsset textAsset = new TextAsset(skillInfoTxt);
                AssetDatabase.CreateAsset(textAsset,skillInfoPath);
                AssetDatabase.SaveAssets();
            }
        }

        void ShowAnimClip()
        {
            if(animSelect < 0 || animSelect >= _heroAnims.Length)
            {
                return;
            }
            GUILayout.BeginHorizontal();
            if(GUILayout.Button("播放",GUILayout.Width(200)))
            {
                preTime = EditorApplication.timeSinceStartup;
                timeScale = 1;
            }
            if(GUILayout.Button("暂停",GUILayout.Width(200)))
            {
                timeScale = 0;
            }
            GUILayout.EndHorizontal();
            AnimationClip clip = _heroAnims[animSelect];
            GUILayout.BeginHorizontal();
            GUILayout.Label("时间轴:");
            float curTime = EditorGUILayout.Slider(animTime,0,clip.length);  
            RefreshRoleByTime(curTime);            
            GUILayout.EndHorizontal();

            
            ShowEvents();
        }

        void ShowEvents()
        {
            if(_info!= null && _animInfo!= null)
            {   
                SkillEditorEventInfo[] arr = _animInfo.eventList.ToArray();
                foreach(var eventInfo in arr)
                {
                    eventInfo.OnGUI();
                }
            }

            if(GUILayout.Button("添加事件",GUILayout.Width(200)))
            {
                EditorUtility.DisplayCustomMenu(new Rect(Event.current.mousePosition.x,Event.current.mousePosition.y,0,0),
                    skillEventContents,
                    0,
                    (data,options,index)=>{
                        SkillEditorEventType type = (SkillEditorEventType)index;    
                        SkillEditorEventInfo eventInfo = SkillEditorInfo.GetSkillEditorEventInfo(type);
                        if(eventInfo!= null)
                        {
                            eventInfo.animInfo = _animInfo;
                            eventInfo.time = animTime;
                            _animInfo.eventList.Add(eventInfo);
                        }
                    },
                    null
                );
            }

        }

        void RefreshRoleByTime(float time)
        {
            AnimationClip clip = _heroAnims[animSelect];
            if(time != animTime)
            {
                if(clip.isLooping)
                {
                    time = time % clip.length;
                }
                else
                {                    
                    if(time > clip.length)
                    {
                        timeScale = 0;
                        time = clip.length;
                    }
                }
                animTime = time;
                Animator animator = _hero.GetComponentInChildren<Animator>();
                clip.SampleAnimation(animator.gameObject,animTime);
                this.Repaint();
            }
        }

        void Update()
        {
            double timeOffset = EditorApplication.timeSinceStartup - preTime;
            preTime = EditorApplication.timeSinceStartup;
            if(timeScale > 0)
            {
                float curTime = animTime + (float)(timeOffset * timeScale);
                RefreshRoleByTime(curTime);
            }
        }
    }
}