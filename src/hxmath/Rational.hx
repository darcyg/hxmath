package hxmath;

// TODO: Parameterize, Rational<T>, allow use of BigInt etc.?
abstract Rational(_Rational) {
	public var num(get, set) : Int;
	inline function get_num() return this.num;
	inline function set_num(n) return this.num = n;

	public var den(get, set) : Int;
	inline function get_den() return this.den;
	inline function set_den(n) return this.den = n;

	public function new(num : Int = 0, den : Int = 1) : Rational {
		this = alloc();
		this.num = num;
		this.den = den;
		reduce(this);
	}

	static inline function alloc() : _Rational
		return {num: 0, den: 0};

	// CONVERSIONS
	public function toFloat() : Float
		return this.num / this.den;

	public function toString() : String
		return '${this.num} / ${this.den}';

	function reduce() {
		if(this.num == 0) {
			this.den = 1;
			return;
		}

		var a = this.num;
		var b = this.den;
		while(b != 0) {
			var temp = b;
			b = a % temp;
			a = temp;
		}
		if(a < 0) a = -a;

		this.num = Std.int(this.num / a);
		this.den = Std.int(this.den / a);

		if(this.den < 0) {
			this.num = -this.num;
			this.den = -this.den;
		}
	}

	// BOOLEAN COMPARISONS
	public static function eq(lhs : Rational, rhs : Rational) : Bool {
		// TODO
		return false;
	}

	public static function ne(lhs : Rational, rhs : Rational) : Bool {
		// TODO
		return false;
	}

	public static function gt(lhs : Rational, rhs : Rational) : Bool {
		// TODO
		return false;
	}

	public static function gte(lhs : Rational, rhs : Rational) : Bool {
		// TODO
		return false;
	}

	public static function lt(lhs : Rational, rhs : Rational) : Bool {
		// TODO
		return false;
	}

	public static function lte(lhs : Rational, rhs : Rational) : Bool {
		// TODO
		return false;
	}
}

private typedef _Rational = {
	var num : Int;
	var den : Int;
}