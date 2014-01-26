/*
	File: scripts/boss.nut
	Author: astrofra
*/

/*!
	@short	Boss
	@author	astrofra
*/
class	BossPart
{
	function	OnSetup(item)
	{
		ItemPhysicSetLinearFactor(item, Vector(1,0,1))
		ItemPhysicSetAngularFactor(item, Vector(0,1,0))
	}
}


/*!
	@short	Boss
	@author	astrofra
*/
class	Boss	extends BossPart
{
	
}
