
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class RotationTrigger : UdonSharpBehaviour {
    public GameObject parentObject;
    public GameObject rotationObject;

    private Transform transform;
    void Start() {
        if (rotationObject != null) {
            transform = rotationObject.transform;
            rotationObject.GetComponent<ParticleSystem>().Stop();
        }
    }

    public void LateUpdate() {
        if (rotationObject != null && parentObject != null) {
            if (transform.position.y < parentObject.transform.position.y) {
                if (!rotationObject.GetComponent<ParticleSystem>().isPlaying) {
                    rotationObject.GetComponent<ParticleSystem>().Play();
                }
            } else {
                if (rotationObject.GetComponent<ParticleSystem>().isPlaying) {
                    rotationObject.GetComponent<ParticleSystem>().Stop();
                }
            }
        }
    }
}
