
using System;
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class masterdetector : UdonSharpBehaviour
{
    private bool isTheMaster = false;
    void Start()
    {
        DetectMaster();
    }

    private void Update()
    {
        if (isTheMaster)
        {
            this.transform.position = Networking.LocalPlayer.GetTrackingData(VRCPlayerApi.TrackingDataType.Head).position;
        }
        
    }

    private void DetectMaster()
    {
        if (Networking.LocalPlayer.IsOwner(gameObject))
        {
            isTheMaster = true;
        }
    }

    public override void OnPlayerLeft(VRCPlayerApi player)
    {
        DetectMaster();
    }
}
