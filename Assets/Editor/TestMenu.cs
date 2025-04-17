using UnityEditor;
using UnityEngine;

public static class TestMenuExample
{
    [MenuItem("Outils/Test Menu")]
    public static void TestMenu()
    {
        Debug.Log("Test menu OK !");
    }
}
