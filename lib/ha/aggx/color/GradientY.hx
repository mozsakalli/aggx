package lib.ha.aggx.color;
//=======================================================================================================
class GradientY implements IGradientFunction
{
	public function new() 
	{
	}
	//---------------------------------------------------------------------------------------------------
	public function calculate(x:Int, y:Int, d:Int):Int 
	{
		return y;
	}
}