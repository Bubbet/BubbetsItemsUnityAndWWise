Shader "Unlit/SandFluidShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", COLOR) = (1,1,1,1)
        _Fill ("Fill", Range(0,1)) = 0.9
        _WobbleX ("WobbleX", Range(-1,1)) = 0
        _WobbleZ ("WobbleZ", Range(-1,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Zwrite On
		    Cull Off // we want the front and back faces
		    AlphaToMask On // transparency
		    
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 viewDir : COLOR;
                float3 normal : COLOR2;
                float fillEdge : TEXCOORD1;
            };

            float _Fill, _WobbleX, _WobbleZ;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            
            float4 RotateAroundYInDegrees(float4 vertex, float degrees){
                float alpha = degrees * UNITY_PI / 180;
                //float sina = sin(alpha);
                //float cosa = cos(alpha);
                float sina, cosa;
                sincos(alpha, sina, cosa);
                float2x2 m = float2x2(cosa, sina, -sina, cosa);
                return float4(vertex.yz, mul(m, vertex.xz)).xzyw;
            }
            
            

            float3 RotateAroundZInDegrees (float3 vertex, float degrees)
            {
                float alpha = degrees * UNITY_PI / 180.0;
                float sina, cosa;
                sincos(alpha, sina, cosa);
                float2x2 m = float2x2(cosa, -sina, sina, cosa);
                //return float3(mul(m, vertex.xz), vertex.y).xzy;
                return float3(mul(m, vertex.xy), vertex.z).zxy;
            }



            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex.xyz);
                float3 worldPosX = RotateAroundYInDegrees(float4(worldPos,0), 360);
                //float3 worldPosX = RotateAroundZInDegrees(float4(worldPos,0), 90);
                //worldPosX = worldPosX.xzy;
                float3 worldPosZ = float3(worldPosX.y, worldPosX.z, worldPosX.x);
                
                float3 worldPosAdjusted = worldPos + (worldPosX * _WobbleX) + (worldPosZ * _WobbleZ);
                
                o.fillEdge = worldPosAdjusted + _Fill*2 - 0.5;
                o.viewDir = normalize(ObjSpaceViewDir(v.vertex));
                o.normal = v.normal;
                               
                return o;
            }

            float4 frag (v2f i, fixed facing : VFACE) : SV_Target
            {
                // sample the texture
                //float4 col = float4(1,1,0,1);
                //float4 col = tex2D(_MainTex, i.uv);
                float4 col = _Color;
                
                float4 result = 1-step(i.fillEdge, 0.5);
                //return result;
                
                float4 topColor = saturate(float4(1.1,1.1,1.1,1) * col * result);
                
                return facing > 0 ? col * result : topColor;
            }
            ENDCG
        }
    }
}
