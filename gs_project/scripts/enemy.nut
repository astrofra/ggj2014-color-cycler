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
		<max_speed = <Name = "Max speed (mtrs)"> <Type = "Float"> <Default = 5.0>>
		<strength = <Name = "Force strength"> <Type = "Float"> <Default = 10.0>>
		<inertia = <Name = "Force inertia"> <Type = "Float"> <Default = 0.25>>
	>
>*/
	player				=	0
	player_script		=	0
	dispatch			=	0
	awaken				=	false
	dying				=	false

	body				=	0

	position			=	0
	position_dt			=	0
	velocity			=	0
	sideway_vector		=	0

	initial_position_dt	=	0
	initial_distance_to_player	=	0

	current_dist_to_player	=	0
	distance_to_player	=	Mtr(5.0)
	distance_dt			=	0.0
	strength			=	1.0
	inertia				=	0.25
	max_speed			=	5.0

	function	OnSetup(item)
	{
		body = item
		player = SceneFindItem(g_scene, "player")

		ItemPhysicSetLinearFactor(item, Vector(1,0,1))
		ItemPhysicSetAngularFactor(item, Vector(0,1,0))

		position_dt = Vector(0,0,0)
		initial_position_dt = Vector(0,0,0)
		sideway_vector = Vector(0,0,0)

		velocity = Vector(0,0,0)
		position = ItemGetPosition(item)

		//	Spawn(position)
	}

	function	Spawn(_position)
	{
		if (player_script == 0)
			player_script = ItemGetScriptInstance(SceneFindItem(g_scene, "player"))

		position = _position
		ItemSetPosition(body, position)
		ItemPhysicResetTransformation(body, position, Vector(0,0,0))
		ItemSetLinearVelocity(body, Vector(0,0,0))

		initial_position_dt = player_script.position - position
		initial_position_dt.y = 0.0
		initial_distance_to_player = initial_position_dt.Len()

		if (fabs(initial_position_dt.x) < fabs(initial_position_dt.z))
			initial_position_dt.x = 0.0
		else
			initial_position_dt.z = 0.0

		awaken = true
	}

	function	OnUpdate(item)
	{
		if (player_script == 0)
			player_script = ItemGetScriptInstance(SceneFindItem(g_scene, "player"))

		if (dispatch != 0)
			dispatch(item)

		position_dt = player_script.position - position
		current_dist_to_player = position_dt.Len()
		distance_dt = distance_to_player - current_dist_to_player

		local	_d_min = distance_to_player * 0.9
		local	_d_max = initial_distance_to_player
		local	dist_ramp = RangeAdjust(Clamp(current_dist_to_player, _d_min, _d_max), _d_min, _d_max, 0.0, 1.0)
		position_dt = position_dt.Lerp(1.0 - dist_ramp, initial_position_dt)

		sideway_vector = player_script.position - position
		sideway_vector = sideway_vector.ApplyMatrix(RotationMatrixY(Deg(90.0)))
		sideway_vector = sideway_vector.Normalize()
	}

	function	OnPhysicStep(item, dt)
	{
		position = ItemGetPosition(item)
		velocity = ItemGetLinearVelocity(item)

		if (awaken)
		{
			ItemSetLinearDamping(item, 1.0)
			ItemSetAngularDamping(item, 1.0)

			local	_force = Vector(0,0,0)
			_force += (position_dt.Normalize().Scale(-distance_dt) - velocity.Scale(inertia))

			if (velocity.Len() > max_speed)
				_force -= velocity.Normalize().Scale(velocity.Len() - max_speed)

			local	side_ramp = RangeAdjust(Clamp(current_dist_to_player, distance_to_player * 0.5, distance_to_player * 1.5), distance_to_player * 0.5, distance_to_player * 1.5, 0.0, 1.0)
			_force += sideway_vector.Scale(side_ramp * strength * 0.5)

			_force = _force.Scale(strength)

			ItemApplyLinearForce(item, _force)
		}
		else
		{
			ItemSetLinearDamping(item, 0.2)
			ItemSetAngularDamping(item, 0.2)
		}
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

class	EnemyGenerator
{
/*<
	<Parameter =
		<spawn_frequency = <Name = "Spawn frequency (Hz)"> <Type = "Float"> <Default = 15.0>>
		<enemy_name = <Name = "Enenmy item name"> <Type = "String"> <Default = "original_enemy_0">>
	>
>*/

	spawn_frequency			=	15.0
	spawn_timeout			=	0.0
	player_script			=	0

	enemy_name				=	"original_enemy_0"
	original_enemy			=	0

	pos_y					=	0

	position				=	0

	function	OnSetup(item)
	{
		if (player_script == 0)
			player_script = ItemGetScriptInstance(SceneFindItem(g_scene, "player"))

		original_enemy = SceneFindItem(g_scene, enemy_name)
		pos_y = ItemGetPosition(original_enemy).y

		position = ItemGetPosition(item)
		position.y = pos_y

		if (spawn_frequency <= 0.0)
			spawn_frequency = 1.0
	}

	function	OnUpdate(item)
	{
		Spawn()
	}

	function	Spawn()
	{
		local	_spawn_time_interval = 1.0 / spawn_frequency

		if (original_enemy != 0 && g_clock - spawn_timeout > SecToTick(_spawn_time_interval))
		{
			local	_new_enemy = SceneDuplicateItem(g_scene, original_enemy)
			ItemRenderSetup(_new_enemy, g_factory)
			SceneSetupItem(g_scene, _new_enemy)

			ItemGetScriptInstance(_new_enemy).Spawn(position)

			spawn_timeout = g_clock
		}
	}
}
