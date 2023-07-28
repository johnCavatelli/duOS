using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OS_Manager : MonoBehaviour
{
    public GameObject startupWindow;
    public void OSStart(){
        Invoke("CloseStartupWindow",3.5f);
    }
    private void CloseStartupWindow(){startupWindow.SetActive(false);}
}
