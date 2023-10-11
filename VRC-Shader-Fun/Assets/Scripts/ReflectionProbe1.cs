﻿
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class ReflectionProbe1 : UdonSharpBehaviour
{
    public GameObject probeGameObject;
    public Vector3 offset = new Vector3(0.0f, 0.0f, 1.0f);
    public Vector3 betweenEyes;
    public Vector3 head;

    private VRCPlayerApi playerLocal;
    void Start() {
#if UNITY_STANDALONE
        probeGameObject.SetActive(true);
#elif UNITY_EDITOR
        probeGameObject.SetActive(true);
#else
        probeGameObject.SetActive(false);
#endif
        playerLocal = Networking.LocalPlayer;
    }

    void LateUpdate() {
        // move realtime probe to player head
        Vector3 leftEye = playerLocal.GetBonePosition(UnityEngine.HumanBodyBones.LeftEye);
        Vector3 rightEye = playerLocal.GetBonePosition(UnityEngine.HumanBodyBones.RightEye);
        head = playerLocal.GetBonePosition(UnityEngine.HumanBodyBones.Head);

        if (leftEye != null && rightEye != null) {
            betweenEyes = leftEye + (rightEye - leftEye) / 2;
            probeGameObject.transform.rotation = playerLocal.GetBoneRotation(UnityEngine.HumanBodyBones.Head);
            probeGameObject.transform.position = betweenEyes + offset;
        } else if (head != null) {
            probeGameObject.transform.rotation = playerLocal.GetBoneRotation(UnityEngine.HumanBodyBones.Head);
            probeGameObject.transform.position = head + offset;
        } else {
            probeGameObject.transform.position = new Vector3(
                playerLocal.GetPosition().x,
                playerLocal.GetPosition().y + 2.0f,
                playerLocal.GetPosition().z
            );
        }
    }
}