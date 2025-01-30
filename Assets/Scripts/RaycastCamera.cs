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
    private const string EnterIgnoreTag = "ingore";
    private const string EnterGPTag = "GuyonProvisoire";
    private const string EnterMontSaintMichelTag = "Mont";
    private const string ExitTag = "Exit";

    private string currentText = "";

    private Dictionary<string, string> textureTitleMapping = new Dictionary<string, string>();

    // Start is called before the first frame update
    void Start()
    {
        LoadCSV();
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
        if (Physics.Raycast(transform.position, transform.TransformDirection(Vector3.forward), out RaycastHit hit, 5, layerMask))
        {
            if (!isText && currentText == "")
            {
                currentText = "Appuyez sur 'F' pour afficher l'élément en grand écran";
                text.SetText(currentText);
                isText = true;
            }

            if (Input.GetKeyDown(KeyCode.F))
            {
                ToggleMedia(hit, text);
            }

            if (hit.collider.CompareTag(EnterMontSaintMichelTag))
            {
                SetText(text, "Approchez vous de la porte et appuyez sur O pour terminer votre jeu au mont Saint Michel");
            }
            else if (hit.collider.CompareTag(ExitTag))
            {
                SetText(text, "Traversez cette porte pour aller dans la zone 2, vous ne pourrez plus revenir en arrière");
            }
            else if (hit.collider.CompareTag(EnterGPTag))
            {
                SetText(text, "Vous êtes dans la zone 1, vous ne pourrez plus revenir en arrière à la Roche Guyon");
            }
            else if (hit.collider.CompareTag(EnterIgnoreTag))
            {
                SetText(text, "Vous êtes dans la zone 2, vous ne pourrez plus revenir à la zone 1, allez tout droit pour aller au Mont Saint Michel");
            }
        }
        else
        {
            if (Input.GetKeyDown(KeyCode.F))
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
                currentText = "";
                text.SetText("");
            }

            if (!isPictureActive && !isVideoActive && currentText != "")
            {
                currentText = "";
                text.SetText("");
            }
        }
    }

    void SetText(TextMeshProUGUI text, string newText)
    {
        if (currentText != newText)
        {
            currentText = newText;
            text.SetText(currentText);
        }
    }

    void ToggleMedia(RaycastHit hit, TextMeshProUGUI text)
    {
        Debug.Log("ToggleMedia appelé");

        if (!isPictureActive && !isVideoActive)
        {
            if (hit.collider.CompareTag("Chartres") || hit.collider.CompareTag("video"))
            {
                video.SetActive(true);
                isVideoActive = true;
                StartCoroutine(FadeIn(video, 2f));
                SetText(text, "Vidéo affichée");
            }
            else
            {
                picture.SetActive(true);
                isPictureActive = true;
                pictureTexture = GetTexture(hit.collider.gameObject);

                if (pictureTexture != null)
                {
                    string textureName = pictureTexture.name;
                    if (textureTitleMapping.TryGetValue(textureName, out string artworkTitle))
                    {
                        SetText(text, $"{artworkTitle}");
                    }
                    else
                    {
                        SetText(text, $"Titre de l'\u0153uvre : {textureName} (titre non trouvé)");
                    }
                    SetTexture(pictureTexture);
                    StartCoroutine(FadeIn(picture, 2f));
                }
                else
                {
                    Debug.LogWarning("La texture est nulle, rien à afficher.");
                }
            }
        }
        else if (isPictureActive)
        {
            picture.SetActive(false);
            isPictureActive = false;
            currentText = "";
            text.SetText("");
        }
        else if (isVideoActive)
        {
            video.SetActive(false);
            isVideoActive = false;
            currentText = "";
            text.SetText("");
        }
    }

    Texture GetTexture(GameObject hit)
    {
        var decalComponent = hit.GetComponent<HG.DeferredDecals.Decal>();
        if (decalComponent == null)
        {
            Debug.LogWarning("Composant Decal introuvable sur l'objet touché !");
            return null;
        }

        Material texture = decalComponent.DecalMaterial;
        if (texture == null || texture.mainTexture == null)
        {
            Debug.LogWarning("Aucune texture principale trouvée sur le matériau !");
            return null;
        }

        Debug.Log($"Texture trouvée : {texture.mainTexture.name}");
        return texture.mainTexture;
    }

    void SetTexture(Texture texture)
    {
        if (texture == null)
        {
            Debug.LogError("La texture fournie à SetTexture est nulle !");
            return;
        }

        float aspectRatio = (float)texture.width / (float)texture.height;
        picture.GetComponent<AspectRatioFitter>().aspectRatio = aspectRatio;
        picture.GetComponent<RawImage>().texture = texture;

        Debug.Log($"Texture appliquée : {texture.name}");
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

    private void LoadCSV()
    {
        //TextAsset csvFile = Resources.Load<TextAsset>("data-csv-virgule"); // Assurez-vous que le fichier est dans le dossier "Resources"
        TextAsset csvFile = Resources.Load<TextAsset>("data-updated");
        if (csvFile == null)
        {
            Debug.LogError("Fichier CSV introuvable !");
            return;
        }

        string[] lines = csvFile.text.Split('\n');
        foreach (string line in lines)
        {
            string[] parts = line.Split(';');
            if (parts.Length >= 2)
            {
                string id = parts[0].Trim();
                string title = parts[1].Trim();
                if (!textureTitleMapping.ContainsKey(id))
                {
                    textureTitleMapping.Add(id, title);
                }
            }
        }
    }
}
