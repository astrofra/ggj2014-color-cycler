/*
	File: scripts/enemy.nut
	Author: astrofra
*/

Include("scripts/bullet.nut")

/*!
	@short	EnemyHandler
	@author	astrofra
*/
class	EnemyHandler
{
/*<
	<Parameter =
		<invisible_color = <Name = "Invisible color"> <Type = "Float"> <Default = 0.0>>
		<distance_to_player = <Name = "Distance to player (m)"> <Type = "Float"> <Default = 5.0>>
		<shooting_range = <Name = "Shooting range (m)"> <Type = "Float"> <Default = 5.0>>
		<distance_rand = <Name = "Distance randomize (m)"> <Type = "Float"> <Default = 1.0>>
		<max_speed = <Name = "Max speed (mtrs)"> <Type = "Float"> <Default = 5.0>>
		<life = <Name = "Enemy life"> <Type = "Float"> <Default = 10.0>>
		<strength = <Name = "Force strength"> <Type = "Float"> <Default = 10.0>>
		<inertia = <Name = "Force inertia"> <Type = "Float"> <Default = 0.25>>
		<collision_damage = <Name = "Collision damage"> <Type = "Float"> <Default = 0.25>>
		<hit_damage = <Name = "Bullet hit damage"> <Type = "Float"> <Default = 1.0>>
		<bullet_speed = <Name = "Bullet speed"> <Type = "Float"> <Default = 0.5>>
		<bullet_frequency = <Name = "Bullet frequency (Hz)"> <Type = "Float"> <Default = 5.0>>
		<bullet_lifetime = <Name = "Bullet life (sec)"> <Type = "Float"> <Default = 5.0>>
	>
>*/
	player				=	0
	player_script		=	0
	dispatch			=	0
	awaken				=	false
	dying				=	false
	invisible_color		=	0

	body				=	0
	body_mat			=	0

	position			=	0
	direction			=	0
	position_dt			=	0
	velocity			=	0
	sideway_vector		=	0

	initial_position_dt	=	0
	initial_distance_to_player	=	0
	distance_rand		=	1.0

	current_dist_to_player	=	0
	distance_to_player	=	Mtr(5.0)
	shooting_range		=	Mtr(5.0)
	distance_dt			=	0.0
	strength			=	1.0
	inertia				=	0.25
	max_speed			=	5.0

	life				=	10.0

	collision_damage	=	0.25
	hit_damage			=	1.0

	cannon				=	0
	bullet_speed		=	0.5
	bullet_frequency	=	5.0

	bullet_lifetime		=	Sec(5.0)
	previous_enemy		=	0

	bullet_item_name	=	"original_bullet_enemy"

	function	OnSetup(item)
	{
		body = item
		player = SceneFindItem(g_scene, "player")

		ItemPhysicSetLinearFactor(item, Vector(1,0,1))
		ItemPhysicSetAngularFactor(item, Vector(0,1,0))

		position_dt = Vector(0,0,0)
		initial_position_dt = Vector(0,0,0)
		sideway_vector = Vector(0,0,0)
		direction = Vector(0,0,0)

		velocity = Vector(0,0,0)
		position = ItemGetPosition(item)

		cannon = CannonHandler(bullet_item_name)
		cannon.bullet_speed = bullet_speed
 		cannon.bullet_frequency	= bullet_frequency
		cannon.bullet_lifetime = bullet_lifetime

		body_mat = GeometryGetMaterialFromIndex(ItemGetGeometry(item), 0)

		//	Spawn(position)
	}

	function	OnCollision(item, with_item)
	{
		//	print("BulletHandler::OnCollision() with_item = " + ItemGetName(with_item))

		if (player_script == 0)
			player_script = ItemGetScriptInstance(SceneFindItem(g_scene, "player"))

		//	This should not happen, just in case...
		if (ObjectIsSame(with_item, body))
		{
			with_item = item
			item = body
		}

		if (with_item != null && ItemGetName(with_item) != null && ItemGetName(with_item).tolower().find("enemy") != null)
			return

		if (ItemGetScriptInstanceCount(with_item) > 0)
		{
			local	_with_item_script = ItemGetScriptInstance(with_item)
			if ("Hit" in _with_item_script)
				_with_item_script.Hit(collision_damage)
		}
	}

	function	UpdateColorVisibility(item)
	{
		if (player_script == 0)
			player_script = ItemGetScriptInstance(SceneFindItem(g_scene, "player"))

		if (invisible_color.tointeger() == player_script.color_index)
			MaterialSetAmbient(body_mat, Vector(0.05,0.05,0.05))
		else
			MaterialSetAmbient(body_mat, Vector(1,1,1))
	}

