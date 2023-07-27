using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Property : MonoBehaviour
{
    public PropertySpace[] spaces;

    public int GetValue(){
        int total = 0;
        foreach(PropertySpace s in spaces){
            if(s.Value == -1){return -1;}
            total += s.Value;
        }
        return total;
    }

    private void Update() {
        print(GetValue());
    }
}
