using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FullscreenPic : MonoBehaviour
{
    [SerializeField] private GameObject test;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.F) && !test.activeInHierarchy)
        {
            test.SetActive(true);
        }

        if (Input.GetKeyDown(KeyCode.U) && test.activeInHierarchy)
        {
            test.SetActive(false);
        }
    }
}
