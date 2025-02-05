using RuntimeInspectorNamespace;
using System.Collections.Generic;
using UnityEngine;

public class PerlinGenerator : MonoBehaviour
{
	[Header("Map Settings")]
	[Tooltip("World size for each chunk")]
	public float chunkSize = 10f;
	[Tooltip("Number of chunks to generate around the player")]
	public int viewDistanceInChunks = 2;
	[Tooltip("Generate textures or meshes")]
	public MapType mapType = MapType.Texture;

	[Header("Noise Settings")]
	[Tooltip("Width of each noise map chunk")]
	public int mapWidth = 100;
	[Tooltip("Height of each noise map chunk")]
	public int mapHeight = 100;
	[Tooltip("Scale factor for noise generation")]
	public float scale = 50f;
	[Tooltip("Number of octaves for noise generation")]
	public int octaves = 4;
	[Tooltip("Persistence factor for noise generation")]
	[Range(0f, 1f)]
	public float persistence = 0.5f;
	[Tooltip("Lacunarity factor for noise generation")]
	public float lacunarity = 2f;
	[Tooltip("Seed for noise generation")]
	public int seed = 0;
	[Tooltip("Randomize seed on start")]
	public bool random = false;

	[Header("Mesh Settings")]
	[Tooltip("Height multiplier for the mesh vertices")]
	public float meshHeightMultiplier = 10f;

	[Header("Custom Shader Settings")]
	[Tooltip("Custom shader for the mesh material")]
	public Shader customShader;
	[Tooltip("First cutoff in % of max height")]
	[Range(0f, 1f)]
	public float lowHeight = 0.3f;
	[Tooltip("Second cutoff in % of max height")]
	[Range(0f, 1f)]
	public float highHeight = 0.6f;

	[Header("Player Tracking")]
	[Tooltip("Reference to the player transform")]
	public Transform playerTransform;

	[Header("Inspector Reference")]
	[Tooltip("Reference to the runtime inspector")]
	public RuntimeInspector runtimeInspector;

	// Dictionary to keep track of generated chunks
	private Dictionary<Vector2Int, GameObject> generatedChunks = new Dictionary<Vector2Int, GameObject>();

	void Start()
	{
		// If no player reference, try to find one in the scene
		if(playerTransform == null)
			playerTransform = GameObject.FindWithTag("Player")?.transform;

		// Generate initial map around the player (and destroy old chunks)
		RegenerateMap();

		if(runtimeInspector != null)
			runtimeInspector.Inspect(this);
	}

	void FixedUpdate()
	{
		GenerateAroundPlayer();
	}

	private void GenerateAroundPlayer()
	{
		if(playerTransform == null)
			return;

		// Calculate the players current chunk coord
		Vector3 playerPos = playerTransform.position;
		Vector2Int playerChunkCoord = new Vector2Int(
			Mathf.FloorToInt(playerPos.x / chunkSize),
			Mathf.FloorToInt(playerPos.z / chunkSize)
		);

		// Loop over nearby chunks and generate
		for(int x = playerChunkCoord.x - viewDistanceInChunks; x <= playerChunkCoord.x + viewDistanceInChunks; x++)
		{
			for(int y = playerChunkCoord.y - viewDistanceInChunks; y <= playerChunkCoord.y + viewDistanceInChunks; y++)
			{
				Vector2Int chunkCoord = new Vector2Int(x, y);
				if(!generatedChunks.ContainsKey(chunkCoord))
					GenerateChunk(chunkCoord);
			}
		}
	}

	private void GenerateChunk(Vector2Int chunkCoord)
	{
		Vector3 chunkPosition = new Vector3(chunkCoord.x * chunkSize, 0f, chunkCoord.y * chunkSize);

		// Generate 2D noise map
		bool flip = (mapType == MapType.Texture) ? true : false;
		float[,] noiseMap = PerlinNoise.GenerateNoiseMap(
			mapWidth, mapHeight, scale, octaves, persistence, lacunarity, seed, chunkCoord, flip);

		if(mapType == MapType.Texture)
			GenerateTexture(chunkCoord, chunkPosition, noiseMap);
		else if(mapType == MapType.Mesh)
			GenerateMesh(chunkCoord, chunkPosition, noiseMap);
	}

