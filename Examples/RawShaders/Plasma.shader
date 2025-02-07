Shader "Custom/Plasma"
{
    Properties
    {
        _Color1     ("Color 1", Color) = (1, 0, 0, 1) // Red
        _Color2     ("Color 2", Color) = (0, 1, 1, 1) // Cyan
        _Frequency  ("Frequency", Float) = 1.0
        _Amplitude  ("Amplitude", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "UnityCG.cginc"

            fixed4 _Color1;
            fixed4 _Color2;
            float _Frequency;
            float _Amplitude;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float fogCoord : FOGCOORD;
            };

            v2f vert(appdata v)
            {
                v2f o;
                float4 worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.worldPos = worldPosition.xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                UNITY_TRANSFER_FOG(o, o.pos);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Compute color form a simple 3D noise function
                float value = sin(i.worldPos.x * _Frequency) +
                    sin(i.worldPos.y * _Frequency) +
                    sin(i.worldPos.z * _Frequency);

                // Normalize to [-1,1], than to [0, 1]
                value /= 3.0;
                float t = saturate(value * 0.5 + 0.5);

                // Scale by the amplitude
                t = saturate(t * _Amplitude);

                fixed4 col = lerp(_Color1, _Color2, t);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}