	function	Spawn(_position)
	{
		if (player_script == 0)
			player_script = ItemGetScriptInstance(SceneFindItem(g_scene, "player"))

		position = _position
		ItemSetPosition(body, position)
		ItemPhysicResetTransformation(body, position, Vector(0,0,0))
		ItemSetLinearVelocity(body, Vector(0,0,0))

		distance_to_player += Rand(-0.5, 0.5) * distance_rand

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

		sideway_vector = player_script.position - position
		sideway_vector = sideway_vector.ApplyMatrix(RotationMatrixY(Deg(90.0)))
		sideway_vector = sideway_vector.Normalize()

		if (previous_enemy != 0 && previous_enemy != null && ObjectIsValid(previous_enemy))
		{
			local	_prev_enemy_pos = ItemGetPosition(previous_enemy)
			local	_escape_dt = (position - _prev_enemy_pos).Normalize().Scale(0.5)
			sideway_vector += _escape_dt
		}

		cannon.Update(ItemGetPosition(item), (player_script.position - position).Normalize())

		if (current_dist_to_player < shooting_range && player_script.life > 0.0)
			cannon.Shoot()

		UpdateColorVisibility(item)
	}

	function	OnPhysicStep(item, dt)
	{
		position = ItemGetPosition(item)
		velocity = ItemGetLinearVelocity(item)

		if (velocity.Len() > 0.01)
			direction = velocity.Normalize()

		if (awaken)
		{
			ItemSetLinearDamping(item, 1.0)
			ItemSetAngularDamping(item, 1.0)

			local	_force = Vector(0,0,0)
			_force += (position_dt.Normalize().Scale(-distance_dt) - velocity.Scale(inertia))

			if (velocity.Len() > max_speed)
				_force -= velocity.Normalize().Scale(velocity.Len() - max_speed)

			local	side_ramp = RangeAdjust(Clamp(current_dist_to_player, distance_to_player * 0.5, distance_to_player * 1.5), distance_to_player * 0.5, distance_to_player * 1.5, 0.0, 1.0)
			_force += sideway_vector.Scale(side_ramp * strength * 0.25)

			_force = _force.Scale(strength)

			ItemApplyLinearForce(item, _force)
		}
		else
		{
			ItemSetLinearDamping(item, 0.2)
			ItemSetAngularDamping(item, 0.2)
		}
	}

	function	Hit(_damage)
	{
		if (dying)
			return

		life -= _damage

		print("EnemyHandler::Hit() !!!")

		if (life <= 0.0)
		{
			SceneGetScriptInstance(g_scene).DecreaseEnemyCount()
			dying = true
			dispatch = Explode
		}
		else
			ItemSetCommandList(body, "toscale 0.0,1.0,1.0,1.0;toscale 0.05,1.1,1.1,1.1;toscale 0.05,1.0,1.0,1.0;")
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
		<wave_size = <Name = "Amount of enemies"> <Type = "Float"> <Default = 15.0>>
		<generator_enabled = <Name = "Enable"> <Type = "Bool"> <Default = True>>
	>
>*/

	spawn_frequency			=	15.0
	spawn_timeout			=	0.0
	player_script			=	0

	enemy_name				=	"original_enemy_0"
	original_enemy			=	0

	pos_y					=	0

	position				=	0

	wave_size				=	15
	spawn_count				=	0
	generator_enabled		=	true

	previous_enemy			=	0

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

		wave_size = wave_size.tointeger()
		spawn_count = wave_size
	}

	function	OnUpdate(item)
	{
		if (player_script == 0)
			player_script = ItemGetScriptInstance(SceneFindItem(g_scene, "player"))

		if (generator_enabled && player_script.life > 0.0)
			Spawn()
	}

	function	Spawn()
	{
		local	_spawn_time_interval = 1.0 / spawn_frequency

		if (original_enemy != 0 && spawn_count > 0 && g_clock - spawn_timeout > SecToTick(_spawn_time_interval))
		{
			local	_new_enemy = SceneDuplicateItem(g_scene, original_enemy)
			ItemRenderSetup(_new_enemy, g_factory)
			SceneSetupItem(g_scene, _new_enemy)
			ItemSetName(_new_enemy, "new_enemy")

			ItemGetScriptInstance(_new_enemy).Spawn(position)
			if (previous_enemy != 0 && previous_enemy != null && ObjectIsValid(previous_enemy))
				ItemGetScriptInstance(_new_enemy).previous_enemy = previous_enemy

			spawn_timeout = g_clock
			spawn_count--

			previous_enemy = _new_enemy
		}
	}
}
