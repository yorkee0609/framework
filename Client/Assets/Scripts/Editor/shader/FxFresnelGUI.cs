using System.Collections;
using System;
using UnityEngine;
using UnityEditor;

public class FxFresnelGUI : ShaderGUI
{
    private enum BlendMode
    {
        Add,
        Transparent
    }

    private enum FaceMode
    {
        One,
        Two
    }
    private enum ZWriteSwitch
    {
        Off,
        On
    }

    private static class Styles
    {
        public static readonly string[] blendNames = Enum.GetNames(typeof(BlendMode));
        public static readonly string[] faceNames = Enum.GetNames(typeof(FaceMode));
        public static readonly string[] zwrite = Enum.GetNames(typeof(ZWriteSwitch));

        public static GUIContent BlendModeText = new GUIContent("混合模式");
        public static GUIContent FaceModeText = new GUIContent("单双面", "双面渲染双倍消耗，尽量选择单面");
        public static GUIContent ZWriteText = new GUIContent("深度写入");

        public static GUIContent BaseColorText = new GUIContent("基础颜色", "HDR颜色，可用Intensity提高亮度");
        public static GUIContent BaseTextureText = new GUIContent("基础贴图");
        public static GUIContent UseUV2Text = new GUIContent("使用UV2", "勾选使用UV2，否则使用UV1");
        public static GUIContent AlphaValueText = new GUIContent("透明值");
        public static GUIContent RimColorText = new GUIContent("边缘光颜色");
        public static GUIContent RimPowerText = new GUIContent("菲涅尔强度");

        public static GUIContent NormalText = new GUIContent("法线效果");
        public static GUIContent NormalTextureText = new GUIContent("法线贴图");

        public static string advancedText = "Unity's Advanced Options";
    }

    public static Texture2D WHXSJ_icon;

    MaterialProperty _BlendMode = null;
    MaterialProperty _FaceMode = null;
    MaterialProperty _ZWriteSwitch = null;

    MaterialProperty _BaseColor = null;
    MaterialProperty _MainTex = null;
    MaterialProperty _UseUV2 = null;
    MaterialProperty _AlphaValue = null;
    MaterialProperty _RimColor = null;
    MaterialProperty _RimPower = null;

    MaterialProperty _Normal = null;
    MaterialProperty _NormalLayerShown = null;
    MaterialProperty _NormalTex = null;

    MaterialEditor m_MaterialEditor;
    bool m_FirstTimeApply = true;

    public void FindProperties(MaterialProperty[] props)
    {
        _BlendMode = FindProperty("_BlendMode", props);
        _FaceMode = FindProperty("_FaceMode", props);
        _ZWriteSwitch = FindProperty("_ZWriteSwitch", props);

        _BaseColor = FindProperty("_BaseColor", props);
        _MainTex = FindProperty("_MainTex", props);
        _UseUV2 = FindProperty("_UseUV2", props);
        _AlphaValue = FindProperty("_AlphaValue", props);
        _RimColor = FindProperty("_RimColor", props);
        _RimPower = FindProperty("_RimPower", props);

        _Normal = FindProperty("_Normal", props);
        _NormalLayerShown = FindProperty("_NormalLayerShown", props);
        _NormalTex = FindProperty("_NormalTex", props);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        if (WHXSJ_icon == null)
        {
            string[] icons = AssetDatabase.FindAssets("XSJLogo t:Texture2D", null);
            if (icons.Length > 0)
            {
                WHXSJ_icon = AssetDatabase.LoadAssetAtPath<Texture2D>(AssetDatabase.GUIDToAssetPath(icons[0]));
            }
        }

        FindProperties(props);
        m_MaterialEditor = materialEditor;
        Material material = materialEditor.target as Material;
        ShaderPropertiesGUI(material);//主要面板显示方法，在后面有定义

        if (m_FirstTimeApply)
        {
            m_FirstTimeApply = false;
        }
    }

