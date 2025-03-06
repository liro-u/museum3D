using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DisableLight : MonoBehaviour
{
    [SerializeField] private Light dirLight;
    [SerializeField] private Light playerLight;

    private void OnTriggerEnter(Collider other)
    {
        if (dirLight != null)
        {
            dirLight.gameObject.SetActive(false);  // Désactive la lumière directionnelle
        }

        if (playerLight != null)
        {
            playerLight.gameObject.SetActive(true);  // Active la lumière du joueur
        }
    }
}
