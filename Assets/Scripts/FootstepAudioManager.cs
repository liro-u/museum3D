using UnityEngine;
using System.Collections;

public class FootstepAudioManager : MonoBehaviour
{
    [Tooltip("Minimum pitch variation for footsteps")]
    [Range(0.5f, 2f)]
    public float pitchMin = 0.9f;
    [Tooltip("Maximum pitch variation for footsteps")]
    [Range(0.5f, 2f)]
    public float pitchMax = 1.1f;

    [Tooltip("Threshold speed above which footsteps play (horizontal movement)")]
    [SerializeField] private float movementThreshold = 0.02f;
    [SerializeField] private float stepInterval = 0.6f;

    [Tooltip("Assign footstep AudioSources for different surfaces")]
    [SerializeField] private AudioSource grassSteps;
    [SerializeField] private AudioSource stoneSteps;
    [SerializeField] private AudioSource cathedralSteps;

    private AudioSource currentSteps;
    private CharacterController controller;

    private Vector3 previousPosition;
    private bool isMoving = false;

    private void Start()
    {
        controller = GetComponent<CharacterController>();
        currentSteps = grassSteps; // default
        StartCoroutine(PlayFootsteps());
    }

    private void Update()
    {
        // Calculate horizontal movement since last frame
        Vector3 currentPosition = transform.position;
        Vector3 horizontalDelta = new Vector3(
            currentPosition.x - previousPosition.x,
            0f,
            currentPosition.z - previousPosition.z
        );

        isMoving = horizontalDelta.magnitude > movementThreshold && controller.isGrounded;

        previousPosition = currentPosition;
    }

    private IEnumerator PlayFootsteps()
    {
        while (true)
        {
            if (isMoving && currentSteps != null)
            {
                currentSteps.pitch = Random.Range(pitchMin, pitchMax);
                currentSteps.Play();
            }
            yield return new WaitForSeconds(stepInterval);
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        switch (other.tag)
        {
            case "GrassSurface":
                currentSteps = grassSteps;
                break;
            case "StoneSurface":
                currentSteps = stoneSteps;
                break;
            case "CathedralSurface":
                currentSteps = cathedralSteps;
                break;
        }
    }
}