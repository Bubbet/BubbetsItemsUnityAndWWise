// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/IntersectionShader"
{
	Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _Color2("Color2", Color) = (1,1,1,1)
        _ColorMix("Color Mix", Range(0, 1)) = 0
        _FadeLength("Fade Length", Range(0, 2)) = 0.15
    }
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite On

        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        Pass
        {
            Cull Off
            ZWrite Off
            CGPROGRAM
            #pragma target 3.0
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            float rand(float2 c){
	return frac(sin(dot(c.xy ,float2(12.9898,78.233))) * 43758.5453);
}

float noise(float2 p, float freq ){
	float unit = 1./freq;
	float2 ij = floor(p/unit);
	float2 xy = fmod(p,unit)/unit;
	//xy = 3.*xy*xy-2.*xy*xy*xy;
	xy = .5*(1.-cos(UNITY_PI*xy));
	float a = rand((ij+float2(0.,0.)));
	float b = rand((ij+float2(1.,0.)));
	float c = rand((ij+float2(0.,1.)));
	float d = rand((ij+float2(1.,1.)));
	float x1 = lerp(a, b, xy.x);
	float x2 = lerp(c, d, xy.x);
	return lerp(x1, x2, xy.y);
}

float pNoise(float2 p, int res){
	float persistance = .5;
	float n = 0.;
	float normK = 0.;
	float f = 4.;
	float amp = 1.;
	int iCount = 0;
	for (int i = 0; i<50; i++){
		n+=amp*noise(p, f);
		f*=2.;
		normK+=amp;
		amp*=persistance;
		if (iCount == res) break;
		iCount++;
	}
	float nf = n/normK;
	return nf*nf*nf*nf;
}
            

            v2f vert(appdata v, out float4 vertex : SV_POSITION)
            {
                v2f o;
                vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            sampler2D _CameraDepthTexture;
            float4 _Color;
            float4 _Color2;
           
            float _FadeLength;
            float _ColorMix;
            

            float4 frag (v2f i, UNITY_VPOS_TYPE vpos : VPOS) : SV_Target
            {
                float2 screenuv = vpos.xy / _ScreenParams.xy;
                float screenDepth = Linear01Depth(tex2D(_CameraDepthTexture, screenuv));
                float diff = screenDepth - Linear01Depth(vpos.z);
                float intersect = 0;

                if(diff > 0)
                    intersect = 1 - smoothstep(0, _ProjectionParams.w * _FadeLength, diff);


                float4 col = lerp(_Color, _Color2, _ColorMix);
                col.a *= intersect;
                col *= pNoise(vpos.xy * 0.005 + _Time.y * 0.1, 2) * 0.5 + 0.5;
                //col.a = _Color.a;
                //col.a = pow(intersect, 4);
                return col;
            }
            ENDCG
        }
    }
}
