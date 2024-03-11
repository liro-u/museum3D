using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class MessageManager : MonoBehaviour
{
    [SerializeField] private TextMeshProUGUI textMeshPro;
    [SerializeField] private Canvas canvas;

    public void ChangeMessage(string message)
    {
        textMeshPro.text = message;
    }
    public void DesenableCanvas()
    {
        canvas.enabled = false;
    }
    public void EnableCanvas()
    {
        canvas.enabled = true;
    }
}
