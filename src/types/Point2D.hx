package types;

class Point2D extends Value {
	public final x: Float;
	public final y: Float;

	public function new(x: Float, y: Float) {
		this.x = x;
		this.y = y;
	}
}