using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEditor;
using HG.DeferredDecals;

public class DecalAutoFixer : MonoBehaviour
{
    [MenuItem("Outils/Fixer Orientation Decals")]
    public static void FixDecalOrientation()
    {
        GameObject[] taggedObjects = GameObject.FindGameObjectsWithTag("DeferredDecal");

        if (taggedObjects.Length == 0)
        {
            Debug.LogError("Aucun GameObject avec le tag 'DeferredDecal' trouvé !");
            return;
        }

        Undo.RegisterCompleteObjectUndo(taggedObjects, "Fix Decal Orientation");

        foreach (GameObject obj in taggedObjects)
        {
            if (!obj.activeInHierarchy)
                continue;

            DecalProjector decalProjector = obj.GetComponent<DecalProjector>();
            Decal deferredDecal = obj.GetComponent<Decal>();

            Material material = null;

            if (decalProjector != null)
                material = decalProjector.material;
            else if (deferredDecal != null)
                material = deferredDecal.DecalMaterial;

            if (material == null || material.mainTexture == null)
                continue;

            Texture texture = material.mainTexture;
            int width = texture.width;
            int height = texture.height;
            bool isLandscape = width > height;

            // Réinitialiser la rotation
            Undo.RecordObject(obj.transform, "Reset Decal Rotation");
            obj.transform.localRotation = Quaternion.identity;

            // Ajuster l'échelle uniquement si le decal est en portrait
            if (!isLandscape)
            {
                Vector3 scale = obj.transform.localScale;
                obj.transform.localScale = new Vector3(scale.y, scale.x, scale.z);
            }

            // Ajuster la texture du decal si nécessaire
            if (decalProjector != null)
            {
                Undo.RecordObject(decalProjector, "Adjust Decal Texture");
                Vector2 tiling = decalProjector.uvScale;
                Vector2 offset = decalProjector.uvBias;

                if (!isLandscape)
                {
                    decalProjector.uvScale = new Vector2(tiling.y, tiling.x);
                    decalProjector.uvBias = new Vector2(offset.y, offset.x);
                }
            }

            Debug.Log($"Fixé : {obj.name} -> {(isLandscape ? "Paysage" : "Portrait")}");
        }

        Debug.Log("Correction des orientations des decals terminée !");
    }
}
