Shader "Custom/Ripple"
{
    Properties
    {
        _Color1       ("Color 1", Color) = (1, 0, 0, 1) // Red
        _Color2       ("Color 2", Color) = (0, 0, 1, 1) // Blue
        _RippleCenter ("Ripple Center", Vector) = (0, 0, 0, 0)
        _Frequency    ("Frequency", Float) = 10.0
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
            float4 _RippleCenter;
            float _Frequency;

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
                float4 worldPos4 = mul(unity_ObjectToWorld, v.vertex);
                o.worldPos = worldPos4.xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                UNITY_TRANSFER_FOG(o, o.pos);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float dist = distance(i.worldPos, _RippleCenter.xyz);

                // Generate a ripple pattern using sine wave
                float ripple = sin(dist * _Frequency);

                // Remap values from [-1, 1] to [0, 1].
                float t = ripple * 0.5 + 0.5;

                fixed4 col = lerp(_Color1, _Color2, t);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}