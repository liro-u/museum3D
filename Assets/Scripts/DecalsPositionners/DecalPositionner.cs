/*using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEditor;

[RequireComponent(typeof(DecalProjector))]
[ExecuteInEditMode]
public class DecalPositionner : MonoBehaviour
{
    public float pixelsPerUnit = 100f;
    public float scaleFactor = 1f;
    public float depth = 1f;
    public bool autoAlignToSurface = true;

    private DecalProjector decalProjector;

    void Awake()
    {
        decalProjector = GetComponent<DecalProjector>();
        ApplyDecalScale();
    }

    void ApplyDecalScale()
    {
        if (decalProjector == null || decalProjector.material == null) return;

        Texture2D decalTexture = decalProjector.material.mainTexture as Texture2D;
        if (decalTexture == null) return;

        float width = decalTexture.width;
        float height = decalTexture.height;

        float scaleX = (width / pixelsPerUnit) * scaleFactor;
        float scaleY = (height / pixelsPerUnit) * scaleFactor;
        float scaleZ = depth;

        transform.localScale = new Vector3(scaleX, scaleY, scaleZ);

        /*if (autoAlignToSurface)
        {
            AlignRotationOnlyOnY();
        }*/

        /*Debug.Log($"✅ Decal ajusté : Scale = ({scaleX}, {scaleY}, {scaleZ}), Rotation Y SEULEMENT modifiée !");
    }

    void AlignRotationOnlyOnY()
    {
        RaycastHit hit;
        if (Physics.Raycast(transform.position, -transform.forward, out hit, 5f))
        {
            // Obtenir la rotation actuelle
            Vector3 currentRotation = transform.eulerAngles;

            // Récupérer uniquement la rotation Y correcte
            float targetY = Quaternion.LookRotation(-hit.normal, Vector3.up).eulerAngles.y;

            // Appliquer la rotation uniquement sur Y, garder X et Z intacts
            transform.rotation = Quaternion.Euler(currentRotation.x, targetY, currentRotation.z);

            Debug.Log($"🔄 Rotation Y ajustée : {targetY}° (Z reste localement vers l'arrière)");
        }
        else
        {
            Debug.LogWarning("⚠️ Aucune surface détectée derrière le decal !");
        }
    }

    void OnValidate()
    {
        if (decalProjector == null) decalProjector = GetComponent<DecalProjector>();

        if (PrefabUtility.IsPartOfPrefabAsset(gameObject))
        {
            Debug.Log("🏗️ Modification du Prefab !");
            ApplyDecalScale();
            return;
        }

        if (PrefabUtility.IsPartOfPrefabInstance(gameObject))
        {
            Debug.Log("🔄 Mise à jour de l'instance du Prefab dans la scène !");
            ApplyDecalScale();
            PrefabUtility.ApplyPrefabInstance(gameObject, InteractionMode.UserAction);
        }
        else
        {
            ApplyDecalScale();
        }
    }
}*/
