Shader "Unlit/SepiaShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        GrabPass { "_BackgroundTexture" }

        Pass
        {
            Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
            
			ZWrite Off
			//ZTest Off
			
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 grabUV : TEXCOORD2;
            };

            float4 _Color;
            sampler2D _BackgroundTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.grabUV = ComputeGrabScreenPos(o.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 bgc = tex2Dproj(_BackgroundTexture, i.grabUV);
                fixed3 gray = (bgc.r + bgc.g + bgc.b)/3;
                fixed3 col = gray * _Color.rgb;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}
