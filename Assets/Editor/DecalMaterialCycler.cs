using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEditor;
using System.Collections.Generic;
using HG.DeferredDecals; // Import du namespace pour Decal

public class DecalMaterialCycler : MonoBehaviour
{
    private static string materialFolderPath = "Assets/Tableaux/zones/PEINTURES DIVERSES- Grotte 32";

    [MenuItem("Outils/Distribuer Matériaux (Cyclique)")]
    public static void AssignMaterialsToDecals()
    {
        // Charger les matériaux depuis le dossier spécifié
        string[] materialGuids = AssetDatabase.FindAssets("t:Material", new[] { materialFolderPath });
        List<Material> materials = new List<Material>();

        foreach (string guid in materialGuids)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            Material mat = AssetDatabase.LoadAssetAtPath<Material>(path);
            if (mat != null)
                materials.Add(mat);
        }

        if (materials.Count == 0)
        {
            Debug.LogError($"Aucun matériau trouvé dans {materialFolderPath}");
            return;
        }

        // Trouver tous les objets activés ayant le tag "DeferredDecal"
        GameObject[] taggedObjects = GameObject.FindGameObjectsWithTag("DeferredDecal");

        if (taggedObjects.Length == 0)
        {
            Debug.LogError("Aucun GameObject avec le tag 'DeferredDecal' trouvé !");
            return;
        }

        Undo.RegisterCompleteObjectUndo(taggedObjects, "Assign Materials to Tagged Decals");

        int index = 0;

        foreach (GameObject obj in taggedObjects)
        {
            if (!obj.activeInHierarchy) // Ignorer les objets désactivés
                continue;

            DecalProjector decalProjector = obj.GetComponent<DecalProjector>();
            Decal deferredDecal = obj.GetComponent<Decal>();

            if (decalProjector == null && deferredDecal == null)
                continue; // Ignorer si aucun des composants n'est présent

            Material selectedMaterial = materials[index % materials.Count];
            index++;

            // Appliquer le matériau à l'URP Decal Projector s'il est présent
            if (decalProjector != null)
            {
                Undo.RecordObject(decalProjector, "Assign Material to URP Decal");
                decalProjector.material = selectedMaterial;
            }

            // Appliquer le matériau au Deferred Decal (HG.DeferredDecals) s'il est présent
            if (deferredDecal != null)
            {
                Undo.RecordObject(deferredDecal, "Assign Material to Deferred Decal");
                deferredDecal.SetMaterial(selectedMaterial);
            }

            Debug.Log($"Matériau '{selectedMaterial.name}' appliqué à {obj.name}");
        }

        Debug.Log("Distribution cyclique des matériaux terminée !");
    }
}
