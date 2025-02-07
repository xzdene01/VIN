Shader "Custom/BlackAndWhite"
{
    Properties
    {
        _CenterColor ("Center Color", Color) = (1, 1, 1, 1) // White
        _EdgeColor   ("Edge Color",   Color) = (0, 0, 0, 1) // Black
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

            fixed4 _CenterColor;
            fixed4 _EdgeColor;

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
                float3 bary : TEXCOORD0;
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
                float3 bary0 = float3(1, 0, 0);
                float3 bary1 = float3(0, 1, 0);
                float3 bary2 = float3(0, 0, 1);
                for (int i = 0; i < 3; i++)
                {
                    g2f o;
                    o.pos = input[i].pos;
                    o.fogCoord = input[i].fogCoord;
                    if (i == 0)
                        o.bary = bary0;
                    else if (i == 1)
                        o.bary = bary1;
                    else
                        o.bary = bary2;
                    triStream.Append(o);
                }
            }

            fixed4 frag(g2f i) : SV_Target
            {
                // Barycentric coordinates of the current fragment
                float3 bary = i.bary;
                float3 baryCenter = float3(1.0/3.0, 1.0/3.0, 1.0/3.0);

                // Compute the distance from the current barycentrics to the barycenter
                float dist = distance(bary, baryCenter);

                // The maximum distance from the center to the edge of the triangle
                float maxDist = 0.8165;

                // Normalize the distance to the range [0, 1]
                float t = saturate(dist / maxDist);

                fixed4 col = lerp(_CenterColor, _EdgeColor, t);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}