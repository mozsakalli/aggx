package lib.ha.aggx;
//=======================================================================================================
import lib.ha.core.memory.Pointer;
//=======================================================================================================
class RowInfo 
{
	public var x1:Int;
	public var x2:Int;
	public var ptr:Pointer;
	//---------------------------------------------------------------------------------------------------
	public function new(ax1:Int, ax2:Int, aptr:Pointer) 
	{
		x1 = ax1;
		x2 = ax2;
		ptr = aptr;
	}
	//---------------------------------------------------------------------------------------------------
}