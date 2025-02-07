Shader "Custom/Checker"
{
    Properties
    {
        _Color1 ("Color 1", Color) = (1,0,0,1)
        _Color2 ("Color 2", Color) = (0,0,1,1)
        _Scale  ("Checker Scale", Float) = 1.0
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
 
            fixed4 _Color1;
            fixed4 _Color2;
            float _Scale;
 
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
                float3 center = (input[0].worldPos + input[1].worldPos + input[2].worldPos) / 3.0;
                int gridX = (int)floor(center.x * _Scale);
                int gridZ = (int)floor(center.z * _Scale);
                int sum = gridX + gridZ;
                fixed4 col = (sum % 2 == 0) ? _Color1 : _Color2;
 
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