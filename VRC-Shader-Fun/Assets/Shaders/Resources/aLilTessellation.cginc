#if !defined(TESSELLATION_INCLUDED)
#define TESSELLATION_INCLUDED

	// Define the Tesselation Control Point struct
	struct ControlPoint {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float4 tangent : TANGENT;
		float2 uv : TEXCOORD0;
		float2 uv1 : TEXCOORD1;
		float2 uv2 : TEXCOORD2;
	};

	// Define the tesselation factors as a struct
	struct TessellationFactors {
		float edge[3] : SV_TessFactor;
		float inside : SV_InsideTessFactor;
	};

	[UNITY_domain("tri")] // we are working with triangles here
	[UNITY_outputcontrolpoints(3)] // each has 3 control points
	[UNITY_outputtopology("triangle_cw")] // vertices are defined clockwise (Unity default)
	[UNITY_partitioning("integer")] // cut up the patch into integers
	[UNITY_patchconstantfunc("PatchConstantFunction")] // run this function once per patch
	ControlPoint HullProgram(
		InputPatch<ControlPoint, 3> patch,
		uint id : SV_OutputControlPointID
	) {
		return patch[id];
	}


	// takes a patch as an input parameter and outputs the tessellation factors
	TessellationFactors PatchConstantFunction(InputPatch<ControlPoint, 3> patch) {
		TessellationFactors f;
		float dist = distance(
			_WorldSpaceCameraPos,
			mul(unity_ObjectToWorld, patch[0].vertex)
		) / _Falloff;

		// Use the current framerate to modify the density
		float densityOffset = normalize(_FPS / 60);

		// Set the density equal to the minimum of simply the user's density value
		// or the density value divided by the distance * the density offset
		// calculated from the FPS
		float density = min(_Density / dist * densityOffset, _Density);
		float2 uv = patch[0].uv;

		// modify the calculated density by the grass density image
		// which the user can use to select specific parts of a mesh
		// to place grass on
		density = density * normalize(tex2Dlod(_GrassDensityTex, float4(uv, 0, 0)));

		// Set the new edges based on the density calculations
		f.edge[0] = density;
		f.edge[1] = density;
		f.edge[2] = density;
		f.inside = density;
		return f;
	}

	ControlPoint TesellatedVertexProgram(VertexData v) {
		ControlPoint p;
		p.vertex = v.vertex;
		p.normal = v.normal;
		p.tangent = v.tangent;
		p.uv = v.uv;
		p.uv1 = v.uv1;
		p.uv2 = v.uv2;
		return p;
	}

	[UNITY_domain("tri")]
	ControlPoint DomainProgram (
		TessellationFactors factors,
		OutputPatch<ControlPoint, 3> patch,
		float3 barycentricCoordinates : SV_DomainLocation
	) {
		ControlPoint data;

		// define a macro to interpolate values
		#define MY_DOMAIN_PROGRAM_INTERPOLATE(fieldName) data.fieldName = \
			patch[0].fieldName * barycentricCoordinates.x + \
			patch[1].fieldName * barycentricCoordinates.y + \
			patch[2].fieldName * barycentricCoordinates.z;

		MY_DOMAIN_PROGRAM_INTERPOLATE(vertex)  // interpolate the vertex
		MY_DOMAIN_PROGRAM_INTERPOLATE(normal)  // interpolate the normal
		MY_DOMAIN_PROGRAM_INTERPOLATE(tangent) // interpolate the tangent
		MY_DOMAIN_PROGRAM_INTERPOLATE(uv)      // interpolate the first uv
		MY_DOMAIN_PROGRAM_INTERPOLATE(uv1)     // interpolate the second uv
		MY_DOMAIN_PROGRAM_INTERPOLATE(uv2)     // interpolate the third uv

		return TesellatedVertexProgram(data);
	}

#endif
