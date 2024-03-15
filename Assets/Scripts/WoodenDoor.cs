using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WoodenDoor : MonoBehaviour
{
    // Start is called before the first frame update
    public GameObject doorPivot;
    public AudioSource doorOpen;
    public AudioSource doorClose;
    
    void Start()
    {
        StartCoroutine(DoorOpening());
    }

    IEnumerator DoorOpening()
    {
        yield return new WaitForSeconds(2);
        doorOpen.Play();
        //doorPivot.GetComponent<Animator>().Play("Door_open");
        yield return new WaitForSeconds(6);
        doorClose.Play();
    }
   
}
