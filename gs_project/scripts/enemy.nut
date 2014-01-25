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
	player			=	0
	player_script	=	0
	dispatch		=	0
	dying			=	false

	function	OnSetup(item)
	{
		player = SceneFindItem(g_scene, "player")

		ItemPhysicSetLinearFactor(item, Vector(1,0,1))
		ItemPhysicSetAngularFactor(item, Vector(0,1,0))
	}

	function	OnUpdate(item)
	{
		if (player_script == 0)
			player_script = ItemGetScriptInstance(SceneFindItem(g_scene, "player"))

		if (dispatch != 0)
			dispatch(item)
	}

	function	OnPhysicStep(item, dt)
	{
	}

	function	Hit()
	{
		if (dying)
			return

		print("EnemyHandler::Hit() !!!")
		dying = true
		dispatch = Explode
	}

	function	Explode(item)
	{
		if ("HearSfxFromLocation" in player_script)
			player_script.HearSfxFromLocation("audio/SFX_explosion.wav", ItemGetPosition(item), Mtr(50.0))

		ItemSetCommandList(item, "toscale 0.0,1.0,1.0,1.0;toscale 0.1,2.0,1.0,2.0;")

		dispatch = WaitForExplosionEnd
	}

	function	WaitForExplosionEnd(item)
	{
		if (ItemIsCommandListDone(item))
			dispatch = Die
	}

	function	Die(item)
	{
		dispatch = 0
		SceneDeleteItem(g_scene, item)
	}
}
