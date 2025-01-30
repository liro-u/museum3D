using UnityEngine;
using UnityEditor;
using System.IO;
using System.Linq;

public class MaterialFromImage : Editor
{
    [MenuItem("Tools/Create Materials from PEINTURES DIVERSES")]
    static void CreateMaterials()
    {
        string path = "Assets/Tableaux/zones/PEINTURES_DIVERSES-Grotte32"; // V�rifie bien ce chemin

        if (!Directory.Exists(path))
        {
            Debug.LogError($"Dossier introuvable : {path}");
            return;
        }

        string[] files = Directory.GetFiles(path, "*.jpg")
            .Concat(Directory.GetFiles(path, "*.jpeg"))
            .Concat(Directory.GetFiles(path, "*.png"))
            .ToArray();

        foreach (string file in files)
        {
            string fileName = Path.GetFileNameWithoutExtension(file);
            string materialPath = path + "/" + fileName + ".mat";

            // V�rifie si un fichier existe d�j�
            if (File.Exists(materialPath))
            {
                Debug.LogError($"Fichier en conflit : {materialPath}. Supprime-le puis r�essaie.");
                continue;
            }

            // V�rifie si un mat�riau existe d�j� et le supprime
            if (AssetDatabase.LoadAssetAtPath<Material>(materialPath) != null)
            {
                AssetDatabase.DeleteAsset(materialPath);
            }

            // Cr�e le mat�riau avec le shader custom
            Material mat = new Material(Shader.Find("Custom/GDecalShader"));

            // D�finit les valeurs par d�faut pour les propri�t�s
            mat.SetFloat("_NormalTolerance", -1);
            mat.SetFloat("_AlphaClip", 0.001f);
            mat.SetFloat("_NormalPow", 0); // Normal Influence
            mat.SetFloat("_Glossiness", 0); // Smoothness
            mat.SetFloat("_Metallic", 0);
            mat.SetFloat("_GlossinessPow", 1); // Specular Influence

            // Charge la texture de l'image et l'assigne au mat�riau
            Texture2D texture = AssetDatabase.LoadAssetAtPath<Texture2D>(file);

            if (texture != null)
            {
                mat.SetTexture("_MainTex", texture);
            }

            // Cr�e le fichier .mat � l'emplacement sp�cifi�
            AssetDatabase.CreateAsset(mat, materialPath);
            Debug.Log($"Mat�riau cr�� : {materialPath}");
        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }
}
