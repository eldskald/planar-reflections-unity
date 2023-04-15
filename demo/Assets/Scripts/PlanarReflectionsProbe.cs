///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// Planar Reflections Probe for Unity                                        //
//                                                                           //
// Author: Rafael Bordoni                                                    //
// Date: January 25, 2022                                                    //
// Last Update: April 14, 2023                                               //
// Email: rafaelbordoni00@gmail.com                                          //
// Repository: https://github.com/eldskald/planar-reflections-unity          //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways, AddComponentMenu("Rendering/Planar Reflections Probe")]
public class PlanarReflectionsProbe : MonoBehaviour {

    [Range(1, 4)] public int targetTextureID = 1;
    [Space(10)]
    public bool useCustomNormal = false;
    public Vector3 customNormal;
    [Space(10)]
    [Range(0.01f, 1.0f)] public float reflectionsQuality = 1f;
    public float farClipPlane = 1000;
    public bool renderBackground = true;
    [Space(10)]
    public bool renderInEditor = false;

    private GameObject _probeGO;
    private Camera _probe;
    private Skybox _probeSkybox;
    private Dictionary<Camera, RenderTexture> _camTextureMap =
        new Dictionary<Camera, RenderTexture>();
    private ArrayList _ignoredCameras = new ArrayList();


    private void OnEnable () {
        Camera.onPreRender += PreRenderRoutine;
    }

    private void OnDisable () {
        FinalizeProbe();
        Camera.onPreRender -= PreRenderRoutine;
    }

    private void OnDestroy () {
        FinalizeProbe();
        Camera.onPreRender -= PreRenderRoutine;
    }

    private void InitializeProbe () {
        _probeGO = new GameObject("", typeof(Camera), typeof(Skybox));
        _probeGO.name = "PRCamera" + _probeGO.GetInstanceID().ToString();
        _probeGO.hideFlags = HideFlags.HideAndDontSave;
        _probe = _probeGO.GetComponent<Camera>();
        _probeSkybox = _probeGO.GetComponent<Skybox>();
        _probeSkybox.enabled = false;
        _probeSkybox.material = null;
    }

    private void FinalizeProbe () {
        CleanupRenderTextures();
        if (_probe == null) {
            return;
        }
        if (Application.isEditor) {
            DestroyImmediate(_probeGO);
        }
        else {
            Destroy(_probeGO);
        }
    }

    private void CleanupRenderTextures() {
        foreach (RenderTexture texture in _camTextureMap.Values) {
            texture.Release();
        }
        _camTextureMap.Clear();
    }

    private bool CheckCamera (Camera cam) {
        if (cam.cameraType == CameraType.Reflection) {
            return true;
        }
        else if (!renderInEditor && cam.cameraType == CameraType.SceneView) {
            return true;
        }
        else if (_ignoredCameras.Contains(cam)) {
            return true;
        }
        return false;
    }

    private void PreRenderRoutine (Camera cam) {
        if (CheckCamera(cam)) {
            return;
        }
        else if (_probe == null) {
            InitializeProbe();
        }
        Vector3 normal = GetNormal();
        UpdateProbeSettings(cam);
        CreateRenderTexture(cam);
        UpdateProbeTransform(cam, normal);
        CalculateObliqueProjection(normal);
        _probe.Render();
        string texName = "_PlanarReflectionsTex" + targetTextureID.ToString();
        _probe.targetTexture.SetGlobalShaderProperty(texName);
    }

    private void UpdateProbeSettings (Camera cam) {
        _probe.CopyFrom(cam);
        _probe.enabled = false;
        _probe.cameraType = CameraType.Reflection;
        _probe.usePhysicalProperties = false;
        _probe.farClipPlane = farClipPlane;
        _probeSkybox.material = null;
        _probeSkybox.enabled = false;
        if (renderBackground) {
            _probe.clearFlags = cam.clearFlags;
            if (cam.GetComponent<Skybox>()) {
                Skybox camSkybox = cam.GetComponent<Skybox>();
                _probeSkybox.material = camSkybox.material;
                _probeSkybox.enabled = camSkybox.enabled;
            }
        }
        else {
            _probe.clearFlags = CameraClearFlags.Nothing;
        }
    }

    private void CreateRenderTexture(Camera cam) {
        int width = (int)((float)cam.pixelWidth * reflectionsQuality);
        int height = (int)((float)cam.pixelHeight * reflectionsQuality);
        RenderTexture texture = _camTextureMap.GetValueOrDefault(cam, null);
        if (!texture || texture.width != width || texture.height != height) {
            if (texture) {
                _camTextureMap.Remove(cam);
                texture.Release();
            }
            _probe.targetTexture = new RenderTexture(width, height, 24);
            _probe.targetTexture.Create();
            _camTextureMap.Add(cam, _probe.targetTexture);
        }
        else {
            _probe.targetTexture = texture;
        }
    }

    private Vector3 GetNormal () {
        if (!useCustomNormal) {
            return transform.forward;
        }
        else if (customNormal.Equals(Vector3.zero)) {
            return Vector3.up;
        }
        else {
            return customNormal.normalized;
        }
    }

    // The probe's camera position should be the the current camera's position
    // mirrored by the reflecting plane. Its rotation mirrored too.
    private void UpdateProbeTransform (Camera cam, Vector3 normal) {
        Vector3 proj = normal * Vector3.Dot(
            normal, cam.transform.position - transform.position);
        _probe.transform.position = cam.transform.position - 2 * proj;
        Vector3 probeForward = Vector3.Reflect(cam.transform.forward, normal);
        Vector3 probeUp = Vector3.Reflect(cam.transform.up, normal);
        _probe.transform.LookAt(
            _probe.transform.position + probeForward, probeUp);
    }

    // The clip plane should coincide with the plane with reflections.
    private void CalculateObliqueProjection (Vector3 normal) {
        Matrix4x4 viewMatrix = _probe.worldToCameraMatrix;
        Vector3 viewPosition = viewMatrix.MultiplyPoint(transform.position);
        Vector3 viewNormal = viewMatrix.MultiplyVector(normal);
        Vector4 plane = new Vector4(
            viewNormal.x, viewNormal.y, viewNormal.z,
            -Vector3.Dot(viewPosition, viewNormal));
        _probe.projectionMatrix = _probe.CalculateObliqueMatrix(plane);
    }


    public void IgnoreCamera (Camera cam) {
        if (!_ignoredCameras.Contains(cam)) {
            _ignoredCameras.Add(cam);
        }
    }

    public void UnignoreCamera (Camera cam) {
        if (_ignoredCameras.Contains(cam)) {
            _ignoredCameras.Remove(cam);
        }
    }

    public void ClearIgnoredList () {
        _ignoredCameras.Clear();
    }

    public bool IsIgnoring (Camera cam) {
        return _ignoredCameras.Contains(cam);
    }


    public static PlanarReflectionsProbe[] FindProbesRenderingTo (int id) {
        var probes = FindObjectsOfType<PlanarReflectionsProbe>();
        ArrayList list = new ArrayList();
        foreach (PlanarReflectionsProbe probe in probes) {
            if (probe.targetTextureID == id) {
                list.Add(probe);
            }
        }
        return (PlanarReflectionsProbe[])list.ToArray(
            typeof(PlanarReflectionsProbe));
    }

    public static PlanarReflectionsProbe FindProbeRenderingTo (int id) {
        var probes = FindObjectsOfType<PlanarReflectionsProbe>();
        foreach (PlanarReflectionsProbe probe in probes) {
            if (probe.targetTextureID == id) {
                return probe;
            }
        }
        return null;
    }
}
