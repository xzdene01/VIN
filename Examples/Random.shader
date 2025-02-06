Shader "Custom/Random"
{
    Properties
    {
        // No properties needed.
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma target 4.0
            #pragma multi_compile_fog
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            // Pass clip-space position and object-space position.
            struct v2g
            {
                float4 pos : SV_POSITION;
                float3 objPos : TEXCOORD0;
                float fogCoord : FOGCOORD;
            };

            struct g2f
            {
                float4 pos : SV_POSITION;
                fixed4 color : COLOR;
                float fogCoord : FOGCOORD;
            };

            // Vertex Shader: transforms vertex to clip space and passes object-space pos.
            v2g vert(appdata v)
            {
                v2g o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.objPos = v.vertex.xyz;
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }

            // Geometry Shader: computes a random color based on object-space triangle center.
            [maxvertexcount(3)]
            void geom(triangle v2g input[3], inout TriangleStream<g2f> triStream)
            {
                float3 triCenter = (input[0].objPos + input[1].objPos + input[2].objPos) / 3.0f;
                float rand = frac(sin(dot(triCenter, float3(12.9898f, 78.233f, 45.164f))) * 43758.5453f);
                fixed3 randomColor = fixed3(rand, frac(rand * 1.3f), frac(rand * 1.7f));
                
                for (int i = 0; i < 3; i++)
                {
                    g2f o;
                    o.pos = input[i].pos;
                    o.color = fixed4(randomColor, 1.0f);
                    o.fogCoord = input[i].fogCoord;
                    triStream.Append(o);
                }
            }

            // Fragment Shader: outputs the constant color.
            fixed4 frag(g2f i) : SV_Target
            {
                fixed4 col = i.color;
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}