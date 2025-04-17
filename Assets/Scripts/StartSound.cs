using UnityEngine;

[RequireComponent(typeof(Collider))]
public class StartSound : MonoBehaviour
{
    [Tooltip("Assign the AudioSource to play when the player enters this trigger.")]
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
            if (audioSource == null)
            {
                Debug.LogWarning("AudioSource not assigned in StartSound script.", this);
                return;
            }
            if (!audioSource.isPlaying)
            {
                if (audioSource.time > 0f)
                    audioSource.UnPause();
                else
                    audioSource.Play();
            }
        }
    }
}