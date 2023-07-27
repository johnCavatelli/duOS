using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player2D : MonoBehaviour
{
    public Rigidbody2D rb;
    public float walkSpeed;
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        rb.velocity = GetMovementVector();
    }

    Vector2 GetMovementVector(){
        if(Input.GetKey(KeyCode.A)){
            return Vector2.left * walkSpeed;
        }
        if(Input.GetKey(KeyCode.W)){
            return Vector2.up * walkSpeed;
        }
        if(Input.GetKey(KeyCode.S)){
            return Vector2.down * walkSpeed;
        }
        if(Input.GetKey(KeyCode.D)){
            return Vector2.right * walkSpeed;
        }
        return Vector2.zero;
    }
}
