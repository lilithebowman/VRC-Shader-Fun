
using System;
using System.Collections.Generic;
using System.Linq;
using UdonSharp;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using VRC.SDKBase;
using VRC.Udon;

public class shaderFPS : UdonSharpBehaviour {
	public GameObject shaderToSetFPSOn;

	private Material shaderMaterial;

	private float deltaTime = 0.0f;

	public float currentFrameRate = 60.0f;
	private float lastFramerate = 60.0f;

	private float elapsed = 0.0f;

	void Start () {
		foreach(Material mat in shaderToSetFPSOn.GetComponent<Renderer>().materials) {
			if (mat.HasProperty("_FPS")) {
				shaderMaterial = mat;
			}
		}
        deltaTime = Time.realtimeSinceStartup;
	}
    void Update() {
		elapsed += Time.smoothDeltaTime;
		if (elapsed >= 60f) {
			elapsed = elapsed % 60.0f;

			deltaTime += Time.smoothDeltaTime - deltaTime;
			// float msec = deltaTime * 1000.0f;
			currentFrameRate = Mathf.Lerp(1.0f / deltaTime, lastFramerate, Time.smoothDeltaTime);
			lastFramerate = Mathf.Lerp(lastFramerate, currentFrameRate, Time.smoothDeltaTime);
			if (currentFrameRate >= 60) {
				SetShaderMaterialFPS(60);
			} else if (currentFrameRate >= 30) {
				SetShaderMaterialFPS(30);
			} else if (currentFrameRate >= 20) {
				SetShaderMaterialFPS(20);
			} else {
				SetShaderMaterialFPS(15);
			}
		}
    }

	public void SetShaderMaterialFPS(float FPS) {
		if (shaderMaterial.HasProperty("_FPS")) {
			shaderMaterial.SetFloat("_FPS", FPS);
		} else {
			Debug.Log("shaderFPS.cs script unable to find material with _FPS parameter to set");
		}
	}
}
