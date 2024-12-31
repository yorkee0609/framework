using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using wc.framework;
using System;
using System.Reflection;
using UnityEngine.Windows;
using System.IO;
using UnityEditor.Animations;
public class RolePrefabWindow : EditorWindow  {
    [MenuItem("WC/Role/生成角色 %F1")]
    public static void OpenRolePrefabWindow()
    {
        RolePrefabWindow window = (RolePrefabWindow)EditorWindow.GetWindow(typeof(RolePrefabWindow));   
        window.Open();     
    }

    private List<string> roleList = new List<string>();
    private List<NormalButton> roleButtonList = new List<NormalButton>();
    private List<NormalButton> searchRoleButtonList = new List<NormalButton>();
    private int roleSelect = -1;

    private const string AssetPath = "Assets/Asset/Role";
    private const string PrefabPath = "Assets/Resources/Res/Role/";

    private SearchBar _bar = new SearchBar();
    public void Open()
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
    void OnGUI() {
        // string popName = "英雄选择:" + (roleSelect < roleList.Count && roleSelect >= 0 ?  roleList[roleSelect]: "未选择");
        // int newIndex = EditorGUILayout.Popup(popName,roleSelect,roleList.ToArray());
        // if(newIndex != roleSelect) {
        //     roleSelect = newIndex;
        // }
        GUILayout.BeginHorizontal();
        GUILayout.BeginVertical();
        _bar.OnGUI();
        
        GUILayout.BeginScrollView(  Vector2.zero, GUILayout.Height(200));
        foreach(var button in searchRoleButtonList) {
            button.OnGUI();
        }
        GUILayout.EndScrollView();
        GUILayout.EndVertical();

        if( roleSelect >= 0 && roleSelect < roleList.Count)
        {
            GUILayout.BeginVertical();

            GUILayout.BeginHorizontal();
            GUILayout.Label("定位文件夹",GUILayout.Width(100));
            if(GUILayout.Button("asset",GUILayout.Width(50))) {
                string prefabName = roleList[roleSelect];
                string assetPath = $"{AssetPath}/{prefabName}";
                EditorUIUtil.LocationTargetPathInEditor(assetPath);
            }
            if(GUILayout.Button("prefab",GUILayout.Width(50))) {
                string prefabName = roleList[roleSelect];
                string prefabPath = $"{PrefabPath}/{prefabName}/{prefabName}.prefab";
                EditorUIUtil.LocationTargetPathInEditor(prefabPath);
            }
            GUILayout.EndHorizontal();

            GUI.color = Color.green;
            if(GUILayout.Button("一键生成")) {
                if(roleSelect >= 0 && roleSelect < roleList.Count) {
                    OptimzeModel();
                    CreateAnimatorController();
                    SpecifyMaterial();
                    CreatePrefab();
                }
            }
            GUI.color = Color.white;

            GUILayout.Space(20);

            if(GUILayout.Button("优化模型")) {
                OptimzeModel();
            }
            if(GUILayout.Button("创建状态机")) {
                CreateAnimatorController();
            }
            if(GUILayout.Button("指定材质球贴图")) {
                SpecifyMaterial();
            }
            if(GUILayout.Button("创建预制体")) {
                CreatePrefab();
            }

            GUILayout.EndVertical();
        }
        
        
        GUILayout.EndHorizontal();
    }

    void OptimzeModel() {
        string prefabName = roleList[roleSelect];
        string modelPath = $"{AssetPath}/{prefabName}/Model/{prefabName}@skin.fbx";
        ModelImporter modelImporter = ModelImporter.GetAtPath(modelPath) as ModelImporter;
        modelImporter.materialImportMode = ModelImporterMaterialImportMode.None;
        modelImporter.useFileUnits = true;
        modelImporter.importBlendShapes = false;
        modelImporter.weldVertices = true;
        modelImporter.isReadable = false;
        modelImporter.importVisibility = false;
        modelImporter.importCameras = false;
        modelImporter.importLights = false;
        modelImporter.importConstraints = false;
        modelImporter.importAnimation = false;
        modelImporter.animationType = ModelImporterAnimationType.Generic;
        modelImporter.avatarSetup = ModelImporterAvatarSetup.CreateFromThisModel;
        modelImporter.SaveAndReimport();

        HumanDescription hd = modelImporter.humanDescription;
        TypedReference reference = __makeref(hd);
        FieldInfo fieldInfo = hd.GetType().GetField("m_RootMotionBoneName",BindingFlags.NonPublic | BindingFlags.Instance);
        fieldInfo.SetValueDirect(reference, "Root");
        modelImporter.humanDescription = hd;
        modelImporter.SaveAndReimport();

        //优化骨骼
        List<string> extraExposedTransform = new List<string>();
        GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(modelPath);
        Func<Transform,string,bool> findExtraTransform = null;
        findExtraTransform = (parent,bone)=>
        {
            if(parent.transform.Find(bone))
            {
                extraExposedTransform.Add(bone);
                return true;
            }
            else {
                foreach(Transform child in parent) {
                    bool bFind = findExtraTransform(child,bone);
                    if(bFind) {
                        return true;
                    }
                }
                return false;
            }
        };

        findExtraTransform(prefab.transform,"Root");
        findExtraTransform(prefab.transform,"Bip001 Head");
        findExtraTransform(prefab.transform,"Bip001 Spine");
        findExtraTransform(prefab.transform,"Bip001 L Hand");
        findExtraTransform(prefab.transform,"Bip001 R Hand");
        findExtraTransform(prefab.transform,"Bip001 L Foot");
        findExtraTransform(prefab.transform,"Bip001 R Foot");
        findExtraTransform(prefab.transform,"Bip001 Spine1");
        findExtraTransform(prefab.transform,"Bip001 Prop1");
        modelImporter.optimizeGameObjects = true;
        modelImporter.extraExposedTransformPaths = extraExposedTransform.ToArray();
        modelImporter.SaveAndReimport();

        

        Debug.Log(prefab.name + " 模型优化成功 ~~~~ ");

    }

