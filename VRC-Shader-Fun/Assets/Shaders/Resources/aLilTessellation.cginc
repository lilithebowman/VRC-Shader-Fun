#if !defined(TESSELLATION_INCLUDED)
#define TESSELLATION_INCLUDED

[UNITY_domain("tri")] // we are working with triangles here
[UNITY_outputcontrolpoints(3)] // each has 3 control points
[UNITY_outputtopology("triangle_cw")] // vertices are defined clockwise (Unity default)
[UNITY_partitioning("integer")] // cut up the patch into integers
[UNITY_patchconstantfunc("PatchConstantFunction")] // run this function once per patch
VertexData HullProgram(
	InputPatch<VertexData, 3> patch,
	uint id : SV_OutputControlPointID
) {
	return patch[id];
}

// Define the tesselation factors as a struct
struct TessellationFactors {
	float edge[3] : SV_TessFactor;
	float inside : SV_InsideTessFactor;
};

// takes a patch as an input parameter and outputs the tessellation factors
TessellationFactors PatchConstantFunction(InputPatch<VertexData, 3> patch) {
	TessellationFactors f;
	f.edge[0] = 1;
	f.edge[1] = 1;
	f.edge[2] = 1;
	f.inside = 1;
	return f;
}

[UNITY_domain("tri")]
void DomainProgram (
	TessellationFactors factors,
	OutputPatch<VertexData, 3> patch,
	float3 barycentricCoordinates : SV_DomainLocation
) {
	VertexData data;
}

#endif
