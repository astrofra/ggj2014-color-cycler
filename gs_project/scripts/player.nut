/*
	File: scripts/player.nut
	Author: astrofra
*/

Include("scripts/utils.nut")
Include("scripts/bullet.nut")
Include("scripts/music.nut")

/*

Colmask :

with mask
			WEEPP
			ABNBL
PLAYER		11100	28
PBULLET		10100	20
ENEMY		00111	7
EBULLET		10001	17
WALLS		01011	11	

group mask
PLAYER		00001	1
PBULLET		00010	2
ENEMY		00100	4
EBULLET		01000	8
WALLS		10000	16
*/

g_color_list	<-	[Vector(1,0.1,0), Vector(0.1,1,0.1), Vector(0,0.1,1)]

/*!
	@short	Player
	@author	astrofra
*/
class	Player
{
/*<
	<Parameter =
		<strength = <Name = "Motion strength"> <Type = "Float"> <Default = 100.0>>
		<inertia = <Name = "Motion inertia [0.0, 1.0]"> <Type = "Float"> <Default = 0.25>>
		<bullet_speed = <Name = "Bullet speed"> <Type = "Float"> <Default = 1.0>>
		<bullet_frequency = <Name = "Bullet frequency (Hz)"> <Type = "Float"> <Default = 15.0>>
		<color_switch_timeout = <Name = "Color switch timeout (sec)"> <Type = "Float"> <Default = 1.0>>
	>
>*/
	keyboard_device		=	0
	pad_device			=	0
	pad_vector			=	0
	pad_heading			=	0

	position			=	0
	velocity			=	0
	angular_velocity	=	0
	vector_front		=	0
	vector_pad_overide	=	0.0

	direction_item		=	0
	angle				=	0
	direction			=	0
	direction_overide	=	0.0

	item_matrix			=	0

	inertia				=	0.25
	strength			=	100.0
	angular_strength	=	5.0

	cannon				=	0
	bullet_speed		=	1.0
	bullet_frequency	=	15.0

	sfx_table			=	0

	life				=	0.0

	main_light				=	0
	color_index				=	1
	color_switch_timeout	=	Sec(1.0)
	color_switch_clock		=	0

	music_manager			=	0

	bullet_item_name	=	"original_bullet_player"

	function	OnSetup(item)
	{
		ItemPhysicSetLinearFactor(item, Vector(1,0,1))
		ItemPhysicSetAngularFactor(item, Vector(0,1,0))

		ItemSetLinearDamping(item, 0.9)
		ItemSetAngularDamping(item, 0.5)

		position = ItemGetPosition(item)
		pad_vector = Vector(0,0,0)
		pad_heading = Vector(0,0,0)
		velocity = Vector(0,0,0)
		angular_velocity = Vector(0,0,0)
		vector_front = Vector(0,0,1)
		item_matrix = ItemGetMatrix(item)
		direction = Vector(0,0,1)

		keyboard_device = GetKeyboardDevice()
		pad_device = GetInputDevice("xinput0")

		direction_item = ItemGetChild(item, "player_direction")

		main_light = ItemCastToLight(SceneFindItem(g_scene, "spot_light"))

		cannon = CannonHandler(bullet_item_name)
		cannon.bullet_speed = bullet_speed
 		cannon.bullet_frequency	= bullet_frequency
		RefreshPlayerColor(item)
		sfx_table = {}
		music_manager = MusicHandler()
	}

	function	ResetGame(item)
	{
		local	_spawn_pos	=	ItemGetPosition(SceneFindItem(g_scene, "player_spawnpoint"))
		ItemSetPosition(item, _spawn_pos)
		ItemPhysicResetTransformation(item, _spawn_pos, Vector(0,0,0))
		life = 100.0
		color_index = 1
		color_switch_clock = g_clock
		RefreshPlayerColor(item)
		music_manager.SelectMusic(color_index)
		RefreshHud()
		
	}

	function	RefreshPlayerColor(item)
	{
		print("Player::RefreshPlayerColor() : color_index = " + color_index.tostring())
		LightSetDiffuseColor(main_light, g_color_list[color_index])
		LightSetSpecularColor(main_light, g_color_list[color_index])
	}

