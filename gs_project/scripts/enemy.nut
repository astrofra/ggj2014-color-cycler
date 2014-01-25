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
/*<
	<Parameter =
		<distance_to_player = <Name = "Distance to player (m)"> <Type = "Float"> <Default = 5.0>>
		<strength = <Name = "Force strength"> <Type = "Float"> <Default = 10.0>>
		<inertia = <Name = "Force inertia"> <Type = "Float"> <Default = 0.25>>
	>
>*/
	player				=	0
	player_script		=	0
	dispatch			=	0
	dying				=	false

	position			=	0
	position_dt			=	0
	velocity			=	0

	distance_to_player	=	Mtr(5.0)
	distance_dt			=	0.0
	strength			=	1.0
	inertia				=	0.25
	max_speed			=	5.0

	function	OnSetup(item)
	{
		player = SceneFindItem(g_scene, "player")

		ItemPhysicSetLinearFactor(item, Vector(1,0,1))
		ItemPhysicSetAngularFactor(item, Vector(0,1,0))

		position_dt = Vector(0,0,0)
		velocity = Vector(0,0,0)
		position = ItemGetPosition(item)
	}

	function	OnUpdate(item)
	{
		if (player_script == 0)
			player_script = ItemGetScriptInstance(SceneFindItem(g_scene, "player"))

		if (dispatch != 0)
			dispatch(item)

		position_dt = player_script.position - position
		local	current_dist_to_player = position_dt.Len()
		distance_dt = distance_to_player - current_dist_to_player
	}

	function	OnPhysicStep(item, dt)
	{
		position = ItemGetPosition(item)
		velocity = ItemGetLinearVelocity(item)

		local	_force = (position_dt.Normalize().Scale(-distance_dt) - velocity.Scale(inertia))

		if (velocity.Len() > max_speed)
			_force -= velocity.Normalize().Scale(velocity.Len() - max_speed)

		_force = _force.Scale(strength)

		ItemApplyLinearForce(item, _force)
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
