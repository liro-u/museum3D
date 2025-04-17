using UnityEngine;

[RequireComponent(typeof(Collider))]
public class StopSound : MonoBehaviour
{
    [Tooltip("Assign the AudioSource to stop when the player enters this trigger.")]
    [SerializeField] private AudioSource audioSource;

    private void Reset()
    {
        var col = GetComponent<Collider>();
        col.isTrigger = true;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            if (audioSource != null)
                audioSource.Stop();
            else
                Debug.LogWarning("AudioSource not assigned in StopSound script.", this);
        }
    }
}