	function	OnUpdate(item)
	{
		music_manager.Update()

		if (keyboard_device != 0 && DeviceIsKeyDown(keyboard_device, KeyEscape))
		{
			life = 0.0
			SceneGetScriptInstance(g_scene).EndGame()
		}

		if (life <= 0.0)
		{
			music_manager.StopAllGameMusic()
			pad_vector = pad_vector.Scale(0.5)
			pad_heading = pad_heading.Scale(0.5)
			return
		}

		if (pad_device != 0)
		{
			pad_vector.x = DeviceInputValue(pad_device, DeviceAxisX)
			pad_vector.z = DeviceInputValue(pad_device, DeviceAxisY)
			pad_heading.x = DeviceInputValue(pad_device, DeviceAxisS)
			pad_heading.z = DeviceInputValue(pad_device, DeviceAxisT)

			if (!DeviceWasKeyDown(pad_device, KeyButton0) && DeviceIsKeyDown(pad_device, KeyButton0))
			{
				if (g_clock - color_switch_clock > SecToTick(color_switch_timeout))
				{
					color_index++
					if (color_index >= g_color_list.len())
						color_index = 0

					RefreshPlayerColor(item)
					music_manager.SelectMusic(color_index)

					UISetCommandList(SceneGetUI(g_scene), "globalfade 0,0;globalfade 0.01,0.5;globalfade 0.5,0.0;globalfade 0,0;")

					color_switch_clock = g_clock
				}
			}
		}

		if (pad_vector.Len() > 0.0)
			vector_pad_overide = Clamp(vector_pad_overide + 10.0 * g_dt_frame, 0.0, 1.0)
		else
			vector_pad_overide = Clamp(vector_pad_overide - 5.0 * g_dt_frame, 0.0, 1.0)

		if (pad_heading.Len() > 0.0)
			direction_overide = Clamp(direction_overide + 10.0 * g_dt_frame, 0.0, 1.0)
		else
			direction_overide = Clamp(direction_overide - 5.0 * g_dt_frame, 0.0, 1.0)

		local	pad_lead_vector = pad_vector.Lerp(direction_overide, pad_heading)

		local	angle_from_pad_vector = Vector(0,0,1).AngleWithVector(pad_vector.Normalize()) * ((Vector(0,0,1).Cross(pad_vector.Normalize())).y < 0.0?-1.0:1.0)
		local	angle_from_pad_heading = Vector(0,0,1).AngleWithVector(pad_heading.Normalize()) * ((Vector(0,0,1).Cross(pad_heading.Normalize())).y < 0.0?-1.0:1.0)

		if ((pad_vector.Len() > 0.0) || (pad_heading.Len() > 0.0))
		{
			if (direction_overide > 0.25)
			{
				angle = angle_from_pad_heading
				direction = pad_heading.Normalize()
			}
			else
			{
				angle = angle_from_pad_vector
				direction =  pad_vector.Normalize()
			}
		}

		ItemSetRotation(direction_item, Vector(0, angle, 0))
		cannon.Update(ItemGetPosition(item), direction)
		if (pad_heading.Len() > 0.1)
			cannon.Shoot()

	//	DumpVector(pad_vector, "pad_vector")
	//	DumpVector(pad_heading, "pad_heading")
	//	print("angle = " + angle)
	}

	function	OnPhysicStep(item, dt)
	{
		local	_force = Vector(0,0,0)
		local	_angular_force = Vector(0,0,0)

		position = ItemGetPosition(item)

		velocity = ItemGetLinearVelocity(item)
		angular_velocity = ItemGetAngularVelocity(item)
		item_matrix = ItemGetMatrix(item)

		_force = pad_vector - velocity.Scale(Clamp(inertia, 0.0, 1.0))
		_force = _force.Scale(strength)

//		_angular_force = pad_heading.x - angular_velocity.y * 0.25

		ItemApplyLinearForce(item, _force)
//		ItemApplyTorque(item, Vector(0,_angular_force * PI * angular_strength,0))
		
	}

	function	Hit(_damage = 1.0)
	{
		if (life <= 0.0)
			return

		print("Player::Hit() !!!!")
		life -= _damage
		RefreshHud()
		print("Player::Hit() life = " + life.tostring())

		if (life <= 0.0)
			SceneGetScriptInstance(g_scene).EndGame()
	}

	function	RefreshHud()
	{
		SceneGetScriptInstance(g_scene).SetLifeBar(life.tofloat())
	}

	function	HearSfxFromLocation(_sound_filename = "", _pos = Vector(0,0,0), far_distance = Mtr(15.0), sound_volume = 1.0)
	{
		local	near_distance = Mtr(5.0)

		if (_sound_filename != "" && FileExists(_sound_filename))
		{
			if (!(SHA1(_sound_filename) in sfx_table))
				sfx_table.rawset(SHA1(_sound_filename), ResourceFactoryLoadSound(g_factory, _sound_filename))

			local	_dist = _pos.Dist(position)
			local	_chan = MixerPlaySound(g_mixer, sfx_table[SHA1(_sound_filename)])
			local	_vol = Clamp(RangeAdjust(_dist, near_distance, far_distance, sound_volume, 0.0), 0.0, sound_volume)
			MixerChannelSetGain(g_mixer, _chan, _vol)
			MixerChannelSetLoopMode(g_mixer, _chan, LoopNone)
			MixerChannelSetPitch(g_mixer, _chan, Rand(0.8, 1.2))
		}
	}
}
