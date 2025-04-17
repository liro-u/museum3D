using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEditor;
using System.Collections.Generic;
using HG.DeferredDecals; // Import du namespace pour Decal

public class DecalMaterialCycler : MonoBehaviour
{
    private static string materialFolderPath = "Assets/Tableaux/zones/PEINTURES DIVERSES- Grotte 32";

    [MenuItem("Outils/Distribuer Mat�riaux (Cyclique)")]
    public static void AssignMaterialsToDecals()
    {
        // Charger les mat�riaux depuis le dossier sp�cifi�
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
            Debug.LogError($"Aucun mat�riau trouv� dans {materialFolderPath}");
            return;
        }

        // Trouver tous les objets activ�s ayant le tag "DeferredDecal"
        GameObject[] taggedObjects = GameObject.FindGameObjectsWithTag("DeferredDecal");

        if (taggedObjects.Length == 0)
        {
            Debug.LogError("Aucun GameObject avec le tag 'DeferredDecal' trouv� !");
            return;
        }

        Undo.RegisterCompleteObjectUndo(taggedObjects, "Assign Materials to Tagged Decals");

        int index = 0;

        foreach (GameObject obj in taggedObjects)
        {
            if (!obj.activeInHierarchy) // Ignorer les objets d�sactiv�s
                continue;

            DecalProjector decalProjector = obj.GetComponent<DecalProjector>();
            Decal deferredDecal = obj.GetComponent<Decal>();

            if (decalProjector == null && deferredDecal == null)
                continue; // Ignorer si aucun des composants n'est pr�sent

            Material selectedMaterial = materials[index % materials.Count];
            index++;

            // Appliquer le mat�riau � l'URP Decal Projector s'il est pr�sent
            if (decalProjector != null)
            {
                Undo.RecordObject(decalProjector, "Assign Material to URP Decal");
                decalProjector.material = selectedMaterial;
            }

            // Appliquer le mat�riau au Deferred Decal (HG.DeferredDecals) s'il est pr�sent
            if (deferredDecal != null)
            {
                Undo.RecordObject(deferredDecal, "Assign Material to Deferred Decal");
                deferredDecal.SetMaterial(selectedMaterial);
            }

            Debug.Log($"Mat�riau '{selectedMaterial.name}' appliqu� � {obj.name}");
        }

        Debug.Log("Distribution cyclique des mat�riaux termin�e !");
    }
}
