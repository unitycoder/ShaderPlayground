Shader "UnityCoder/ShaderPlayground/SphereDistanceMelt"
{
    Properties
    {
        [hdr]_Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _pos("Sphere Position", Vector) = (0,0,0,0)

        _maxDist ("MaxDist", Float) = 3
        _extrude ("Extrude Multiplier", Float) = 1
        [hdr]_nearColor ("Near Color", Color) = (1,1,1,1)
        [hdr]_farColor ("Far Color", Color) = (1,1,1,1)

    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard
        #pragma target 3.0
		#pragma vertex vert

        sampler2D _MainTex;
        sampler2D _NoiseTex;

        uniform float4 _pos;
        float _maxDist;
        float _extrude;
        float4 _nearColor;
        float4 _farColor;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void vert(inout appdata_full v, out Input o) 
        {
			UNITY_INITIALIZE_OUTPUT(Input, o);
            float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
            float dist = distance(worldPos,_pos.xyz);
            dist = clamp(dist,0,_maxDist)/_maxDist;
            float edge = step(dist,0.52);
            float2 offset = float2(_Time.x, 0);
            float rgb = tex2Dlod (_NoiseTex, float4(v.texcoord.xy+offset,0,0));
            v.vertex.xyz += v.normal*rgb *_extrude*edge;
		}

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float dist = distance(IN.worldPos,_pos.xyz);
            dist = clamp(dist,0,_maxDist)/_maxDist;
            float a = lerp(0,1,dist);
            if (a<0.5) discard;
            float edge = 1-step(dist,0.52);
            float4 glow = lerp(_nearColor,_farColor,edge);
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Emission = glow;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
}
