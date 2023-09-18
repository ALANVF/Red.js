package types;

class Point3D extends Value {
	public final x: Float;
	public final y: Float;
	public final z: Float;

	public function new(x: Float, y: Float, z: Float) {
		this.x = x;
		this.y = y;
		this.z = z;
	}
}