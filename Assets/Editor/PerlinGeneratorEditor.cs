#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(PerlinGenerator))]
public class PerlinGeneratorEditor : Editor
{
	public override void OnInspectorGUI()
	{
		DrawDefaultInspector();

		PerlinGenerator generator = (PerlinGenerator)target;
		if(GUILayout.Button("Generate Noise Plane"))
		{
			generator.RegenerateMap();
		}
	}
}
#endif