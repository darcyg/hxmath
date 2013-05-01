package hxmath;

// BigInt interface
abstract BigInt(_BigInt) {
	static inline var BITS_PER_CHUNK : Int = 30;
	static inline var CHUNK_MASK : Int = (1 << BITS_PER_CHUNK) - 1;
	static inline var CHUNK_MAX_FLOAT : Float = (1 << (BITS_PER_CHUNK-1)) * 2.0;

	var impl(get, never) : _BigInt;
	inline function get_impl() return this;
	
	inline function new() : BigInt
		this = alloc();

	// INSTANTIATION
	private static inline function alloc() : _BigInt {
		return {chunks: new Array(), signum: 0};
	}

	@:from
	public static function ofInt(n : Int) : BigInt {
		var bn = new BigInt();
		if (n < 0) {
			bn.impl.signum = -1;
			n = -n;
		} else if (n > 0) {
			bn.impl.signum = 1;
		} else {
			return bn;
		}
		
		while(n != 0) {
			bn.impl.chunks.push(n & CHUNK_MASK);
			n >>>= BITS_PER_CHUNK;
		}

		return bn;
	}

	public static function ofFloat(n : Float) : BigInt {
		var bn = new BigInt();

		if (n < 0) {
			bn.impl.signum = -1;
			n = -n;
		} else if (n > 0) {
			bn.impl.signum = 1;
		}

		n = Math.ffloor(n);
		while(n != 0) {
			bn.impl.chunks.push( Std.int(n % CHUNK_MAX_FLOAT) );
			n = Math.ffloor( n / CHUNK_MAX_FLOAT );
		}

		return bn;
	}

	public static function ofString(n : String) : BigInt {
		// TODO
		return new BigInt();
	}

	// CONVERSION
	public function toInt() : Int {
		var n = 0;
		var i = this.chunks.length - 1;
		while(i >= 0) {
			n <<= BITS_PER_CHUNK;
			n |= this.chunks[i];
			i--;
		}
		return n * this.signum;
	}

	public function toFloat() : Float {
		var n = 0.0;
		var i = this.chunks.length - 1;
		while(i >= 0) {
			n *= CHUNK_MAX_FLOAT;
			n += this.chunks[i];
			i--;
		}
		return n * this.signum;
	}

	public function toString() : String {
		// TODO
		return "0";
	}

	// BOOLEAN COMPARISONS
	@:op(A == B)
	public static function eq(lhs : BigInt, rhs : BigInt) : Bool {
		// the _BigInt representation is guaranteed to be unique,
		// so we can just compare the guts for equality
		if(lhs.impl.signum != rhs.impl.signum) return false;
		if(lhs.impl.chunks.length != rhs.impl.chunks.length) return false;
		for(i in 0...lhs.impl.chunks.length) {
			if(lhs.impl.chunks[i] != rhs.impl.chunks[i]) return false;
		}

		return true;
	}

	@:op(A != B)
	public static inline function neq(lhs : BigInt, rhs : BigInt) : Bool
		return !eq(lhs, rhs);

	@:op(A == B) @:commutative
	public static inline function eqInt(lhs : BigInt, rhs : Int) : Bool
		return lhs == ofInt(rhs);

	@:op(A != B) @:commutative
	public static inline function neqInt(lhs : BigInt, rhs : Int) : Bool
		return lhs != ofInt(rhs);

	// BASIC ARITHMETIC
	@:op(A + B)
	public static function add(lhs : BigInt, rhs : BigInt) : BigInt {
		if (lhs.impl.signum == 0) return rhs;
		if (rhs.impl.signum == 0) return lhs;
		if (_compareMagnitude(lhs, rhs) == 1) {
			var temp = lhs;
			lhs = rhs;
			rhs = temp;
		}
		if (lhs.impl.signum == rhs.impl.signum) return _add(lhs, rhs);
		else return _sub(lhs, rhs);
	}

	@:op(A - B)
	public static function sub(lhs : BigInt, rhs : BigInt) : BigInt
		return new BigInt(); // TODO

	static function _compareMagnitude(a : BigInt, b : BigInt) : Int {
		if (a.impl.chunks.length > b.impl.chunks.length) return -1;
		if (a.impl.chunks.length < b.impl.chunks.length) return 1;
		var i = a.impl.chunks.length;
		while (i >= 0) {
			if(a.impl.chunks[i] > b.impl.chunks[i]) return -1;
			if(a.impl.chunks[i] < b.impl.chunks[i]) return 1;
			i--;
		}
		return 0;
	}

	static function _add(big : BigInt, small : BigInt) : BigInt {
		var out = new BigInt();

		var carry = 0;
		for(i in 0...big.impl.chunks.length) {
			var sum = big.impl.chunks[i] + small.impl.chunks[i] + carry;
			carry = sum >>> BITS_PER_CHUNK;
			sum &= CHUNK_MASK;
			out.impl.chunks.push(sum);
		}
		for(i in big.impl.chunks.length...small.impl.chunks.length) {
			var sum = big.impl.chunks[i] + carry;
			carry = sum >>> BITS_PER_CHUNK;
			sum &= CHUNK_MASK;
			out.impl.chunks.push(sum);
		}
		if (carry == 1) out.impl.chunks.push(1);
		out.impl.signum = big.impl.signum;

		return out;
	}

	static function _sub(big : BigInt, small : BigInt) : BigInt {
		var out = new BigInt();

		var borrow = 0;
		for(i in 0...big.impl.chunks.length) {
			var diff = big.impl.chunks[i] - small.impl.chunks[i] - borrow;
			borrow = diff >>> BITS_PER_CHUNK;
			diff &= CHUNK_MASK;
			out.impl.chunks.push(diff);
		}
		for(i in big.impl.chunks.length...small.impl.chunks.length) {
			var diff = big.impl.chunks[i] - borrow;
			borrow = diff >>> BITS_PER_CHUNK;
			diff &= CHUNK_MASK;
			out.impl.chunks.push(diff);
		}
		if (borrow == 1) out.impl.chunks.push(1);
		out.impl.signum = big.impl.signum;

		return out;
	}

	@:op(A * B)
	public static inline function mul(lhs : BigInt, rhs : BigInt) : BigInt
		return new BigInt(); // TODO

	@:op(A / B)
	public static inline function div(lhs : BigInt, rhs : BigInt) : BigInt
		return new BigInt(); // TODO

	@:op(-A)
	public static inline function neg(n : BigInt) : BigInt {
		var out : BigInt = new BigInt();
		out.impl.chunks = n.impl.chunks;
		out.impl.signum = -n.impl.signum;
		return out;
	}
}

private typedef _BigInt = {
	var chunks : Array<Int>;
	var signum : Int;
}