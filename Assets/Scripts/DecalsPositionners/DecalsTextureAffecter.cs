/*using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering.Universal;

[RequireComponent(typeof(DecalProjector))]
[ExecuteInEditMode] // 🛠️ Exécute dans l'éditeur même hors Play Mode
public class DecalsTextureAffecter : MonoBehaviour
{
    private DecalProjector projector;
    private Material material;
    private HG.DeferredDecals.Decal decals;

    private void Awake()
    {
        projector = GetComponent<DecalProjector>();
        decals = GetComponent<HG.DeferredDecals.Decal>();
        material = decals.DecalMaterial;
        ApplyTexture();
    }

    void OnValidate()
    {
        if (projector == null) projector = GetComponent<DecalProjector>();

        // Vérifie si on est en mode Prefab (Asset, hors scène)
        if (PrefabUtility.IsPartOfPrefabAsset(gameObject))
        {
            Debug.Log("🏗️ Modification du Prefab dans le Project Window !");
            ApplyTexture();
            return;
        }

        // Si l'objet est une instance dans la scène liée à un prefab
        if (PrefabUtility.IsPartOfPrefabInstance(gameObject))
        {
            Debug.Log("🔄 Mise à jour de l'instance du Prefab dans la scène !");
            ApplyTexture();
        }
        else
        {
            // Objet standard dans la scène
            ApplyTexture();
        }
    }

    private void ApplyTexture()
    {
        if (material == null)
        {
            Debug.LogWarning("⚠️ Aucun matériau assigné au Decal Projector !");
            return;
        }

        projector.material = material;
    }

}*/
