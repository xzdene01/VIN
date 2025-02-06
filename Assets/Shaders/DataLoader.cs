using UnityEngine;
using System.IO;
using System.Collections.Generic;

public class DataLoader : MonoBehaviour
{
	// Remember loaded assets
	private HashSet<string> loadedFiles = new HashSet<string>();

	void Start()
	{
		LoadAssetBundles();
	}

	private void FixedUpdate()
	{
		//LoadAssetBundles();
	}

	private void LoadAssetBundles()
	{
		// Build/project root path
		string buildDirectory = Path.GetDirectoryName(Application.dataPath);

		// The "Data" folder should be placed in the build directory !!! HARDCODED !!!
		string dataFolderPath = Path.Combine(buildDirectory, "Data");
		if(!Directory.Exists(dataFolderPath))
		{
			Debug.Log("Data folder not found at: " + dataFolderPath);
			return;
		}

		// Get all files in the Data folder (only AssetBundles should be there) !!! non-recursive !!!
		string[] bundleFiles = Directory.GetFiles(dataFolderPath);
		Debug.Log("Found " + bundleFiles.Length + " file(s) in the Data folder.");

		foreach(string filePath in bundleFiles)
		{
			Debug.Log("Attempting to load asset bundle from: " + filePath);
			LoadAssetBundle(filePath);
		}
	}

	private void LoadAssetBundle(string filePath)
	{
		// Check if the file was already loaded
		if(loadedFiles.Contains(filePath))
		{
			Debug.Log("AssetBundle already loaded: " + filePath);
			return;
		}

		// Load the asset bundle in runtime
		AssetBundle assetBundle = AssetBundle.LoadFromFile(filePath);
		if(assetBundle == null)
		{
			Debug.LogError("Failed to load AssetBundle from: " + filePath);
			return;
		}

		// Load all assets from the bundle into memory
		Object[] loadedAssets = assetBundle.LoadAllAssets();
		Debug.Log("Total loaded assets count from '" + Path.GetFileName(filePath) + "': " + loadedAssets.Length);
		foreach(Object asset in loadedAssets)
		{
			Debug.Log("Loaded asset: " + asset.name);
		}

		// Unload the asset bundle but keep the loaded assets in memory
		assetBundle.Unload(false);

		// Remember the loaded file
		loadedFiles.Add(filePath);
	}
}
