using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PropertySpace : MonoBehaviour
{
    [SerializeField] bool activated;
    [SerializeField] int currentTileValue;//the tile that's in the slot's value (0 or 1 tile)
    public int spaceValue;
    public int Value{get => spaceValue * (activated?currentTileValue:-1);}
    
    private void OnTriggerEnter2D(Collider2D other) {
        if(other.CompareTag("0B")){
            currentTileValue = 0;
            activated = true;
            other.GetComponent<GridBlock>().ChangeActivated(true);
        }
        else if(other.CompareTag("1B")){
            currentTileValue = 1;
            activated = true;
            other.GetComponent<GridBlock>().ChangeActivated(true);
        }
    }

    private void OnTriggerExit2D(Collider2D other) {
        if(other.CompareTag("0B") || other.CompareTag("1B")){
            activated = false;
            other.GetComponent<GridBlock>().ChangeActivated(false);
        }
    }
}
