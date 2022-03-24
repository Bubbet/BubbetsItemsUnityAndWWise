// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/TorturerShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BackgroundColor ("Background Color", Color) = (1,1,1,1)
        _ForegroundColor ("Foreground Color", Color) = (1,1,1,1)
        _TextureScale ("Static Scale", Range(0,10)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            //#pragma multi_compile_fog

            #include "UnityCG.cginc"
            
            #define TAU 6.28318530718

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            float4 _ForegroundColor;
            float4 _BackgroundColor;
            
            float _TextureScale;
            
            float rand(float2 co)
            {
                return frac((sin( dot(co.xy , float2(12.345 * _Time.w, 67.890 * _Time.w) )) * 12345.67890+_Time.w));
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.vertex += rand(sin(_Time.y * 0.01 + v.uv.y) * 0.0001) * 0.1;
                o.screenPos = ComputeScreenPos(o.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex); //v.uv; //
                o.uv.x += (sin(_Time.y * 0.25) + 1)/2; // _Time.y * 0.5; 
                //UNITY_TRANSFER_FOG(o,o.vertex);
                
                //float4 modelOrigin = mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0));
                //o.camDist.x = distance(_WorldSpaceCameraPos.xyz, modelOrigin.xyz);
                //o.camDist.x = lerp(1.0, o.camDist.x, _ScaleWithZoom);
                
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 mask = tex2D(_MainTex, i.uv);
                float4 effectMask = (1-mask);
                effectMask *= mask;
                
                float2 pos = i.screenPos.xy / i.screenPos.w * _TextureScale;
                //float4 pos = i.screenPos;
                pos = round(pos * 100)/100;
                
                float4 bgcol = float4(rand(pos).xxx, 1) * _BackgroundColor; //float4(sin(i.screenPos.x), cos(i.screenPos.y), 0, 1); 
                float4 fgcol = _ForegroundColor * ((cos(_Time.y*3.3)+1)/2+0.5);// * effectMask;
                
                //float4 col = bgcol + fgcol;
                float4 col = lerp(bgcol, fgcol, effectMask*2);
                
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                
                return float4(saturate(col).xyz, 1.0);
            }
            ENDCG
        }
    }
}
