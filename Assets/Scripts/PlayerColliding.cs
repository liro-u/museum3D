using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;

public class PlayerColliding : MonoBehaviour
{
    private const string ExitTag = "Exit";

    private const string Enter1Tag = "Enter1";
    private const string EnterMontSaintMichelTag = "Mont";

    private GameManager _gameManager;

    private bool canOpenURL = false;
    string url1 = "https://www.timographie360.fr/visites/visite-virtuelle/CMN/mont-saint-michel/?fbclid=IwAR2iypzYLU5_U4iuZESqf43Q1oWH47nn3OW0hdQ4TlJcadeTX2MWmJZcQVM";

    private void Awake()
    {

    }

    private void Start()
    {
        _gameManager = GameManager.Instance;
    }

    private void Update()
    {
        if (canOpenURL && Input.GetKeyDown(KeyCode.O))
        {
            Application.OpenURL(url1);
            _gameManager.Won();
        }
    }

    public void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag(ExitTag))
        {
            _gameManager.Door1();
        }

        if (collision.gameObject.CompareTag(Enter1Tag))
        {
            _gameManager.Enter1();
        }

        if (collision.gameObject.CompareTag(EnterMontSaintMichelTag))
        {
            canOpenURL = true;
        }
    }

    public void OnCollisionExit(Collision collision)
    {
        if (collision.gameObject.CompareTag(EnterMontSaintMichelTag))
        {
            canOpenURL = false;
        }
    }
}
