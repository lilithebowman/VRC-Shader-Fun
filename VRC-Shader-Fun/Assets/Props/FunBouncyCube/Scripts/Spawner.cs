
using System.Collections.Generic;

using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class Spawner : UdonSharpBehaviour {
    public int maximumNumberOfSpawnedObjects = 500;
    public GameObject objectToBeSpawned;
    public float frequencyToSpawnObjectsAt = 0.5f; // default to once per 500 ms

    private int objectsSpawned = 0;
    private float timeSinceLastSpawnedObject;
    private float timeInterval;

	private void Start () {
        timeInterval = frequencyToSpawnObjectsAt;
        timeSinceLastSpawnedObject = 0.0f;
	}
	void Update() {
        if (objectToBeSpawned) {
            if (objectsSpawned < maximumNumberOfSpawnedObjects) {

                Debug.Log(timeInterval);
                Debug.Log(timeSinceLastSpawnedObject);
                if (Time.timeSinceLevelLoad > (timeSinceLastSpawnedObject + timeInterval)) {
                    // Reset the timer
                    timeSinceLastSpawnedObject = Time.timeSinceLevelLoad;

                    // Spawn a Udon networked game object!
                    GameObject newObject = VRCInstantiate(objectToBeSpawned);
                    objectsSpawned++;

                    // Log it!
                    Debug.Log("A new " + objectToBeSpawned.name + " has spawned at " + Time.timeSinceLevelLoad + "!");
                    Debug.Log("Next one at " + Time.timeSinceLevelLoad + "+" + timeInterval);
                }
			}
		}
    }
}
