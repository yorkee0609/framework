﻿using UnityEditor;
using UnityEditor.UI;
using UnityEngine;

namespace UiParticles.Editor
{
    /// <summary>
    /// Custom editor for UI Particles component
    /// </summary>
    [CustomEditor(typeof(UiParticles))]
    public class UiParticlesEditor : GraphicEditor
    {

        private SerializedProperty m_RenderMode;
        private SerializedProperty m_StretchedSpeedScale;
        private SerializedProperty m_StretchedLenghScale;
        private SerializedProperty m_IgnoreTimescale;
        private SerializedProperty m_RenderedMesh;

        protected override void OnEnable()
        {
            base.OnEnable();

            m_RenderMode = serializedObject.FindProperty("m_RenderMode");
            m_StretchedSpeedScale = serializedObject.FindProperty("m_StretchedSpeedScale");
            m_StretchedLenghScale = serializedObject.FindProperty("m_StretchedLenghScale");
            m_IgnoreTimescale = serializedObject.FindProperty("m_IgnoreTimescale");
            m_RenderedMesh = serializedObject.FindProperty("m_RenderedMesh");
        }


        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            UiParticles uiParticleSystem = (UiParticles) target;
            uiParticleSystem.raycastTarget = false;

            if (GUILayout.Button("Apply to nested particle systems"))
            {
                var nested = uiParticleSystem.gameObject.GetComponentsInChildren<ParticleSystem>();
                foreach (var particleSystem in nested)
                {
                    if (particleSystem.GetComponent<UiParticles>() == null)
                        particleSystem.gameObject.AddComponent<UiParticles>();
                }
            }

            EditorGUILayout.PropertyField(m_RenderMode);

            if (uiParticleSystem.RenderMode == UiParticleRenderMode.StreachedBillboard)
            {
                EditorGUILayout.PropertyField(m_StretchedSpeedScale);
                EditorGUILayout.PropertyField(m_StretchedLenghScale);
            }
            
            if (uiParticleSystem.RenderMode == UiParticleRenderMode.Mesh)
            {
                EditorGUILayout.PropertyField(m_RenderedMesh);
            }

            EditorGUILayout.PropertyField(m_IgnoreTimescale);
            serializedObject.ApplyModifiedProperties();
        }
    }
}
