Shader "Custom/ColorChange"
{
    Properties
    {
        _Pulse ("Normal Pulse", Float) = 0.8
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma target 4.0
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "UnityCG.cginc"

            float _Pulse;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2g
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float fogCoord : FOGCOORD;
            };

            struct g2f
            {
                float4 pos : SV_POSITION;
                fixed4 color : COLOR;
                float3 normal : TEXCOORD1;
                float fogCoord : FOGCOORD;
            };

            v2g vert(appdata v)
            {
                v2g o;
                float4 worldPos4 = mul(unity_ObjectToWorld, v.vertex);
                o.worldPos = worldPos4.xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                UNITY_TRANSFER_FOG(o, o.pos);
                return o;
            }

            [maxvertexcount(3)]
            void geom(triangle v2g input[3], inout TriangleStream<g2f> triStream)
            {
                float3 center = (input[0].worldPos + input[1].worldPos + input[2].worldPos) / 3.0;
                float3 edge1 = input[1].worldPos - input[0].worldPos;
                float3 edge2 = input[2].worldPos - input[0].worldPos;
                float3 faceNormal = normalize(cross(edge1, edge2));

                // Modify the normal with a time-based pulse
                float3 modNormal = normalize(faceNormal + _Pulse * float3(sin(_Time.y), cos(_Time.y), sin(_Time.y * 0.5)));

                // Use the modified normal to generate a color (mapping from [-1,1] to [0,1])
                fixed3 col = 0.5 * (modNormal + 1.0);

                for (int i = 0; i < 3; i++)
                {
                    g2f o;
                    o.pos = input[i].pos;
                    o.normal = modNormal;
                    o.color = fixed4(col, 1.0);
                    o.fogCoord = input[i].fogCoord;
                    triStream.Append(o);
                }
            }

            fixed4 frag(g2f i) : SV_Target
            {
                UNITY_APPLY_FOG(i.fogCoord, i.color);
                return i.color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}