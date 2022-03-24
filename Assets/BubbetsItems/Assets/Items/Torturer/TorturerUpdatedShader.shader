Shader "Custom/TorturerUpdatedShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _BackgroundColor ("Background Color", Color) = (1,1,1,1)
        _ForegroundColor ("Foreground Color", Color) = (1,1,1,1)
        _TextureScale ("Static Scale", Range(0,10)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float4 screenPos : TEXCOORD0;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        
            float4 _ForegroundColor;
            float4 _BackgroundColor;
            
            float _TextureScale;
        
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
        v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.vertex += rand(sin(_Time.y * 0.01 + v.uv.y) * 0.0001) * 0.1;
                o.screenPos = ComputeScreenPos(o.vertex); 
                //UNITY_TRANSFER_FOG(o,o.vertex);
                
                //float4 modelOrigin = mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0));
                //o.camDist.x = distance(_WorldSpaceCameraPos.xyz, modelOrigin.xyz);
                //o.camDist.x = lerp(1.0, o.camDist.x, _ScaleWithZoom);
                
                return o;
            }
            
            float rand(float2 co)
            {
                return frac((sin( dot(co.xy , float2(12.345 * _Time.w, 67.890 * _Time.w) )) * 12345.67890+_Time.w));
            }

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            //fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            //o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = 1.0;


            IN.uv_MainTex.x += (sin(_Time.y * 0.25) + 1)/2;
            
            // sample the texture
                float4 mask = tex2D(_MainTex, IN.uv_MainTex);
                float4 effectMask = (1-mask);
                effectMask *= mask;
                
                float2 pos = IN.screenPos.xy / IN.screenPos.w * _TextureScale;
                //float4 pos = i.screenPos;
                pos = round(pos * 100)/100;
                
                float4 bgcol = float4(rand(pos).xxx, 1) * _BackgroundColor; //float4(sin(i.screenPos.x), cos(i.screenPos.y), 0, 1); 
                float4 fgcol = _ForegroundColor * ((cos(_Time.y*3.3)+1)/2+0.5);// * effectMask;
                
                //float4 col = bgcol + fgcol;
                float4 col = lerp(bgcol, fgcol, effectMask*2);
                
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                
                o.Albedo = saturate(col).xyz;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
