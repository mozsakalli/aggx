package lib.ha.aggx.calculus;
//=======================================================================================================
import flash.Vector;
import lib.ha.core.memory.FloatStorage;
import lib.ha.core.memory.Ref;
//=======================================================================================================
class BSpline 
{
	private var _max:Int;
	private var _num:Int;
	private var _x:Vector<Float>;
	private var _y:Vector<Float>;
	private var _am:Vector<Float>;
	private var _lastIdx:Int;
	//---------------------------------------------------------------------------------------------------
	public function new(?num:Int, ?x:Vector<Float>, ?y:Vector<Float>) 
	{
		_am = new Vector();
		_x = new Vector();
		_y = new Vector();
		init(num, x, y);
	}
	//---------------------------------------------------------------------------------------------------
	public function init(num:Int, ?x:Vector<Float>, ?y:Vector<Float>)
	{
		if (num > 2 && num > _max)
		{
			_max = num;
			_am.length = num * 3;
			_x[_x.length] = _am[_max];
			_y[_y.length] = _am[_max * 2];
			if (x != null && y != null)			
			{
				var i = 0;
				while (i < num) 
				{
					addPoint(x[i], y[i]);
					i++;
				}
			}
		}
		else 
		{
			_num = 0;
		}
		_lastIdx = -1;
	}
	//---------------------------------------------------------------------------------------------------
	public function addPoint(x:Float, y:Float):Void
	{
		if(_num < _max)
		{
			_x[_num] = x;
			_y[_num] = y;
			++_num;
		}
	}
	//---------------------------------------------------------------------------------------------------
	public function prepare():Void
	{
		if(_num > 2)
		{
			var i:Int, k:Int, n1:Int;
			
			var h:Float, p:Float, d:Float, f:Float, e:Float;

			var k = 0;
			while(k < _num)
			{
				_am[k] = 0.0;
				k++;
			}

			n1 = 3 * _num;

			var al = new Vector<Float>(n1);
			
			var temp = { data: al, offset:0 };
			
			temp.data = al;

			while(k < n1)
			{
				temp.data[temp.offset + k] = 0.0;
				k++;
			}
			var r = { data: temp.data, offset:_num };
			var s = { data: temp.data, offset:_num * 2 };

			n1 = _num - 1;
			d = _x[1] - _x[0];
			e = (_y[1] - _y[0]) / d;

			k = 1;
			while(k < n1)
			{
				h = d;
				d = _x[k + 1] - _x[k];
				f = e;
				e = (_y[k + 1] - _y[k]) / d;
				al[k] = d / (d + h);
				r.data[r.offset + k] = 1.0 - al[k];
				s.data[s.offset + k] = 6.0 * (e-f) / (h + d);
				k++;
			}

			k = 1;
			while(k < n1)
			{
				p = 1.0 / (r.data[r.offset + k] * al[k - 1] + 2.0);
				al[k] *= -p;
				s.data[s.offset + k] = (s.data[s.offset + k] - r.data[r.offset + k] * s.data[s.offset + (k - 1)]) * p;
				k++;
			}

			_am[n1] = 0.0;
			al[n1 - 1] = s.data[s.offset + (n1 - 1)];
			_am[n1 - 1] = al[n1 - 1];

			k = n1 - 2;
			i = 0;
			while(i < _num - 2)
			{
				al[k] = al[k] * al[k + 1] + s.data[s.offset + k];
				_am[k] = al[k];
				k--;
				i++;
			}
		}
		_lastIdx = -1;
	}
	//---------------------------------------------------------------------------------------------------
	private function bsearch(n:Int, x:FloatStorage, x0:Float, i:IntRef)
	{
		var j = n - 1;
		var k;

		i.value = 0;
		while(j - i.value > 1)
		{
			k = (i.value + j) >> 1;
			if (x0 < x.data[x.offset + k]) j = k;
			else i.value = k;
		}
	}
	//---------------------------------------------------------------------------------------------------
	private function interpolation(x:Float, i:Int):Float
	{
		var j = i + 1;
		var d = _x[i] - _x[j];
		var h = x - _x[j];
		var r = _x[i] - x;
		var p = d * d / 6.0;
		return (_am[j] * r * r * r + _am[i] * h * h * h) / 6.0 / d + ((_y[j] - _am[j] * p) * r + (_y[i] - _am[i] * p) * h) / d;
	}
	//---------------------------------------------------------------------------------------------------
	private function extrapolationLeft(x:Float):Float
	{
		var d = _x[1] - _x[0];
		return (-d * _am[1] / 6 + (_y[1] - _y[0]) / d) * (x - _x[0]) + _y[0];
	}

	//------------------------------------------------------------------------
	private function extrapolationRight(x:Float):Float
	{
		var d = _x[_num - 1] - _x[_num - 2];
		return (d * _am[_num - 2] / 6 + (_y[_num - 1] - _y[_num - 2]) / d) * (x - _x[_num - 1]) + _y[_num - 1];
	}
	//---------------------------------------------------------------------------------------------------
	public function get(x:Float):Float
	{
		if(_num > 2)
		{
			var i = Ref.int1;

			if (x < _x[0]) return extrapolationLeft(x);
			if (x >= _x[_num - 1]) return extrapolationRight(x);

			var pmx = { data: _x, offset:0 };
			bsearch(_num, pmx, x, i);
			return interpolation(x, i.value);
		}
		return 0.0;
	}
	//---------------------------------------------------------------------------------------------------
	public function getStateful(x:Float):Float
	{
		if(_num > 2)
		{
			if (x < _x[0]) return extrapolationLeft(x);

			if (x >= _x[_num - 1]) return extrapolationRight(x);

			if (_lastIdx >= 0)			
			{
				if (x< _x[_lastIdx] || x > _x[_lastIdx + 1])				
				{
					if (_lastIdx < _num - 2 && x >= _x[_lastIdx + 1] && x <= _x[_lastIdx + 2])					
					{
						++_lastIdx;
					}
					else if (_lastIdx > 0 && x >= _x[_lastIdx - 1] && x <= _x[_lastIdx])					
					{
						--_lastIdx;
					}
					else
					{
						var last_idx = Ref.int2.set(_lastIdx);
						var pmx = { data: _x, offset:0 };
						bsearch(_num, pmx, x, last_idx);
						_lastIdx = last_idx.value;
					}
				}
				return interpolation(x, _lastIdx);
			}
			else
			{
				var last_idx = Ref.int2.set(_lastIdx);
				var pmx = { data: _x, offset:0 };
				bsearch(_num, pmx, x, last_idx);
				_lastIdx = last_idx.value;
				return interpolation(x, _lastIdx);
			}
		}
		return 0.0;
	}
}