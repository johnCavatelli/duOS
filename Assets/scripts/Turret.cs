using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Turret : MonoBehaviour
{
    public Transform turretHead;
    Transform playerTransform;
    private void Start() {
        playerTransform = GameObject.FindWithTag("Player").transform;
    }

    private void Update() {
        turretHead.LookAt(playerTransform,Vector3.up);
        turretHead.rotation = Quaternion.Euler(0,turretHead.rotation.eulerAngles.y,0);
        //transform.rotatio = 4f;
    }
}
