/*
	File: scripts/bullet.nut
	Author: astrofra
*/

/*!
	@short	BulletHandler
	@author	astrofra
*/
class	BulletHandler
{
	player_script	=	0
	body			=	0
	velocity		=	0
	dispatch		=	0

	hit_damage		=	1.0

	function	OnSetup(item)
	{
		body = item

		ItemPhysicSetLinearFactor(item, Vector(1,0,1))
		ItemPhysicSetAngularFactor(item, Vector(0,1,0))

		ItemSetLinearDamping(item, 0)
		ItemSetAngularDamping(item, 0)

		velocity = Vector(0,0,0)
	}

	function	OnUpdate(item)
	{
		if (dispatch != 0)
			dispatch(item)
	}

	function	OnCollision(item, with_item)
	{
		print("BulletHandler::OnCollision() with_item = " + ItemGetName(with_item))

		if (player_script == 0)
			player_script = ItemGetScriptInstance(SceneFindItem(g_scene, "player"))

		//	This should not happen, just in case...
		if (ObjectIsSame(with_item, body))
		{
			with_item = item
			item = body
		}

		if (ItemGetScriptInstanceCount(with_item) > 0)
		{
			local	_with_item_script = ItemGetScriptInstance(with_item)
			if ("Hit" in _with_item_script)
				_with_item_script.Hit(hit_damage)
		}

		dispatch = EmitHitSound
	}

	function	OnPhysicStep(item, dt)
	{
	}

	function	EmitHitSound(item)
	{
		if ("HearSfxFromLocation" in player_script)
			player_script.HearSfxFromLocation("audio/SFX_hit.wav", ItemGetPosition(item), Mtr(30.0))

		dispatch = Die
	}

	function	Die(item)
	{
		dispatch = 0
		SceneDeleteItem(g_scene, item)
	}
}

class	CannonHandler
{
	player_script	=	0
	position			=	0
	direction			=	0
	original_bullet		=	0
	cannon_len			=	Mtr(2.0)
	bullet_speed		=	1.0
	bullet_frequency	=	15
	shoot_timeout		=	0.0
	pos_y				=	Mtr(1.0)

	constructor(_bullet_item_name = "original_bullet")
	{
		if (player_script == 0)
			player_script = ItemGetScriptInstance(SceneFindItem(g_scene, "player"))

		original_bullet = SceneFindItem(g_scene, _bullet_item_name)
		pos_y = ItemGetPosition(original_bullet).y

		position = Vector(0,1,0)
		direction = Vector(0,0,1)

		if (bullet_frequency <= 0.0)
			bullet_frequency = 1.0
	}

	function	Update(_position = Vector(0,0,0), _direction = Vector(0,0,1))
	{
		position = _position
		position.y = pos_y
		direction = _direction
	}

	function	Shoot()
	{
		local	_shoot_time_interval = 1.0 / bullet_frequency

		if (g_clock - shoot_timeout > SecToTick(_shoot_time_interval) && direction.Len() > 0)
		{
			local	_new_bullet = SceneDuplicateItem(g_scene, original_bullet)
			ItemRenderSetup(_new_bullet, g_factory)
			SceneSetupItem(g_scene, _new_bullet)

			local	_pos = position + direction.Scale(cannon_len)
			ItemSetPosition(_new_bullet, _pos)
			ItemPhysicResetTransformation(_new_bullet, _pos, Vector(0,0,0))
			ItemApplyLinearImpulse(_new_bullet, direction.Normalize().Scale(bullet_speed))

			if ("HearSfxFromLocation" in player_script)
				player_script.HearSfxFromLocation("audio/SFX_lasershot.wav", position)

			shoot_timeout = g_clock
		}
	}
}
