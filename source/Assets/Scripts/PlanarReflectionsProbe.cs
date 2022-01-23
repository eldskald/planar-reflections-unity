using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways, AddComponentMenu("Rendering/Planar Reflections Probe")]
public class PlanarReflectionsProbe : MonoBehaviour {



    ///////////////////////////////////////////////////////////////////////////
    // Public properties that show up on the inspector.                      //
    ///////////////////////////////////////////////////////////////////////////

    [Range(1, 4)] public int targetTextureID = 1;
    [Range(0.01f, 1.0f)] public float reflectionsQuality = 1f;
    public bool renderInEditor = false;
    public Vector3 planeNormal;
    public Vector3 planePosition;
    public bool renderBackground = true;
    public float farClipPlane = 1000;

    ///////////////////////////////////////////////////////////////////////////



    ///////////////////////////////////////////////////////////////////////////
    // Basic private methods and properties that control probe behavior,     //
    // both at runtime and at the editor.                                    //
    ///////////////////////////////////////////////////////////////////////////

    private GameObject _probeGO;
    private Camera _probe;
    private ArrayList _ignoredCameras = new ArrayList();

    private void OnEnable () {
        Camera.onPreRender += PreRenderRoutine;
        Camera.onPostRender += PostRenderRoutine;
    }

    private void OnDisable () {
        FinalizeProbe();
        Camera.onPreRender -= PreRenderRoutine;
        Camera.onPostRender -= PostRenderRoutine;
    }

    private void OnDestroy () {
        FinalizeProbe();
        Camera.onPreRender -= PreRenderRoutine;
        Camera.onPostRender -= PostRenderRoutine;
    }

    private void InitializeProbe () {
        _probeGO = new GameObject("", typeof(Camera));
        _probeGO.name = "PRCamera" + _probeGO.GetInstanceID().ToString();
        _probeGO.hideFlags = HideFlags.HideAndDontSave;
        _probe = _probeGO.GetComponent<Camera>();
    }

    private void FinalizeProbe () {
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

        UpdateProbeSettings(cam);
        CreateRenderTexture(cam);
        UpdateProbeTransform(cam);
        CalculateObliqueProjection();
        _probe.Render();
        string texName = "_PlanarReflectionsTex" + targetTextureID.ToString();
        _probe.targetTexture.SetGlobalShaderProperty(texName);
    }

    private void PostRenderRoutine (Camera cam) {
        if (CheckCamera(cam) || _probe == null) {
            return;
        }

        _probe.targetTexture.Release();
        _probe.targetTexture = null;
    }

    ///////////////////////////////////////////////////////////////////////////



    ///////////////////////////////////////////////////////////////////////////
    // Auxiliary private methods called by the ones above. This is           //
    // where most of the math and other gritty details are.                  //
    ///////////////////////////////////////////////////////////////////////////

    private void UpdateProbeSettings (Camera cam) {
        _probe.CopyFrom(cam);
        _probe.enabled = false;
        _probe.cameraType = CameraType.Reflection;
        _probe.usePhysicalProperties = false;
        _probe.farClipPlane = farClipPlane;
        if (!renderBackground) {
            _probe.clearFlags = CameraClearFlags.Nothing;
        }
    }

    private void CreateRenderTexture (Camera cam) {
        int width = (int)((float)cam.pixelWidth * reflectionsQuality);
        int height = (int)((float)cam.pixelHeight * reflectionsQuality);
        _probe.targetTexture = new RenderTexture(width, height, 24);
        _probe.targetTexture.Create();
    }

    // The probe's camera position should be the the current camera's position
    // mirrored by the reflecting plane. Its rotation mirrored too.
    private void UpdateProbeTransform (Camera cam) {
        Vector3 proj = planeNormal.normalized * Vector3.Dot(
            planeNormal.normalized, cam.transform.position - planePosition);
        _probe.transform.position = cam.transform.position - 2 * proj;

        Vector3 probeForward = Vector3.Reflect(
            cam.transform.forward, planeNormal);
        _probe.transform.LookAt(_probe.transform.position + probeForward);
        _probe.transform.Rotate(0f, 0f, -cam.transform.eulerAngles.z);
        // _probe.transform.Rotate(0f, 0f, 180f - cam.transform.eulerAngles.z);
        
    }

    // The clip plane should coincide with the plane with reflections.
    private void CalculateObliqueProjection () {
        Matrix4x4 viewMatrix = _probe.worldToCameraMatrix;
        Vector3 viewPosition = viewMatrix.MultiplyPoint(planePosition);
        Vector3 viewNormal = viewMatrix.MultiplyVector(planeNormal.normalized);
        Vector4 plane = new Vector4(
            viewNormal.x, viewNormal.y, viewNormal.z,
            -Vector3.Dot(viewPosition, viewNormal));
        _probe.projectionMatrix = _probe.CalculateObliqueMatrix(plane);
    }

    ///////////////////////////////////////////////////////////////////////////



    ///////////////////////////////////////////////////////////////////////////
    // Public methods.                                                       //
    ///////////////////////////////////////////////////////////////////////////

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

    ///////////////////////////////////////////////////////////////////////////



    ///////////////////////////////////////////////////////////////////////////
    // Static methods.                                                       //
    ///////////////////////////////////////////////////////////////////////////

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

    ///////////////////////////////////////////////////////////////////////////
}
