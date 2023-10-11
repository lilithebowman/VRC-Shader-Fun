/* Simple Holy Macaroni Raymarching Shader
 *
 * Lilithe followed the tutorial at https://www.youtube.com/watch?v=S8AWd66hoCo
 */

Shader "Unlit/HolyMacaroni" {
	Properties {
		// _MainTex("Texture", 2D) = "white" {} /* Texture is unused in this one */
		_Cutout("Cutout", float) = 1
		_TorusSize("Torus Size", float) = 1
		_Thickness("Torus Thickness", float) = 1
		_Tuner("Tuner", float) = 1
	}

	SubShader {
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#define MAX_STEPS 100
			#define MAX_DIST 100
			#define SURF_DIST 0.001

			#include "UnityCG.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f {
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 ro : TEXCOORD1;
				float3 hitPos : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Cutout;
			float _TorusSize;
			float _Thickness;
			float _Tuner;

			v2f vert(appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				// calculate ray origin and hit position in world space
				/*
				o.ro = _WorldSpaceCameraPos;
				o.hitPos = mul(unity_ObjectToWorld, v.vertex);
				*/

				// calculate ray origin and hit position in object space
				o.ro = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
				o.hitPos = v.vertex;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			float GetDist(float3 p) {
				float d = length(p) - 0.5; // sphere
				d = length(float2(length(p.xz) - 0.5 * _TorusSize, p.y)) - 0.1 *
				_Thickness; //torus

				return d;
			}

			// The normal mostly affects the colour here
			float3 GetNormal(float3 p) {
				float2 offset = float2(0.02, 0);
				float3 n = GetDist(p) - float3(
				GetDist(p - offset.xyy),
				GetDist(p - offset.yxy),
				GetDist(p - offset.yyx)
				);
				return normalize(n);
			}

			float Raymarch(float3 ro, float3 rd) {
				float dO = 0; // distance from origin
				float dS; // distance from surface
				for (int i = 0; i < MAX_STEPS; i++) {
					float3 p = ro + dO * rd;
					dS = GetDist(p % _Tuner);
					dO += dS;
					if (dS % _Tuner < SURF_DIST || dO % _Tuner > MAX_DIST) {
						break;
					}
				}

				return dO;
			}

			fixed4 frag(v2f i) : SV_Target {
				float2 uv = i.uv - 0.5; // uv co-ordinates
				float3 ro = i.ro; // ray origin
				float3 rd = normalize(i.hitPos - ro); // ray distance

				float d = Raymarch(ro, rd); // distance
				fixed4 tex = tex2D(_MainTex, i.uv); // texture
				fixed4 col = 0; // colour
				// float m = dot(tex.x, tex.y); // mask

				if (d >= MAX_DIST) {
					if (_Cutout > 0.5) discard;
				} else {
					float3 p = ro + rd * d;
					float3 n = GetNormal(p);
					col.rgb = n;
				}

				// Blend texture on top of shader
				// col = lerp(col, tex, smoothstep(0.1, 0.2, m));

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}