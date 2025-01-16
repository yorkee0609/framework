using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Profiling;
using UnityEngine.UI;

[ExecuteInEditMode]
public class UIParticleTrail : MaskableGraphic
{
    static readonly int s_IdMainTex = Shader.PropertyToID("_MainTex");
    static readonly List<Vector3> s_Vertices = new List<Vector3>();

    public ParticleSystem m_ParticleSystem;
    public ParticleSystemRenderer _renderer;
    private Mesh _mesh;

    public override Texture mainTexture
    {
        get
        {
            Texture tex = null;
            if (!tex && _renderer)
            {
                var mat = _renderer.trailMaterial;
                if (mat && mat.HasProperty(s_IdMainTex))
                {
                    tex = mat.mainTexture;
                }
            }
            return tex ?? s_WhiteTexture;
        }
    }

    public override Material GetModifiedMaterial(Material baseMaterial)
    {
        return base.GetModifiedMaterial(_renderer ? _renderer.trailMaterial : baseMaterial);
    }

    protected override void OnEnable()
    {
        m_ParticleSystem = m_ParticleSystem ? m_ParticleSystem : GetComponent<ParticleSystem>();
        _renderer = m_ParticleSystem ? m_ParticleSystem.GetComponent<ParticleSystemRenderer>() : null;

        _mesh = new Mesh();
        _mesh.MarkDynamic();
        base.OnEnable();
        raycastTarget = false;

        Canvas.willRenderCanvases += UpdateMesh;
    }

    protected override void OnDisable()
    {
        Canvas.willRenderCanvases -= UpdateMesh;
        DestroyImmediate(_mesh);
        _mesh = null;
        base.OnDisable();
    }

    protected override void UpdateGeometry()
    {
    }
    
    bool InLayer(LayerMask lm, int layer)
    {
        if((lm.value & (int)Mathf.Pow(2,layer)) == (int)Mathf.Pow(2,layer))
        {
            return true;
        }
        return false;
    }

    void UpdateMesh()
    {
        try
        {
            if (m_ParticleSystem)
            {
                if (Application.isPlaying)
                {
                    _renderer.enabled = false;
                }

                var cam = canvas == null? null :canvas.worldCamera;// ?? Camera.main;
                if (cam == null)
                {
                    var allCams = Camera.allCameras;
                    for (var i = 0; i < allCams.Length; i++)
                    {
                        if (InLayer(allCams[i].cullingMask, LayerMask.NameToLayer("UI")))
                            cam = allCams[i];
                    }
                }
                
                bool useTransform = false;
                Matrix4x4 matrix = default(Matrix4x4);
                switch (m_ParticleSystem.main.simulationSpace)
                {
                    case ParticleSystemSimulationSpace.Local:
                        matrix =
                        Matrix4x4.Rotate(m_ParticleSystem.transform.rotation).inverse
                         * Matrix4x4.Scale(m_ParticleSystem.transform.lossyScale).inverse;
                        useTransform = true;
                        break;
                    case ParticleSystemSimulationSpace.World:
                        matrix = m_ParticleSystem.transform.worldToLocalMatrix;
                        break;
                    case ParticleSystemSimulationSpace.Custom:
                        break;
                }

                _mesh.Clear();
                if (0 < m_ParticleSystem.particleCount)
                {
                    var origCamPos = cam.transform.position;
                    // fix 相机过远会导致计算异常
                    cam.transform.position = new Vector3(0, 0, -50);
                    _renderer.BakeTrailsMesh(_mesh, cam, useTransform);
                    cam.transform.position = origCamPos;
                    _mesh.GetVertices(s_Vertices);
                    var count = s_Vertices.Count;
                    for (int i = 0; i < count; i++)
                    {
                        s_Vertices[i] = matrix.MultiplyPoint3x4(s_Vertices[i]);
                    }
                    _mesh.SetVertices(s_Vertices);
                    s_Vertices.Clear();
                }

                canvasRenderer.SetMesh(_mesh);
                canvasRenderer.SetTexture(mainTexture);
            }
        }
        catch (System.Exception e)
        {
            Debug.LogError(e.Message);
        }
    }
}
