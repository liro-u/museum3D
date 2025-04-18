using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using HG.DeferredDecals;
using UnityEngine;
using TMPro;
using UnityEngine.Rendering.Universal;
using UnityEngine.UI;

public class RaycastCamera : MonoBehaviour
{
    [SerializeField] private GameObject picture;
    [SerializeField] private GameObject video;
    [SerializeField] private GameObject textObject;
    [SerializeField] private AudioSource audioSource;
    private bool isPictureActive = false;
    private bool isVideoActive = false;
    private bool isText = true;
    private Texture pictureTexture;
    private const string EnterChartresTag = "Chartres";
    private const string EnterIgnoreTag = "ingore";
    private const string EnterGpTag = "GuyonProvisoire";
    private const string EnterMontSaintMichelTag = "Mont";
    private const string ExitTag = "Exit";

    private string currentText = "";

    private Dictionary<string, string> textureTitleMapping = new Dictionary<string, string>();
    private Dictionary<string, string> idPathMapping = new Dictionary<string, string>();

    [SerializeField] private float moveDuration = 3f;
    private Dictionary<Transform, Vector3> initialPositions = new Dictionary<Transform, Vector3>();
    private Decal currentActiveDecal = null;
    private bool isAnimating = false;

    void Start()
    {
        LoadCSV();
        TextMeshProUGUI text = textObject.GetComponent<TextMeshProUGUI>();
        video.SetActive(false);
        if (isText)
        {
            text.SetText("");
            isText = false;
        }
    }

    void Update()
    {
        if (isAnimating) return;

        TextMeshProUGUI text = textObject.GetComponent<TextMeshProUGUI>();
        int layerMask = 1 << 7;

        if (Physics.Raycast(transform.position, transform.TransformDirection(Vector3.forward), out RaycastHit hit, 5, layerMask))
        {
            float distanceThreshold = 2.0f;
            float distanceToHit = Vector3.Distance(transform.position, hit.point);

            if (distanceToHit < distanceThreshold)
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
            else if (hit.collider.CompareTag(EnterGpTag))
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
            if (isPictureActive)
            {
                isPictureActive = false;
                if (currentActiveDecal != null)
                {
                    StartCoroutine(AnimateWallMovement(currentActiveDecal, false));
                    currentActiveDecal = null;
                }
            }
            if (isVideoActive)
            {
                video.SetActive(false);
                isVideoActive = false;
            }
            if (currentText != "")
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
                    SetTexture(pictureTexture, hit.collider.gameObject);

                    Decal decal = hit.collider.GetComponent<Decal>();
                    if (decal != null && currentActiveDecal != decal)
                    {
                        currentActiveDecal = decal;
                        StartCoroutine(AnimateWallMovement(decal, true));
                    }
                }
            }
        }
    }

    Texture GetTexture(GameObject hit)
    {
        var decalComponent = hit.GetComponent<DecalProjector>();
        if (decalComponent == null || decalComponent.material == null || decalComponent.material.mainTexture == null)
        {
            Debug.LogWarning("Composant ou texture decal introuvable !");
            return null;
        }
        return decalComponent.material.mainTexture;
    }

    void SetTexture(Texture texture, GameObject go)
    {
        Decal decal = go.GetComponent<Decal>();
        if (decal == null || texture == null) return;

        Transform pictureTransform = decal.transform.Find("picture");
        if (pictureTransform == null) return;

        Renderer pictureRenderer = pictureTransform.GetComponent<Renderer>();
        if (pictureRenderer == null) return;

        pictureRenderer.material.mainTexture = texture;
        pictureRenderer.material.mainTextureScale = new Vector2(-1, -1);
    }

    IEnumerator FadeIn(GameObject mediaObject, float duration)
    {
        CanvasGroup canvasGroup = mediaObject.GetComponent<CanvasGroup>() ?? mediaObject.AddComponent<CanvasGroup>();
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
        TextAsset csvFile = Resources.Load<TextAsset>("data-updated");
        if (csvFile == null) return;

        string[] lines = csvFile.text.Split('\n');
        foreach (string line in lines)
        {
            string[] parts = line.Split(';');
            if (parts.Length >= 2)
            {
                string id = parts[0].Trim();
                string title = parts[1].Trim();
                string path = parts[3].Trim();

                if (!textureTitleMapping.ContainsKey(id))
                    textureTitleMapping.Add(id, title);

                if (!idPathMapping.ContainsKey(id))
                {
                    string fullPathJpg = Path.Combine(path, id + ".jpg").Replace("\\", "/");
                    string fullPathJpeg = Path.Combine(path, id + ".jpeg").Replace("\\", "/");

                    if (File.Exists(fullPathJpg))
                        idPathMapping.Add(id, fullPathJpg);
                    else if (File.Exists(fullPathJpeg))
                        idPathMapping.Add(id, fullPathJpeg);
                }
            }
        }
    }

    private IEnumerator AnimateWallMovement(Decal decal, bool moveForward)
    {
        isAnimating = true;

        DecalProjector projector = decal.GetComponent<DecalProjector>();
        if (projector != null && !moveForward)
            projector.enabled = true;

        Transform[] children = new[] {
            decal.transform.Find("picture"),
            decal.transform.Find("downWall"),
            decal.transform.Find("upWall"),
            decal.transform.Find("leftWall"),
            decal.transform.Find("rightWall")
        };

        foreach (var child in children)
        {
            if (child == null)
            {
                isAnimating = false;
                yield break;
            }
            if (!initialPositions.ContainsKey(child))
                initialPositions[child] = child.localPosition;
        }

        float offset = 0.4f * decal.transform.localScale.z;
        Vector3[] startPositions = new Vector3[children.Length];
        Vector3[] endPositions = new Vector3[children.Length];

        for (int i = 0; i < children.Length; i++)
        {
            startPositions[i] = children[i].localPosition;
            endPositions[i] = moveForward ? startPositions[i] + new Vector3(0, 0, -offset) : initialPositions[children[i]];
        }

        float elapsed = 0f;
        audioSource.Play();
        while (elapsed < moveDuration)
        {
            elapsed += Time.deltaTime;
            float t = Mathf.Clamp01(elapsed / moveDuration);
            for (int i = 0; i < children.Length; i++)
            {
                children[i].localPosition = Vector3.Lerp(startPositions[i], endPositions[i], t);
            }
            yield return null;
        }

        for (int i = 0; i < children.Length; i++)
            children[i].localPosition = endPositions[i];

        if (projector != null && moveForward)
            projector.enabled = false;

        isAnimating = false;
    }
}
