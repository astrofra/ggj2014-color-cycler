/*
	File: scripts/enemy.nut
	Author: astrofra
*/

/*!
	@short	EnemyHandler
	@author	astrofra
*/
class	EnemyHandler
{
		function	OnSetup(item)
	{
		ItemPhysicSetLinearFactor(item, Vector(1,0,1))
		ItemPhysicSetAngularFactor(item, Vector(0,1,0))
	}

	function	Hit()
	{
		print("EnemyHandler::Hit() !!!")
	}
}
