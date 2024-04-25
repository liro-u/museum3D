using System;
using UnityEngine;
using UnityEngine.SceneManagement;
using System.Collections;


public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }
    private int sceneNumber = 0; // Scene number tracking
    [SerializeField] private AudioSource soundDeath;
    [SerializeField] private Transform playerTransform;
    [SerializeField] public Transform canvas;

    // To remember player's last position in each scene
    private Vector3 newPosition = new Vector3(1.0f, 1.0f, 1.0f); // Assuming a maximum of 10 scenes for example

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);

            if (playerTransform != null)
            {
                DontDestroyOnLoad(playerTransform.gameObject);
            }
            else
            {
                Debug.LogWarning("Player Transform is not set in GameManager.");
            }

            if (canvas != null)
            {
                DontDestroyOnLoad(canvas.gameObject);
                /*for (int i = 0; i <= 4; i++){
                    canvas.transform.GetChild(i).gameObject.SetActive(false);
                }*/
            }
            else
            {
                Debug.LogWarning("Canvas is not set in GameManager.");
            }
        }
        else
        {
            if (Instance != this)
            {
                Debug.LogWarning("Another instance of GameManager was found and destroyed.");
                Destroy(gameObject);
            }
        }
    }

    public void setActive(int set)
    {
        if (canvas != null && set >= 0 && set < canvas.transform.childCount)
        {
            canvas.transform.GetChild(set).gameObject.SetActive(true);
        }
    }

    public void Won()
    {
        SceneManager.LoadScene(3);
    }

    public void Door1()
    {
        if (playerTransform != null) {
            newPosition = (sceneNumber == 0) ? new Vector3(116.06f, -17.95f, 95.74f) : new Vector3(-2.3f, 1.0f, 2.3f);
            playerTransform.gameObject.SetActive(false);
            canvas.gameObject.SetActive(false);
        }

        // Toggle between scene 0 and 1
        sceneNumber = (sceneNumber == 0) ? 1 : 0;
        SceneManager.LoadScene(1);
    }

    public void Enter1()
    {
        if (playerTransform != null) {
            playerTransform.position = newPosition;
            playerTransform.gameObject.SetActive(true);
            canvas.gameObject.SetActive(true);
            Debug.Log("Player position after scene load: " + playerTransform.position);
        }

        

        if(sceneNumber == 1)
        {
            SceneManager.LoadScene(2);
        } /*else if (sceneNumber == 2)
        {
            SceneManager.LoadScene(5);
        }*/
    }

}
