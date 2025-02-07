using UnityEngine;
using System.IO;
using System.Collections.Generic;
using System.Collections;
using System.Diagnostics;

public class DataLoader : MonoBehaviour
{
	// Remember loaded assets
	private HashSet<string> loadedFiles = new HashSet<string>();

	void Start()
	{
		// Check if Raw folder exists
		string buildDirectory = Path.GetDirectoryName(Application.dataPath);
		string rawPath = Path.Combine(buildDirectory, "Raw");
		if(Directory.Exists(rawPath))
			RunDockerTool();

		// Start loading asset bundles
		StartCoroutine(CallLoad());
	}

	private IEnumerator CallLoad()
	{
		LoadAssetBundles();
		yield return new WaitForSeconds(5.0f);
		StartCoroutine(CallLoad());
	}

	private void LoadAssetBundles()
	{
		// Build/project root path
		string buildDirectory = Path.GetDirectoryName(Application.dataPath);

		// The "Data" folder should be placed in the build directory !!! HARDCODED !!!
		string dataFolderPath = Path.Combine(buildDirectory, "Data");
		if(!Directory.Exists(dataFolderPath))
		{
			UnityEngine.Debug.Log("Data folder not found at: " + dataFolderPath);
			return;
		}

		// Get all files in the Data folder (only AssetBundles should be there) !!! non-recursive !!!
		string[] bundleFiles = Directory.GetFiles(dataFolderPath);
		UnityEngine.Debug.Log("Found " + bundleFiles.Length + " file(s) in the Data folder.");

		foreach(string filePath in bundleFiles)
		{
			UnityEngine.Debug.Log("Attempting to load asset bundle from: " + filePath);
			LoadAssetBundle(filePath);
		}
	}

	private void LoadAssetBundle(string filePath)
	{
		// Check if the file was already loaded
		if(loadedFiles.Contains(filePath))
		{
			UnityEngine.Debug.Log("AssetBundle already loaded: " + filePath);
			return;
		}

		// Load the asset bundle in runtime
		AssetBundle assetBundle = AssetBundle.LoadFromFile(filePath);
		if(assetBundle == null)
		{
			UnityEngine.Debug.LogError("Failed to load AssetBundle from: " + filePath);
			return;
		}

		// Load all assets from the bundle into memory
		Object[] loadedAssets = assetBundle.LoadAllAssets();
		UnityEngine.Debug.Log("Total loaded assets count from '" + Path.GetFileName(filePath) + "': " + loadedAssets.Length);
		foreach(Object asset in loadedAssets)
		{
			UnityEngine.Debug.Log("Loaded asset: " + asset.name);
		}

		// Unload the asset bundle but keep the loaded assets in memory
		assetBundle.Unload(false);

		// Remember the loaded file
		loadedFiles.Add(filePath);
	}

	private void RunDockerTool()
	{
		UnityEngine.Debug.Log("Running Docker tool to build shaders and asset bundles");

		// Get absolute path of folders to be mounted into Docker
		string projectRoot = Directory.GetParent(Application.dataPath).FullName;
		string rawPath = Path.Combine(projectRoot, "Raw");
		string dataPath = Path.Combine(projectRoot, "Data");

		// Create Data folder if it does not exist
		if(!Directory.Exists(dataPath))
			Directory.CreateDirectory(dataPath);

		string dockerArgs = string.Format(
			"run --rm -v \"{0}:/project/Assets/Shaders\" -v \"{1}:/project/AssetBundles\" xzdene01/unity-shader-builder:latest",
			rawPath, dataPath
		);

		ProcessStartInfo psi = new ProcessStartInfo
		{
			FileName = "docker",
			Arguments = dockerArgs,
			UseShellExecute = true,
			CreateNoWindow = false,
		};

		Process dockerProcess = Process.Start(psi);
		dockerProcess.WaitForExit();

		UnityEngine.Debug.Log("Docker tool finished building shaders and asset bundles");
	}
}
