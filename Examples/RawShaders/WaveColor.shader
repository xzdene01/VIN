Shader "Custom/WaveColor"
{
    Properties
    {
        _Amplitude ("Wave Amplitude", Float) = 0.5
        _Frequency ("Wave Frequency", Float) = 1.0
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

            float _Amplitude;
            float _Frequency;

            struct appdata
            {
                float4 vertex : POSITION;
            };

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

            v2g vert(appdata v)
            {
                v2g o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.objPos = v.vertex.xyz;
                UNITY_TRANSFER_FOG(o, o.pos);
                return o;
            }

            [maxvertexcount(3)]
            void geom(triangle v2g input[3], inout TriangleStream<g2f> triStream)
            {
                float3 center = (input[0].objPos + input[1].objPos + input[2].objPos) / 3.0;
                float3 edge1 = input[1].objPos - input[0].objPos;
                float3 edge2 = input[2].objPos - input[0].objPos;
                float3 normal = normalize(cross(edge1, edge2));
                float wave = sin(_Time.y * _Frequency + (center.x + center.z));
                float3 disp = normal * wave * _Amplitude;
                fixed3 col = lerp(fixed3(0,0,1), fixed3(1,0,0), (wave + 1) * 0.5);

                for (int i = 0; i < 3; i++)
                {
                    g2f o;
                    float3 newPos = input[i].objPos + disp;
                    o.pos = UnityObjectToClipPos(float4(newPos, 1));
                    o.color = fixed4(col, 1);
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