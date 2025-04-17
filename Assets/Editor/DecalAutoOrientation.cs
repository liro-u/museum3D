using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEditor;
using System.Collections.Generic;
using HG.DeferredDecals;

public class DecalAutoOrientation : MonoBehaviour
{
    [MenuItem("Outils/Auto-Orienter Decals")]
    public static void AutoOrientDecals()
    {
        GameObject[] taggedObjects = GameObject.FindGameObjectsWithTag("DecalTest2");

        if (taggedObjects.Length == 0)
        {
            Debug.LogError("Aucun GameObject avec le tag 'DeferredDecal' trouvé !");
            return;
        }

        Undo.RegisterCompleteObjectUndo(taggedObjects, "Auto-Orient Decals");

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

            // Rotation du Decal
            Undo.RecordObject(obj.transform, "Rotate Decal");
            obj.transform.rotation = Quaternion.Euler(0, 0, isLandscape ? 0 : 90);

            // Correction du tiling et offset pour remettre la texture dans le bon sens
            if (decalProjector != null)
            {
                Undo.RecordObject(decalProjector, "Adjust Decal Texture");
                Vector2 tiling = decalProjector.uvScale;
                Vector2 offset = decalProjector.uvBias;

                if (!isLandscape)
                {
                    decalProjector.uvScale = new Vector2(tiling.y, tiling.x); // Inverser X et Y
                    decalProjector.uvBias = new Vector2(offset.y, offset.x); // Corriger l'offset
                }
            }

            Debug.Log($"Decal '{obj.name}' orienté en {(isLandscape ? "paysage" : "portrait")} avec correction.");
        }

        Debug.Log("Auto-orientation et correction des textures terminées !");
    }
}
