Shader "Unlit/Vector_Extended"
{
    Properties
    {
        [PerRendererData] _MainTex ("Texture", 2D) = "white" {}
		[HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
		[HideInInspector] _Flip ("Flip", Vector) = (1,1,1,1)
		[PerRendererData] _HorizontalSkew ("Horizontal Skew", Float) = 0
        [PerRendererData] _VerticalSkew ("Vertical Skew", Float) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "PreviewType" = "Plane"
        }
 
        Cull Off
        Lighting Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
 
        Pass
        {
            CGPROGRAM
            #pragma vertex VectorVert
            #pragma fragment frag
            #pragma multi_compile_instancing
 
            #include "UnityCG.cginc"
			#include "UnitySprites.cginc"
 
            struct appdata
            {
                float4 vertex : POSITION;
                fixed4 color : COLOR;
                float2 uv : TEXCOORD0;
                float2 settingIndex : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
 
            struct v2f2
            {
                fixed4 color : COLOR;
                float2 uv : TEXCOORD0; // uv.z is used for setting index
                float2 settingIndex : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };
 
            //sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
           
			float _HorizontalSkew;
			float _VerticalSkew;
         
            v2f2 VectorVert (appdata v)
            {
                v2f2 o;
                UNITY_SETUP_INSTANCE_ID (v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);	
                o.vertex = UnityObjectToClipPos(v.vertex);			
                #ifdef UNITY_COLORSPACE_GAMMA				
                fixed4 col = v.color;			
                #else
                fixed4 col = fixed4(GammaToLinearSpace(v.color.rgb), v.color.a);				
                #endif
                o.color = col * _RendererColor;		
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);			
                o.settingIndex = v.settingIndex;
				//Create a skew transformation matrix
				float h = _HorizontalSkew;
				float vs = _VerticalSkew;
				float4x4 transformMatrix = float4x4(
					1,h,0,0,
					vs,1,0,0,
					0,0,1,0,
					0,0,0,1);
					float4 skewedVertex = mul(transformMatrix, v.vertex);
					o.vertex = UnityObjectToClipPos(skewedVertex);	
                return o;
            }
 
            float2 unpackFloat2(fixed4 c)
            {
                return float2(c.r*255 + c.g, c.b*255 + c.a);
            }
 
            float2 rayUnitCircleFirstHit(float2 rayStart, float2 rayDir)
            {
                float tca = dot(-rayStart, rayDir);
                float d2 = dot(rayStart, rayStart) - tca * tca;
                float thc = sqrt(1.0f - d2);
                float t0 = tca - thc;
                float t1 = tca + thc;
                float t = min(t0, t1);
                if (t < 0.0f)
                    t = max(t0, t1);
                return rayStart + rayDir * t;
            }
 
            float radialAddress(float2 uv, float2 focus)
            {
                uv = (uv - float2(0.5f, 0.5f)) * 2.0f;
                float2 pointOnPerimeter = rayUnitCircleFirstHit(focus, normalize(uv - focus));
                float2 diff = pointOnPerimeter - focus;
                if (abs(diff.x) > 0.0001f)
                    return (uv.x - focus.x) / diff.x;
                if (abs(diff.y) > 0.0001f)
                    return (uv.y - focus.y) / diff.y;
                return 0.0f;
            }
 
            fixed4 frag (v2f2 i) : SV_Target
            {
              
                int settingBase = ((int)(i.settingIndex.x + 0.5f)) * 3;
                float2 texelSize = _MainTex_TexelSize.xy;
                float2 settingUV = float2(settingBase + 0.5f, 0.5f) * texelSize;
 
                float2 uv = i.uv;
                fixed4 gradSettings = tex2D(_MainTex, settingUV);
                if (gradSettings.x > 0.0f)
                {
                    // Radial texture case
                    float2 focus = (gradSettings.zw - float2(0.5f, 0.5f)) * 2.0f; // bring focus in the (-1,1) range                
                    uv = float2(radialAddress(i.uv, focus), 0.0);
                }
 
                int addressing = gradSettings.y * 255;
                uv.x = (addressing == 0) ? fmod(uv.x,1.0f) : uv.x; // Wrap
                uv.x = (addressing == 1) ? max(min(uv.x,1.0f), 0.0f) : uv.x; // Clamp
                float w = fmod(uv.x,2.0f);
                uv.x = (addressing == 2) ? (w > 1.0f ? 1.0f-fmod(w,1.0f) : w) : uv.x; // Mirror
 
                // Adjust UV to atlas position
                float2 nextUV = float2(texelSize.x, 0);
                float2 pos = (unpackFloat2(tex2D(_MainTex, settingUV+nextUV) * 255) + float2(0.5f, 0.5f)) * texelSize;
                float2 size = unpackFloat2(tex2D(_MainTex, settingUV+nextUV*2) * 255) * texelSize;
                uv = uv * size + pos;
				
                fixed4 texColor = tex2D(_MainTex, uv);
                #ifndef UNITY_COLORSPACE_GAMMA
                texColor = fixed4(GammaToLinearSpace(texColor.rgb), texColor.a);
                #endif
 
                return texColor * i.color;
            }
            ENDCG
        }
    }
}
 