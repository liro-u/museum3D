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

    private const string EnterGPTag = "GuyonProvisoire";
    private const string EnterMontSaintMichelTag = "Mont";
    private const string ExitTag = "Exit";

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
        
        
        int layerMask = 1 << 7;
        // Does the ray intersect any objects excluding the player layer
        if (Physics.Raycast(transform.position, transform.TransformDirection(Vector3.forward), out RaycastHit hit, 5, layerMask))
        {
            if (!isText)
            {
                text.SetText("Appuyez sur 'F' pour afficher l'élément en grand écran");
                isText = true;
            }
            
            if (Input.GetKeyDown(KeyCode.F))
            {
                StartCoroutine(ClearTextDelayed(text));
                ToggleMedia(hit, text);
                isText = false;
            }

            if (hit.collider.CompareTag(EnterMontSaintMichelTag))
            {
                text.SetText("Approchez vous de la porte et appuyez sur O pour terminer votre jeu au mont Saint Michel");
                isText = true;
            }

            if (hit.collider.CompareTag(ExitTag))
            {
                text.SetText("Traversez cette porte pour aller dans la zone 2, vous ne pourez plus revenir en arrière");
                isText = true;
            }

            if (hit.collider.CompareTag(EnterGPTag))
            {
                text.SetText("Vous êtes dans la zone 1, vous ne pourez plus revenir en arrière à la Roche Guyon");
                isText = true;
            }
            //Debug.Log("Did Hit");
        }
         else
        {
            

            if (Input.GetKeyDown(KeyCode.F))
            {
                if ((isPictureActive && !isVideoActive) || text.text == "Appuyez sur 'F' pour fermer l'élément")
                {
                    picture.SetActive(false);
                    isPictureActive = false;
                }
                if (!isPictureActive && isVideoActive)
                {
                    video.SetActive(false);
                    //isPictureActive = false;
                    isVideoActive = false;
                }
            }

            if (isText && (isPictureActive || isVideoActive))
            {
                text.text = "Appuyez sur 'F' pour fermer l'élément";
                //isText = false;
            } else
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
        text.SetText("Appuyez sur 'F' pour fermer l'élément");
    }

    IEnumerator FadeIn(GameObject mediaObject, float duration)
    {
        CanvasGroup canvasGroup = mediaObject.GetComponent<CanvasGroup>();
        if (canvasGroup == null)
        {
            canvasGroup = mediaObject.AddComponent<CanvasGroup>();
        }
        canvasGroup.alpha = 0f;
        while (canvasGroup.alpha < 1)
        {
            canvasGroup.alpha += Time.deltaTime / duration;
            yield return null;
        }
        canvasGroup.alpha = 1;
    }

    void ToggleMedia(RaycastHit hit, TextMeshProUGUI text)
    {
        if (!isPictureActive && !isVideoActive)
        {
            if (hit.collider.CompareTag("Chartres") || hit.collider.CompareTag("video"))
            {
                video.SetActive(true);
                isVideoActive = true;
                StartCoroutine(FadeIn(video, 2f));
            }
            else
            {
                picture.SetActive(true);
                isPictureActive = true;
                pictureTexture = GetTexture(hit.collider.gameObject);
                SetTexture(pictureTexture);
                StartCoroutine(FadeIn(picture, 2f));
            }
        } else if((isPictureActive && !isVideoActive))
        {
            picture.SetActive(false);
            isPictureActive = false;
        }
        else if ((!isPictureActive && isVideoActive))
        {
            video.SetActive(false);
            //isPictureActive = false;
            isVideoActive = false;
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