    public void ShaderPropertiesGUI(Material material)
    {
        EditorGUIUtility.labelWidth = 0f;
        EditorGUI.BeginChangeCheck();
        {
            EditorGUILayout.BeginVertical(GUILayout.MaxWidth(250));
            BlendModePopup();
            EditorGUI.EndDisabledGroup();

            if (WHXSJ_icon != null)
            {
                Rect iconRect = GUILayoutUtility.GetLastRect();
                iconRect.y -= 5;
                iconRect.height = WHXSJ_icon.height; ;
                iconRect.width = WHXSJ_icon.width;
                iconRect.x = EditorGUIUtility.currentViewWidth - iconRect.width - 15;
                iconRect.x = GUILayoutUtility.GetLastRect().xMax > iconRect.x ? GUILayoutUtility.GetLastRect().xMax : iconRect.x;
                GUI.DrawTexture(iconRect, WHXSJ_icon, ScaleMode.StretchToFill);
            }
            FaceModePopup();
            ZWriteSwitchPopup();
            EditorGUILayout.EndVertical();

            //base
            m_MaterialEditor.ShaderProperty(_BaseColor, Styles.BaseColorText, 0);
            m_MaterialEditor.ShaderProperty(_MainTex, Styles.BaseTextureText, 0);
            m_MaterialEditor.ShaderProperty(_UseUV2, Styles.UseUV2Text, 0);
            m_MaterialEditor.ShaderProperty(_AlphaValue, Styles.AlphaValueText, 0);
            m_MaterialEditor.ShaderProperty(_RimColor, Styles.RimColorText, 0);
            m_MaterialEditor.ShaderProperty(_RimPower, Styles.RimPowerText, 0);
        }
        Color bCol = GUI.backgroundColor;

        //normal
        GUI.backgroundColor = new Color(1.0f, 1.0f, 1.0f, 0.5f);
        EditorGUILayout.BeginVertical("Button");
        GUI.backgroundColor = bCol;
        {
            EditorGUI.showMixedValue = _Normal.hasMixedValue;
            float nval;
            EditorGUI.BeginChangeCheck();
            if (_Normal.floatValue == 1)
            {
                material.EnableKeyword("_NORMAL_ON");
                nval = EditorGUILayout.ToggleLeft(Styles.NormalText, _Normal.floatValue == 1, EditorStyles.boldLabel, GUILayout.Width(EditorGUIUtility.currentViewWidth - 60)) ? 1 : 0;
            }
            else
            {
                material.DisableKeyword("_NORMAL_ON");
                material.SetTexture("_NormalTex",null);
                nval = EditorGUILayout.ToggleLeft(Styles.NormalText, _Normal.floatValue == 1, EditorStyles.boldLabel) ? 1 : 0;
            }
            if (EditorGUI.EndChangeCheck())
            {
                _Normal.floatValue = nval;
            }
            EditorGUI.showMixedValue = false;
        }
        //fold
        if (_Normal.floatValue == 1)
        {
            Rect rect = GUILayoutUtility.GetLastRect();
            rect.x += EditorGUIUtility.currentViewWidth - 45;

            EditorGUI.BeginChangeCheck();
            float nval = EditorGUI.Foldout(rect, _NormalLayerShown.floatValue == 1, "") ? 1 : 0;
            if (EditorGUI.EndChangeCheck())
            {
                _NormalLayerShown.floatValue = nval;
            }
        }
        //setting
        if (_Normal.floatValue == 1 && (_NormalLayerShown.floatValue == 1 || _NormalLayerShown.hasMixedValue))
        {
            m_MaterialEditor.TexturePropertySingleLine(Styles.NormalTextureText, _NormalTex);
        }
        EditorGUILayout.EndVertical();


        //set mode
        if (EditorGUI.EndChangeCheck())
        {
            foreach (var obj in _BlendMode.targets)
            {
                SetupMaterialWithBlendMode((Material)obj, (BlendMode)_BlendMode.floatValue);
            }
            foreach (var obj in _FaceMode.targets)
            {
                SetupMaterialWithCullMode((Material)obj, (FaceMode)_FaceMode.floatValue);
            }
            foreach (var obj in _ZWriteSwitch.targets)
            {
                SetupMaterialWithZWriteSwitch((Material)obj, (ZWriteSwitch)_ZWriteSwitch.floatValue);
            }
        }

        //other options
        EditorGUILayout.Space();
        GUILayout.Label(Styles.advancedText, EditorStyles.boldLabel);
        m_MaterialEditor.RenderQueueField();
        m_MaterialEditor.EnableInstancingField();
    }

    void BlendModePopup()
    {
        EditorGUI.showMixedValue = _BlendMode.hasMixedValue;
        var mode = (BlendMode)_BlendMode.floatValue;

        EditorGUI.BeginChangeCheck();
        mode = (BlendMode)EditorGUILayout.Popup(Styles.BlendModeText, (int)mode, Styles.blendNames);
        if (EditorGUI.EndChangeCheck())
        {
            m_MaterialEditor.RegisterPropertyChangeUndo("Rendering Mode");
            _BlendMode.floatValue = (float)mode;

        }
        EditorGUI.showMixedValue = false;
    }

    void FaceModePopup()
    {
        EditorGUI.showMixedValue = _FaceMode.hasMixedValue;
        var mode = (FaceMode)_FaceMode.floatValue;

        EditorGUI.BeginChangeCheck();
        mode = (FaceMode)EditorGUILayout.Popup(Styles.FaceModeText, (int)mode, Styles.faceNames);
        if (EditorGUI.EndChangeCheck())
        {
            m_MaterialEditor.RegisterPropertyChangeUndo("Face Mode");
            _FaceMode.floatValue = (float)mode;
        }

        EditorGUI.showMixedValue = false;

    }
        void ZWriteSwitchPopup()
    {
        EditorGUI.showMixedValue = _ZWriteSwitch.hasMixedValue;
        var mode = (ZWriteSwitch)_ZWriteSwitch.floatValue;

        EditorGUI.BeginChangeCheck();
        mode = (ZWriteSwitch)EditorGUILayout.Popup(Styles.ZWriteText, (int)mode, Styles.zwrite);
        if (EditorGUI.EndChangeCheck())
        {
            m_MaterialEditor.RegisterPropertyChangeUndo("zwrite Mode");
            _ZWriteSwitch.floatValue = (float)mode;
        }

        EditorGUI.showMixedValue = false;

    }

    static void SetupMaterialWithBlendMode(Material material, BlendMode blendMode)
    {
        switch (blendMode)
        {
            case BlendMode.Add:
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                break;
            case BlendMode.Transparent:
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                break;
        }
    }

    static void SetupMaterialWithCullMode(Material material, FaceMode cullMode)
    {
        switch (cullMode)
        {
            case FaceMode.One:
                material.SetInt("_CullMode", (int)UnityEngine.Rendering.CullMode.Back);
                break;
            case FaceMode.Two:
                material.SetInt("_CullMode", (int)UnityEngine.Rendering.CullMode.Off);
                break;
        }
    }
    static void SetupMaterialWithZWriteSwitch(Material material, ZWriteSwitch Zwrite)
    {
        switch (Zwrite)
        {
            case ZWriteSwitch.Off:
                material.SetInt("_ZWriteSwitch", (int)0);
                break;
            case ZWriteSwitch.On:
                material.SetInt("_ZWriteSwitch", (int)1);
                break;
        }
    }
}
