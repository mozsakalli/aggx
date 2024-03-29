package lib.ha.aggx.vectorial;
//=======================================================================================================
import lib.ha.core.memory.Ref;
import lib.ha.core.math.Calc;
//=======================================================================================================
class Ellipse implements IVertexSource
{
	private var _x:Float;
	private var _y:Float;
	private var _rx:Float;
	private var _ry:Float;
	private var _approximationScale:Float;
	private var _num:Int;
	private var _step:Int;
	private var _cw:Bool;
	//---------------------------------------------------------------------------------------------------
	public function new(?x:Float, ?y:Float, ?rx:Float, ?ry:Float, ?numSteps:Int, ?cw:Bool)
	{
		if (x != null && y != null && rx != null && ry != null)
		{
			init(x, y, rx, ry, numSteps, cw);
		}
		else 
		{
			_x = 0.;
			_y = 0.;
			_rx = 1.;
			_ry = 1.;
			_num = 4;
			_approximationScale = 1.;
			_cw = false;
		}
	}
	//---------------------------------------------------------------------------------------------------
	private inline function set_approximationScale(value:Float):Float
	{
		_approximationScale = value;
		calcNumSteps();
		return value;
	}
	public inline var approximationScale(null, set_approximationScale):Float;	
	//---------------------------------------------------------------------------------------------------
	public function init(x:Float, y:Float, rx:Float, ry:Float, numSteps:Int = 0, cw:Bool = false):Void
	{
		_approximationScale = 1.0;
		_x = x;
		_y = y;
		_rx = rx;
		_ry = ry;
		_num = numSteps;
		_step = 0;
		_cw = cw;
		if(_num == 0) calcNumSteps();
	}
	//---------------------------------------------------------------------------------------------------
	private function calcNumSteps():Void
	{
		var ra = (Calc.fabs(_rx) + Calc.fabs(_ry)) / 2;
		var da = Math.acos(ra / (ra + 0.125 / _approximationScale)) * 2;
		_num = Std.int(Calc.PI2 / da);
	}
	//---------------------------------------------------------------------------------------------------
	public function rewind(path_id:UInt):Void
	{
		_step = 0;
	}
	//---------------------------------------------------------------------------------------------------
	public function getVertex(x:FloatRef, y:FloatRef):UInt
	{
		if(_step == _num)
		{
			++_step;
			return PathCommands.END_POLY | PathFlags.CLOSE | PathFlags.CCW;
		}
		if(_step > _num) return PathCommands.STOP;
		var angle = _step / _num * Calc.PI2;
		if(_cw) angle = Calc.PI2 - angle;
		x.value = _x + Math.cos(angle) * _rx;
		y.value = _y + Math.sin(angle) * _ry;
		_step++;
		return ((_step == 1) ? PathCommands.MOVE_TO : PathCommands.LINE_TO);
	}
}