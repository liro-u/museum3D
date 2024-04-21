using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;

public class RaycastCamera : MonoBehaviour
{
    [SerializeField] private GameObject picture;
    [SerializeField] private GameObject video;
    [SerializeField] private GameObject textObject;
    private bool isPictureActive = false;
    private bool isVideoActive = false;
    private bool isText = true;
    private Texture pictureTexture;
    private const string EnterChartresTag = "Chartres";

    // Start is called before the first frame update
    void Start()
    {
        TextMeshProUGUI text = textObject.GetComponent<TextMeshProUGUI>();
        picture.SetActive(false);
        video.SetActive(false);
        if (isText)
        {
            text.SetText("");
            isText = false;
        }
    }

    // Update is called once per frame
    void Update()
    {
        TextMeshProUGUI text = textObject.GetComponent<TextMeshProUGUI>();
        
        if (Input.GetKeyUp(KeyCode.F))
        {
            if (isPictureActive)
            {
                picture.SetActive(false);
                isPictureActive = false;
            }
            if (isVideoActive)
            {
                video.SetActive(false);
                isVideoActive = false;
            }
        }
        int layerMask = 1 << 7;
        // Does the ray intersect any objects excluding the player layer
        if (Physics.Raycast(transform.position, transform.TransformDirection(Vector3.forward), out RaycastHit hit, 5, layerMask))
        {
            if (!isText)
            {
                text.SetText("Restez appuyé sur 'F' pour afficher l'élément en grand écran");
                isText = true;
            }

            if (Input.GetKeyDown(KeyCode.F))
            {
                StartCoroutine(ClearTextDelayed(text));
                ToggleMedia(hit);
                isText = false;
            }
            //Debug.Log("Did Hit");
        }
         else
        {
            if (isText)
            {
                text.text = "";
                isText = false;
            }
            //Debug.Log("Did not Hit");
        }
    }

    IEnumerator ClearTextDelayed(TextMeshProUGUI text)
    {
        yield return null; // Wait for the next frame
        text.SetText(""); // Clear the text
    }

    void ToggleMedia(RaycastHit hit)
    {
        if (!isPictureActive)
        {
            if (hit.collider.CompareTag("Chartres"))
            {
                video.SetActive(true);
                isVideoActive = true;
            }
            else
            {
                picture.SetActive(true);
                isPictureActive = true;
                pictureTexture = GetTexture(hit.collider.gameObject);
                SetTexture(pictureTexture);
            }
        }
        else if (!isVideoActive)
        {
            video.SetActive(true);
            isPictureActive = false;
            isVideoActive = true;
        }
    }


    Texture GetTexture(GameObject hit)
    {
        Material texture = hit.GetComponent<HG.DeferredDecals.Decal>().DecalMaterial;
        return texture.mainTexture;
    }

    void SetTexture(Texture texture)
    {
        float aspectRatio = (float)texture.width / (float)texture.height;
        picture.GetComponent<AspectRatioFitter>().aspectRatio = aspectRatio;
        picture.GetComponent<RawImage>().texture = texture;
    }
}