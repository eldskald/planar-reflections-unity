using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraControls : MonoBehaviour {
    
    [Range(0f, 1f)] public float sensitivity = 0.5f;

    private void Start () {
        Cursor.lockState = CursorLockMode.Locked;
    }

    private void Update () {
        if (Cursor.lockState == CursorLockMode.Locked) {
            float rotX = transform.eulerAngles.y;
            float rotY = transform.eulerAngles.x;
            if (rotY > 180) {
                rotY -= 360;
            }
            rotX += Input.GetAxis("Mouse X") * (1f + sensitivity * 9f);
            rotY -= Input.GetAxis("Mouse Y") * (1f + sensitivity * 9f);
            rotY = Mathf.Clamp(rotY, -80f, 80f);
            transform.eulerAngles = new Vector3(rotY, rotX, 0f);
        }
        
        if (Input.GetMouseButtonDown(0)) {
            CatchOrReleaseMouse();
        }

        if (Input.GetKeyDown(KeyCode.Escape)) {
            Screen.fullScreen = !Screen.fullScreen;
        }
    }

    private void CatchOrReleaseMouse () {
        if (Cursor.lockState == CursorLockMode.Locked) {
            Cursor.lockState = CursorLockMode.None;
        }
        else {
            Cursor.lockState = CursorLockMode.Locked;
        }
    }
}
