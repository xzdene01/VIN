Shader "Custom/HeightColor"
{
    Properties
    {
        // Define the cutoff heights as shader properties
        _LowHeight ("Low Height Cutoff", Float) = 3.0
        _HighHeight ("High Height Cutoff", Float) = 7.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            // Require shader model 4.0 for geometry shader usage
            #pragma target 4.0
            #pragma multi_compile_fog
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            #include "UnityCG.cginc"

            // Uniform parameters set from c# script
            float _LowHeight;
            float _HighHeight;

            // -----------------------------------------------------------------
            // Structures for passing data between shader stages
            // -----------------------------------------------------------------

            // Input structure for the vertex shader
            struct appdata
            {
                float4 vertex : POSITION;
            };

            // Data passed from vertex to geometry shader
            struct v2g
            {
                float4 pos : SV_POSITION;
                float3 objPos : TEXCOORD0;
                float fogCoord : FOGCOORD;
            };

            // Data passed from geometry to fragment shader
            struct g2f
            {
                float4 pos : SV_POSITION;
                fixed4 color : COLOR;
                float3 normal : TEXCOORD1;
                float fogCoord : FOGCOORD;
            };

            // -----------------------------------------------------------------
            // Vertex Shader: Transforms vertices from object space to clip space
            // and passes the original object-space position
            // -----------------------------------------------------------------
            v2g vert(appdata v)
            {
                v2g o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.objPos = v.vertex.xyz;
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }

            // -----------------------------------------------------------------
            // Geometry Shader: Computes the triangle center, assigns a color based on height,
            // and calculates a face normal for flat lighting
            // -----------------------------------------------------------------
            [maxvertexcount(3)]
            void geom(triangle v2g input[3], inout TriangleStream<g2f> triStream)
            {
                // Calculate the center of the triangle in object space
                float3 triCenter = (input[0].objPos + input[1].objPos + input[2].objPos) / 3.0f;

                // Predefined colors for brown, green, and white
                fixed3 brown = fixed3(0.55f, 0.27f, 0.07f);
                fixed3 green = fixed3(0.0f, 0.5f, 0.0f);
                fixed3 white = fixed3(1.0f, 1.0f, 1.0f);

                // Choose the color based on the triangle height
                fixed3 col;
                if (triCenter.y < _LowHeight)
                {
                    col = brown;
                }
                else if (triCenter.y < _HighHeight)
                {
                    col = green;
                }
                else
                {
                    col = white;
                }

                // Compute the face normal using two edges of the triangle
                float3 edge1 = input[1].objPos - input[0].objPos;
                float3 edge2 = input[2].objPos - input[0].objPos;
                float3 faceNormal = normalize(cross(edge1, edge2));

                // Emit each vertex with its position, the chosen color, and the computed normal
                for (int i = 0; i < 3; i++)
                {
                    g2f o;
                    o.pos = input[i].pos;
                    o.color = fixed4(col, 1.0f);
                    o.normal = faceNormal;
                    o.fogCoord = input[i].fogCoord;
                    triStream.Append(o);
                }
            }

            // -----------------------------------------------------------------
            // Fragment Shader: Applies basic Lambert diffuse lighting
            // -----------------------------------------------------------------
            fixed4 frag(g2f i) : SV_Target
            {
                // Normalize the face normal
                float3 N = normalize(i.normal);

                // Get the directional light vector from the built-in _WorldSpaceLightPos0
                float3 L = normalize(_WorldSpaceLightPos0.xyz);

                // Calculate the diffuse factor
                float diff = saturate(dot(N, L));

                // Add a small ambient term
                float ambient = 0.2f;
                fixed4 litColor = i.color * (ambient + diff);
                UNITY_APPLY_FOG(i.fogCoord, litColor);
                return litColor;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
