shader_type spatial;
const vec3 cameraNormalVector = vec3(0.0,0.0,-10.93);
const float mass = 10.0;

float calculateB(float phi,float r,float R,float M) {
	float l = r*r*phi;
	float e = sqrt((((r*r)-(r*M*2.0))*phi*phi)+(r*r));
	float b = abs(l/e);
	
	return b;
}

float calculateDeflection(float b, float M) {
	float bofM = b/M;
	bool comparison = b/M > 5.19;
	float defAngle = 0.0;
	if (comparison) {
		float firstAddBracket = (4.0/bofM)+((1.0/((bofM-4.0)*(bofM-4.0)))*10.0);
		float secondAddBracket = ((1.0/((bofM-4.0)*(bofM-4.0)*(bofM-4.0)))*-20.0)+((1.0/((bofM-4.0)*(bofM-4.0)*(bofM-4.0)*(bofM-4.0)))*17.0);
		float thirdAddBracket = ((1.0/((bofM-4.2)*(bofM-4.2)))*(1.0/((bofM-4.2)*(bofM-4.2)))*(1.0/((bofM-4.2)*(bofM-4.2)*(bofM-4.2)*(bofM-4.2)*(bofM-4.2)))*1.5)+((1.0/((bofM-5.16)*(bofM-5.16)*(bofM-5.16)*(bofM-5.16)*(bofM-5.16)))*10e-7);
		float defAngle = firstAddBracket+secondAddBracket+thirdAddBracket;
	}
	
	return defAngle;
}

void fragment() {
	vec3 normalizedView = normalize(VIEW);
	vec3 projectedVector = (normalizedView.x*cameraNormalVector.x+normalizedView.y*cameraNormalVector.y+normalizedView.z*cameraNormalVector.z)*normalize(cameraNormalVector);
	float phi = length(normalizedView-projectedVector);
	float r = length(projectedVector);
	float B = calculateB(phi,r,length(cameraNormalVector),mass);
	float deflectionAngle = calculateDeflection(B,mass);
	int mask = 0;
	if (deflectionAngle != 0.0) {
		mask = 1;
	}
	vec3 normalizedCrossProduct = normalize(vec3(VIEW.y*cameraNormalVector.z-VIEW.z*cameraNormalVector.y,VIEW.z*cameraNormalVector.x-VIEW.x*cameraNormalVector.z,VIEW.x*cameraNormalVector.y-VIEW.y*cameraNormalVector.x));
	vec4 quaternionCrossProduct = vec4(normalizedCrossProduct.x,normalizedCrossProduct.y,normalizedCrossProduct.z,deflectionAngle);
	vec4 quatView = vec4(normalizedView.x,normalizedView.y,normalizedView.z,0.0);
	quatView = quaternionCrossProduct * quatView * vec4(-quaternionCrossProduct.x,-quaternionCrossProduct.y,-quaternionCrossProduct.z,quaternionCrossProduct.w);
	vec3 rotatedVector = vec3(quatView.x,quatView.y,quatView.z);
}

