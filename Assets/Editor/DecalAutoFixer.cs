using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEditor;
using HG.DeferredDecals;

public class DecalAutoFixer : MonoBehaviour
{
    [MenuItem("Outils/Fixer Orientation Decals")]
    public static void FixDecalOrientation()
    {
        GameObject[] taggedObjects = GameObject.FindGameObjectsWithTag("DecalTest2");

        if (taggedObjects.Length == 0)
        {
            Debug.LogError("Aucun GameObject avec le tag 'DecalTest' trouvé !");
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
            float ratio = (float)height / width;

            bool isPortrait = height > width;

            Undo.RecordObject(obj.transform, "Fix Decal Transform");
            obj.transform.localRotation = Quaternion.identity;

            if (isPortrait)
                obj.transform.Rotate(Vector3.forward, 90f);

            if (decalProjector != null)
            {
                Undo.RecordObject(decalProjector, "Adjust UV");

                Vector2 tiling = decalProjector.uvScale;
                Vector2 offset = decalProjector.uvBias;

                if (isPortrait)
                {
                    decalProjector.uvScale = new Vector2(tiling.y, tiling.x);
                    decalProjector.uvBias = new Vector2(offset.y, offset.x);
                }

                Vector3 size = decalProjector.size;
                float baseSize = Mathf.Max(size.x, size.y);
                decalProjector.size = new Vector3(baseSize, baseSize * ratio, size.z);
            }
            else
            {
                Vector3 scale = obj.transform.localScale;
                float baseSize = Mathf.Max(scale.x, scale.y);
                obj.transform.localScale = new Vector3(baseSize, baseSize * ratio, scale.z);
            }

            Debug.Log($"Fixé : {obj.name} → {(isPortrait ? "portrait" : "paysage")} | Ratio: {ratio:F2}");
        }

        Debug.Log("Correction automatique des decals terminée !");
    }
}
