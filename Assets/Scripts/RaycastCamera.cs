using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;

public class RaycastCamera : MonoBehaviour
{
    [SerializeField] private GameObject picture;
    [SerializeField] private GameObject textObject;
    private bool isText = true;
    private Texture pictureTexture;

    // Start is called before the first frame update
    void Start()
    {
        TextMeshProUGUI text = textObject.GetComponent<TextMeshProUGUI>();

        if (picture.activeInHierarchy)
        {
            picture.SetActive(false);
        }
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

        if (Input.GetKeyUp(KeyCode.F) && picture.activeInHierarchy)
        {
            picture.SetActive(false);
        }

        int layerMask = 1 << 7;
        // Does the ray intersect any objects excluding the player layer
        if (Physics.Raycast(transform.position, transform.TransformDirection(Vector3.forward), out RaycastHit hit, 5, layerMask))
        {
            if (!isText && !picture.activeInHierarchy)
            {
                text.SetText("Restez appuyé sur 'F' pour afficher l'image en grand écran");
                isText = true;
            }

            if (Input.GetKeyDown(KeyCode.F) && !picture.activeInHierarchy)
            {
                picture.SetActive(true);
                pictureTexture = GetTexture(hit.collider.gameObject);
                SetTexture(pictureTexture);
                text.SetText("");
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

    Texture GetTexture(GameObject hit)
    {
        Material texture = hit.GetComponent<HG.DeferredDecals.Decal>().DecalMaterial;

        return texture.mainTexture;
    }

    void SetTexture(Texture texture)
    {
        float aspectRatio = (float)texture.width / (float)texture.height;
        Debug.Log(texture.height);
        picture.GetComponent<AspectRatioFitter>().aspectRatio = aspectRatio;
        picture.GetComponent<RawImage>().texture = texture;
    }
}
