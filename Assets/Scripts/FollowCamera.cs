using UnityEngine;

public class FollowCamera : MonoBehaviour
{
    private Transform cameraTransform;

    private void Start()
    {
        cameraTransform = Camera.main.transform; // Trouve la cam�ra principale
    }

    private void Update()
    {
        transform.position = cameraTransform.position; // Suit la position de la cam�ra
        transform.eulerAngles = cameraTransform.eulerAngles; // Suit la rotation de la cam�ra
    }
}

