using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GridConformer : MonoBehaviour
{
    public Rigidbody2D rb;
    public float forceMult = 0.1f;
    public float snapMagnitude = 0.1f;
    private void Update() {
        float xTarget = Mathf.Round(transform.position.x);
        float yTarget = Mathf.Round(transform.position.y);
        Vector2 targ = new Vector2(xTarget, yTarget);
        Vector2 pos = new Vector2(transform.position.x, transform.position.y);
        Vector2 calcTarg = targ - pos;
        if(calcTarg.magnitude < snapMagnitude){
            transform.position = new Vector3(targ.x, targ.y ,0);
            rb.velocity = Vector2.zero;
        }
        else{
            rb.velocity = (calcTarg * forceMult );
        }
    }
}