    void CreateAnimatorController() {
        string prefabName = roleList[roleSelect];
        var anims = AssetDatabase.FindAssets("t:AnimationClip",new string[]{$"{AssetPath}/{prefabName}/Anim"});
        List<AnimationClip> animClips = new List<AnimationClip>();
        foreach(var anim in anims) {
            var animPath = AssetDatabase.GUIDToAssetPath(anim);
            AnimationClip animClip = AssetDatabase.LoadAssetAtPath<AnimationClip>(animPath);
            animClips.Add(animClip);
        }
        EditorUIUtil.CreateDirectory($"{AssetPath}/{prefabName}/AnimatorController");
        string animatorPath = $"{AssetPath}/{prefabName}/AnimatorController/{prefabName}.controller";
        AnimatorController animatorController = AnimatorController.CreateAnimatorControllerAtPath(animatorPath);
        AnimatorStateMachine stateMatchine = animatorController.layers[0].stateMachine;
        stateMatchine.entryPosition = Vector3.zero;
        stateMatchine.exitPosition = Vector3.right * 300;
        stateMatchine.anyStatePosition = Vector3.right * 600;
        for(int i = 0; i < animClips.Count; i++) {
            var clip = animClips[i];
            float x = i / 10;
            float y = i % 10;
            AnimatorState state = stateMatchine.AddState(clip.name,new Vector3(x * 300,100 + y * 70,0));
            state.motion = clip;
            if(clip.name.ToLower().Equals("idle"))
            {
                stateMatchine.defaultState = state;
            }
        }

        EditorUtility.SetDirty(stateMatchine);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    void SpecifyMaterial() {
    }

    void CreatePrefab() {
        string prefabName = roleList[roleSelect];
        string modelPath = $"{AssetPath}/{prefabName}/Model/{prefabName}@skin.fbx";
        string prefabDir = $"{PrefabPath}/{prefabName}";
        EditorUIUtil.CreateDirectory(prefabDir);
        GameObject obj = new GameObject(prefabName);
        GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(modelPath);
        GameObject body = GameObject.Instantiate(prefab);
        body.name = "body";
        body.transform.SetParent(obj.transform);

        var mats = AssetDatabase.FindAssets("t: Material",new string[]{$"{AssetPath}/{prefabName}/Material"});
        Dictionary<string,Material> materialDic = new Dictionary<string, Material>();
        foreach(var mat in mats) {
            var matPath = AssetDatabase.GUIDToAssetPath(mat);
            Material material = AssetDatabase.LoadAssetAtPath<Material>(matPath);
            materialDic.Add(material.name.ToLower(),material);
        }
        
        SkinnedMeshRenderer[] renderers = body.GetComponentsInChildren<SkinnedMeshRenderer>();
        foreach(var renderer in renderers) {
            string materialName = renderer.gameObject.name.ToLower();
            if(materialDic.ContainsKey(materialName)) {
                renderer.material = materialDic[materialName];
            }
        }

        Animator animator = EditorUIUtil.EnsureComponant<Animator>(body);
        string animatorPath = $"{AssetPath}/{prefabName}/AnimatorController/{prefabName}.controller";
        RuntimeAnimatorController animatorController = AssetDatabase.LoadAssetAtPath<RuntimeAnimatorController>(animatorPath);
        animator.runtimeAnimatorController = animatorController;


        Action<GameObject> setLayer = null;
        setLayer = (go)=>{
            go.layer = LayerMask.NameToLayer("Role");
            foreach(Transform child in go.transform) {
                setLayer(child.gameObject);
            }
        };
        setLayer(obj);

        GameObject target = PrefabUtility.SaveAsPrefabAsset(obj,$"{prefabDir}/{prefabName}.prefab");
        DestroyImmediate(obj);
        ProjectWindowUtil.ShowCreatedAsset(target);
        Debug.Log(prefab.name + " 创建成功 ~~~~ ");
    }
}