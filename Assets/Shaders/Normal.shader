Shader "Custom/Normal"
{
    Properties
    {
        _NorthColor ("North Color", Color) = (1, 0, 0, 1) // Red
        _EastColor  ("East Color",  Color) = (0, 1, 0, 1) // Green
        _SouthColor ("South Color", Color) = (0, 0, 1, 1) // Blue
        _WestColor  ("West Color",  Color) = (1, 1, 0, 1) // Yellow
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

            fixed4 _NorthColor;
            fixed4 _EastColor;
            fixed4 _SouthColor;
            fixed4 _WestColor;

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
                float3 a = input[0].worldPos;
                float3 b = input[1].worldPos;
                float3 c = input[2].worldPos;
                float3 faceNormal = normalize(cross(b - a, c - a));

                // Get the horizontal projection of the normal
                float2 hor = faceNormal.xz;

                // If the normal is pointing straight up or down, use a default direction
                if (length(hor) < 0.0001)
                {
                    hor = float2(0, 1);
                }
                else
                {
                    hor = normalize(hor);
                }

                // Compute the angle from north in radians
                float angle = atan2(hor.x, hor.y);
                if (angle < 0)
                    angle += 6.2831853; // Ensure angle is in [0, 2π)

                // Normalize the angle to the range [0,1]
                float f = angle / 6.2831853;

                // Interpolate the color based on the angle
                fixed4 col;
                if (f < 0.25)
                {
                    float t = f / 0.25;
                    col = lerp(_NorthColor, _EastColor, t);
                }
                else if (f < 0.5)
                {
                    float t = (f - 0.25) / 0.25;
                    col = lerp(_EastColor, _SouthColor, t);
                }
                else if (f < 0.75)
                {
                    float t = (f - 0.5) / 0.25;
                    col = lerp(_SouthColor, _WestColor, t);
                }
                else
                {
                    float t = (f - 0.75) / 0.25;
                    col = lerp(_WestColor, _NorthColor, t);
                }

                for (int i = 0; i < 3; i++)
                {
                    g2f o;
                    o.pos = input[i].pos;
                    o.color = col;
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