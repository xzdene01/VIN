using UnityEngine;

public static class PerlinNoise
{
	// chunkOffset is specified in chunk units (e.g. (0,0) for the origin, (1,0) for one chunk to the right)
	public static float[,] GenerateNoiseMap(
		int mapWidth,
		int mapHeight,
		float scale,
		int octaves,
		float persistence,
		float lacunarity,
		int seed,
		Vector2Int chunkOffset,
		bool flip)
	{
		if(flip)
			chunkOffset *= -1;
		float[,] noiseMap = new float[mapWidth, mapHeight];

		System.Random prng = new System.Random(seed);
		Vector2[] octaveOffsets = new Vector2[octaves];

		// Generate deterministic random offsets for each octave
		for(int i = 0; i < octaves; i++)
		{
			float offsetX = prng.Next(-100000, 100000);
			float offsetY = prng.Next(-100000, 100000);
			octaveOffsets[i] = new Vector2(offsetX, offsetY);
		}

		if(scale <= 0)
			scale = 0.0001f;

		// Compute the sample origin for this chunk.
		// Using (mapWidth - 1) and (mapHeight - 1) ensures adjacent chunks share their edge samples.
		Vector2Int sampleOrigin = new Vector2Int(chunkOffset.x * (mapWidth - 1), chunkOffset.y * (mapHeight - 1));

		// Precompute the theoretical maximum amplitude for normalization
		float maxPossibleAmplitude = 0f;
		float amplitudeCalc = 1f;
		for(int i = 0; i < octaves; i++)
		{
			maxPossibleAmplitude += amplitudeCalc;
			amplitudeCalc *= persistence;
		}

		// Generate noise values using global coordinates (derived from the chunk's sampleOrigin)
		for(int y = 0; y < mapHeight; y++)
		{
			for(int x = 0; x < mapWidth; x++)
			{
				float amplitude = 1f;
				float frequency = 1f;
				float noiseHeight = 0f;

				// Global coordinates for this sample, ensuring continuity across chunks
				float globalX = sampleOrigin.x + x;
				float globalY = sampleOrigin.y + y;

				for(int i = 0; i < octaves; i++)
				{
					float sampleX = (globalX / scale) * frequency + octaveOffsets[i].x;
					float sampleY = (globalY / scale) * frequency + octaveOffsets[i].y;
					// Mathf.PerlinNoise returns values in [0,1], remap to [-1, 1]
					float perlinValue = Mathf.PerlinNoise(sampleX, sampleY) * 2f - 1f;
					noiseHeight += perlinValue * amplitude;

					amplitude *= persistence;
					frequency *= lacunarity;
				}

				noiseMap[x, y] = noiseHeight;
			}
		}

		

		// Normalize the noise map using the theoretical amplitude range
		for(int y = 0; y < mapHeight; y++)
		{
			for(int x = 0; x < mapWidth; x++)
			{
				noiseMap[x, y] = Mathf.InverseLerp(-maxPossibleAmplitude, maxPossibleAmplitude, noiseMap[x, y]);
			}
		}

		return noiseMap;
	}
}
