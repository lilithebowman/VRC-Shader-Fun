#if !defined(TESSELLATION_INCLUDED)
#define TESSELLATION_INCLUDED

// Define the Tesselation Control Point struct
struct TessellationControlPoint {
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
TessellationControlPoint HullProgram(
	InputPatch<TessellationControlPoint, 3> patch,
	uint id : SV_OutputControlPointID
) {
	return patch[id];
}


// takes a patch as an input parameter and outputs the tessellation factors
TessellationFactors PatchConstantFunction(InputPatch<TessellationControlPoint, 3> patch) {
	TessellationFactors f;
	f.edge[0] = 1;
	f.edge[1] = 1;
	f.edge[2] = 1;
	f.inside = 1;
	return f;
}

TessellationControlPoint TesellatedVertexProgram(TessellationControlPoint v) {
	TessellationControlPoint p;
	p.vertex = v.vertex;
	p.normal = v.normal;
	p.tangent = v.tangent;
	p.uv = v.uv;
	p.uv1 = v.uv1;
	p.uv2 = v.uv2;
	return p;
}

[UNITY_domain("tri")]
TessellationControlPoint DomainProgram (
	TessellationFactors factors,
	OutputPatch<TessellationControlPoint, 3> patch,
	float3 barycentricCoordinates : SV_DomainLocation
) {
	TessellationControlPoint data;

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
