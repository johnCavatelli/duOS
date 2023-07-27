using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GridBlock : MonoBehaviour
{
    public Sprite unactivated;
    public Sprite activated;
    public SpriteRenderer sr;

    public bool startActivated;
    bool isActivated;

    private void Start() {
        isActivated = startActivated;
    }

    public void ChangeActivated(bool newState){
        isActivated = newState;
        sr.sprite = isActivated ? activated : unactivated;
    }
}