	private void GenerateTexture(Vector2Int chunkCoord, Vector3 chunkPosition, float[,] noiseMap)
	{
		// Create texture from noise map
		Texture2D texture = new Texture2D(mapWidth, mapHeight);
		texture.filterMode = FilterMode.Point;
		texture.wrapMode = TextureWrapMode.Clamp;
		for(int y = 0; y < mapHeight; y++)
		{
			for(int x = 0; x < mapWidth; x++)
			{
				float value = noiseMap[x, y];
				Color color = new Color(value, value, value);
				texture.SetPixel(x, y, color);
			}
		}
		texture.Apply();

		// Create material from texture
		Material material = new Material(Shader.Find("Unlit/Texture"));
		material.mainTexture = texture;

		// Create a plane for the chunk
		GameObject plane = GameObject.CreatePrimitive(PrimitiveType.Plane);
		plane.name = "Noise Plane " + chunkCoord;
		plane.transform.position = chunkPosition;
		plane.transform.parent = transform;

		// Adjust the plane scale so that it matches the desired chunk size
		// Default is 10x10 units
		float planeDefaultSize = 10f;
		float scaleFactor = chunkSize / planeDefaultSize;
		plane.transform.localScale = new Vector3(scaleFactor, 1f, scaleFactor);

		// Assign the material to the plane
		plane.GetComponent<Renderer>().material = material;

		// Add the generated chunk to the dictionary so it is not spawned again
		generatedChunks.Add(chunkCoord, plane);
	}

	private void GenerateMesh(Vector2Int chunkCoord, Vector3 chunkPosition, float[,] noiseMap)
	{
		// Create arrays for vertices, UVs, and triangles
		Vector3[] vertices = new Vector3[mapWidth * mapHeight];
		Vector2[] uv = new Vector2[mapWidth * mapHeight];
		int[] triangles = new int[(mapWidth - 1) * (mapHeight - 1) * 6];

		// Populate vertices and UVs
		// The grid is laid out in the XZ plane with Y representing the height
		for(int y = 0; y < mapHeight; y++)
		{
			for(int x = 0; x < mapWidth; x++)
			{
				int i = y * mapWidth + x;
				float vertexHeight = noiseMap[x, y]; // Use noise as the vertex height
				vertices[i] = new Vector3(x, vertexHeight * meshHeightMultiplier, y);
				uv[i] = new Vector2((float)x / (mapWidth - 1), (float)y / (mapHeight - 1));
			}
		}

		// Populate the triangles array by iterating over each quad in the grid
		int triIndex = 0;
		for(int y = 0; y < mapHeight - 1; y++)
		{
			for(int x = 0; x < mapWidth - 1; x++)
			{
				int i = y * mapWidth + x;

				// First triangle of the quad
				triangles[triIndex + 0] = i;
				triangles[triIndex + 1] = i + mapWidth;
				triangles[triIndex + 2] = i + mapWidth + 1;

				// Second triangle of the quad
				triangles[triIndex + 3] = i;
				triangles[triIndex + 4] = i + mapWidth + 1;
				triangles[triIndex + 5] = i + 1;

				triIndex += 6;
			}
		}

		// Create and assign the mesh
		Mesh mesh = new Mesh
		{
			vertices = vertices,
			triangles = triangles,
			uv = uv
		};
		mesh.RecalculateNormals();

		// Create a new GameObject for the mesh chunk
		GameObject meshChunk = new GameObject("Noise Mesh " + chunkCoord);
		meshChunk.transform.position = chunkPosition;
		meshChunk.transform.parent = transform;

		// Normalize scale to match chunk size (not width and height of generate map)
		Vector2 scale = new Vector2(chunkSize / (mapWidth - 1), chunkSize / (mapHeight - 1));
		meshChunk.transform.localScale = new Vector3(scale.x, 1f, scale.y);

		// Center mesh (origin mesh will have center around (0, 0, 0))
		meshChunk.transform.position -= new Vector3(chunkSize / 2f, 0f, chunkSize / 2f);

		// Add a MeshFilter to display the mesh
		MeshFilter meshFilter = meshChunk.AddComponent<MeshFilter>();
		meshFilter.mesh = mesh;

		// Use custom shader material
		Material material = new Material(customShader);
		material.SetFloat("_LowHeight", lowHeight * meshHeightMultiplier);
		material.SetFloat("_HighHeight", highHeight * meshHeightMultiplier);
		meshChunk.AddComponent<MeshRenderer>().material = material;

		// Finally, add the generated chunk to the dictionary so it is not spawned again
		generatedChunks.Add(chunkCoord, meshChunk);
	}

	public void RegenerateMap()
	{
		// Generate a random seed
		if(random) seed = Random.Range(0, int.MaxValue);

		// Destroy all child objects (generated chunks)
		// In editor use DestroyImmediate to avoid memory leaks
		for(int i = transform.childCount - 1; i >= 0; i--)
		{
#if UNITY_EDITOR
			DestroyImmediate(transform.GetChild(i).gameObject);
#else
			Destroy(transform.GetChild(i).gameObject);
#endif
		}

		// Clear the generated chunks dictionary
		generatedChunks.Clear();

		GenerateAroundPlayer();
	}

	public enum MapType
	{
		Texture = 0,
		Mesh = 1
	}
}