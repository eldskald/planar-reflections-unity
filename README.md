# Planar Reflections for Unity's Built-In Render Pipeline

![](images/ss1.png)

This project is a small demo and the code for a planar reflections probe, easy to incorporate into any project. Feel free to use it on your own games or to study and and learn from it! The main file you're looking for is [this](source/Assets/Scripts/PlanarReflectionsProbe.cs) one if you want to see how I made my implementation. Feel free to optimize, adapt it to your projects or use it as is.

# Instructions

Just add the [this](source/Assets/Scripts/PlanarReflectionsProbe.cs) C# script file and [this](source/Assets/Shaders/PlanarReflections.cginc) shader include file to your project. After that, go to the editor and you can add the Planar Reflections Probe component to any game object in the scene, just click Add Component > Rendering > Planar Reflections Probe.

In order to render them somewhere, you need to write your own shader, include the .cginc file in it and enable one of the _PRID_ONE, _PRID_TWO, etc keywords depending on what you set the probe's target ID number. You can see the [water shader](source/Assets/Shaders/Water.shader) I wrote as an example, using a KeywordEnum tag and multi-compile for and easy implementation. Read the comments on the shader files for more information.

# Documentation

This is how a planar reflections probe looks like in the inspector:

![](images/inspector1.png)

You can put the component in an empty game object like I did, but there is no problem doing so in a game object with other components. How each property and method works can be seen on the code, but here's an easy guide.

## Properties

| Type | Property | Description |
|:----:|:---------|:------------|
| *int* | targetTextureID | Which texture slot this probe will render to. There are four slots, in case you want to have multiple reflective surfaces on the scene, make multiple probes and make each one render to a different ID. Be aware that each probe is a render call from a camera, so it can be quite GPU intensive |
| *bool* | useForwardAsNormal | Uses the forward vector from the transform where the probe component is as the reflective plane's normal. When true, planeNormal does nothing. Use it when the reflective plane is in an awkward rotation, just put the probe in the same location as the plane and rotate it so that the forward vector (the blue one on the widget) points outwards to it. |
| *Vector3* | planeNormal | The normal direction of the reflective plane. |
| *Vector3* | planePosition | The position of the reflective plane. Can be any point on the plane really, but the position on the transform will do as well. |
| *float* | reflectionsQuality | The resolution of the texture this probe will render to. This float will multiply the current camera this probe is rendering to, so if you're rendering a 1080p screen and set the probe to 0.5, the reflections texture will be 540p. |
| *float* | farClipPlane | The far value of the camera this probe will spawn in order to render the reflections. |
| *bool* | renderBackground | If turned on, will use whatever settings and custom skyboxes on the camera this probe is rendering to. Otherwise, background will have an alpha value of zero on the rendered texture. |
| *bool* | renderInEditor | Allows this probe to render in the editor. |

## Public Methods

| Type | Method | Description |
|:----:|:-------|:------------|
| *void* | IgnoreCamera (Camera cam) | By default, the probe will render reflections for every render call from any camera. If you want it not to render for a specific camera, use this method with *cam* as the camera you want it to ignore. |
| *void* | UnignoreCamera (Camera cam) | Each time you use the IgnoreCamera method, the camera is sent to an internal list of ignored cameras. Use this method to remove the camera *cam* from this list and start rendering reflections to it again. |
| *bool* | IsIgnoring (Camera cam) | Returns true if *cam* is on the ignored list, false otherwise. |
| *void* | ClearIgnoredList () | Empties the ignored list. |

## Static Methods

| Type | Method | Description |
|:----:|:-------|:------------|
| *PlanarReflectionsProbe* | FindProbeRenderingTo (int id) | Returns the first PlanarReflectionsProbe object found on the scene that's rendering to target ID *id*. |
| *PlanarReflectionsProbe[]* | FindProbesRenderingTo (int id) | Returns an array of all PlanarReflectionsProbe objects on the scene that are rendering to target ID *id*. |

# Credits

All code, the water and its material by [Rafael Bordoni](https://github.com/eldskald). All 3D models by [Broken Vector](https://assetstore.unity.com/publishers/12124).
