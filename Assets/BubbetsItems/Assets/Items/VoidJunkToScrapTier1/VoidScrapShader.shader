Shader "Unlit/VoidScrapShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
		}
		LOD 100

		Pass
		{
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
                float3 viewDir : COLOR;
			    float4 screenPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.viewDir = normalize(ObjSpaceViewDir(v.vertex));
                o.screenPos = ComputeScreenPos(o.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

			float mix(float x, float y, float a)
            {
	            return mul(x, (1. - a) + mul(y, a));
            }
            
            float2x2 Rot(float a) {
                float s=sin(a), c=cos(a);
                return float2x2(c, -s, s, c);
            }

			float Star(float2 uv, float flare) {
	float d = length(uv);
    float m = .05/d;
    
    float rays = max(0., 1.-abs(uv.x*uv.y*1000.));
    m += rays*flare;
    uv = mul(uv, Rot(3.1415/4.));
    rays = max(0., 1.-abs(uv.x*uv.y*1000.));
    m += rays*.3*flare;
    
    m *= smoothstep(1., .2, d);
    return m;
}

float Hash21(float2 p) {
    p = frac(p*float2(123.34, 456.21));
    p += dot(p, p+45.32);
    return frac(p.x*p.y);
}

float3 StarLayer(float2 uv) {
	float3 col = float3(0, 0, 0);
	
    float2 gv = frac(uv)-.5;
    float2 id = floor(uv);
    
    for(int y=-1;y<=1;y++) {
    	for(int x=-1;x<=1;x++) {
            float2 offs = float2(x, y);
            
    		float n = Hash21(id+offs); // random between 0 and 1
            float size = frac(n*345.32);
            
    		float star = Star(gv-offs-float2(n, frac(n*4.))+.5, smoothstep(.9, 1., size)*.6);
            
            float3 color = sin(float3(.2, .3, .9)*frac(n*2345.2)*123.2)*.5+.5;
            color = color*float3(0.5,.0,1.+size)+float3(.15, .05, .2)*2.;
            
            star *= sin(_Time.y*3.+n*2.2831)*.15+.2;
            col += star*size*color * 0.2;
        }
    }
    return col;
}

            float4 frag (v2f ig) : SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);

            	float t = _Time.y * 0.1;

                //float2 uv = ig.screenPos.xy;
            	float2 uv = ig.screenPos / ig.uv;
                uv = mul(uv, Rot(t));

                float3 col = float3(0., 0., 0.);

                for(float i=0.; i<1.; i+=1./2) {
    				float depth = frac(i+t);
        
					float scale = mix(20., .5, depth);
					float fade = depth*smoothstep(1., .9, depth);
					col += StarLayer(uv*scale+i*453.2)*fade;
				}
                
                col = pow(col, .4545);
                return float4(col.xyz, 1.);
            }
            ENDCG
		}
	}
}