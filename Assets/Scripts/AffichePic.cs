using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AffichePic : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        other.gameObject.GetComponent<HG.DeferredDecals.Decal>().enabled = true;
    }

    /*private void OnTriggerExit(Collider other)
    {
        other.gameObject.GetComponent<HG.DeferredDecals.Decal>().enabled = false;
    }*/
}
