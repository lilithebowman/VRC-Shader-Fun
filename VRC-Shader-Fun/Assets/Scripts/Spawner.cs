
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class Spawner : UdonSharpBehaviour {
    public int maximumNumberOfSpawnedObjects = 50;
    public GameObject objectToBeSpawned;
    public float frequencyToSpawnObjectsAt = 5.0f;

    private int numberOfObjectsSpawned = 0;
    private float timeSinceLastSpawnedObject;

	private void Start () {
        timeSinceLastSpawnedObject = Time.realtimeSinceStartup;
	}
	void Update() {
        if (objectToBeSpawned) {
            if (numberOfObjectsSpawned < maximumNumberOfSpawnedObjects) {
                if (timeSinceLastSpawnedObject > frequencyToSpawnObjectsAt) {
                    // Spawn a Udon networked game object!
                    Networking.Instantiate(VRC_EventHandler.VrcBroadcastType.Always, objectToBeSpawned.name, this.transform.position, this.transform.rotation);
				}
			}
		}
    }
}
