using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Message : MonoBehaviour
{
    [SerializeField] string message;
    private MessageManager messageManager;
    // Start is called before the first frame update

    private void Awake()
    {
        messageManager = GameObject.Find("Message Manager").GetComponent<MessageManager>();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            messageManager.EnableCanvas();
            messageManager.ChangeMessage(message);
        }
    }
    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            messageManager.DesenableCanvas();
        }
    }
}
