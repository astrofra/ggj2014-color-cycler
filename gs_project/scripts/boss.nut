/*
	File: scripts/boss.nut
	Author: astrofra
*/

Include("scripts/utils.nut")
Include("scripts/enemy.nut")

/*!
	@short	Boss
	@author	astrofra
*/
class	BossPart	extends EnemyHandler
{
	parent_position		=	0
	previous_item		=	0
	awaken				=	false
	died				=	false

	function	OnSetup(item)
	{
		if ("OnSetup" in base)
			base.OnSetup(item)

		print("BossPart::OnSetup()")
		ItemPhysicSetLinearFactor(item, Vector(0,0,0))
		ItemPhysicSetAngularFactor(item, Vector(0,1,0))

		ItemSetLinearVelocity(item, Vector(0,0,0))
		ItemSetLinearDamping(item, 0.0)
		ItemSetAngularDamping(item, 0.0)

		parent_position = LinearFilter(Irand(30,120))
		awaken = false
	}

	function	OnSetupDone(item)
	{
		if ("OnSetupDone" in base)
			base.OnSetupDone(item)

		AutoLink(item)
	}

	function	OnUpdate(item)
	{
		if (died)
			return

		if ("OnUpdate" in base)
			base.OnUpdate(item)

		if (!awaken)
			return

		if (!previous_item)
			return

		if (!ObjectIsValid(previous_item))
		{
			SceneGetScriptInstance(g_scene).WinGame()
			died =	true
			return
		}

		parent_position.SetNewValue(ItemGetWorldPosition(previous_item))
		local	dt_pos = parent_position.GetFilteredValue() - ItemGetWorldPosition(previous_item)
		dt_pos = dt_pos.Normalize().Scale(Mtr(2.0))
		dt_pos = ItemGetWorldPosition(previous_item) + dt_pos
		ItemSetPosition(item, dt_pos)
	}

	function	AutoLink(item)
	{
		local	tail_index
		local	_name = ItemGetName(item)
		local	_previous_item
		if (_name != "boss_head")
		{
			tail_index = split(_name, "_")[2].tointeger()
			//	print("BossPart::AutoLink() _idx = " + tail_index.tostring())

			local	tail_padding = Mtr(1.0)

			if (tail_index == 0)
			{
				previous_item = SceneFindItem(g_scene, "boss_head")
				tail_padding = Mtr(1.5)
			}
			else
			{
				previous_item = SceneFindItem(g_scene, "boss_tail_" + (tail_index - 1).tostring())
			}

			//	print("BossPart::AutoLink() creating contraint between " + ItemGetName(_previous_item) + " and " + ItemGetName(item) + ".")

			//	SceneAddPointConstraint(g_scene, "constraint_" + tail_index.tostring(), item, _previous_item, Vector(tail_padding,0,0), Vector(-tail_padding,0,0))
		}
	}
}


/*!
	@short	Boss
	@author	astrofra
*/
class	Boss	extends BossPart
{
	player				=	0
	player_script		=	0

	boss_item_list		=	0
	first_update_done	=	false

	dispatch			=	0

	position			=	0
	velocity			=	0
	position_dt			=	0

	inertia				=	0.3
	strength			=	10.0

	life				=	50.0
	collision_damage	=	0.25
	hit_damage			=	1.0
	bullet_speed		=	0.5
	bullet_frequency	=	5.0
	bullet_lifetime		=	5.0

	function	OnSetup(item)
	{
		if ("OnSetup" in base)
			base.OnSetup(item)

		position_dt = Vector(0,0,0)
		position = Vector(0,0,0)
		velocity = Vector(0,0,0)

		base.OnSetup(item)
		boss_item_list = []
	}

	function	OnSetupDone(item)
	{
		if ("OnSetupDone" in base)
			base.OnSetupDone(item)

		first_update_done = true
		boss_item_list.append(item)
		foreach(_item in SceneGetItemList(g_scene))
			if (_item != null && ItemGetName(_item) != null && ItemGetName(_item).find("boss_tail_") != null)
				boss_item_list.append(_item)

		print("Boss::OnSetupDone() found " + boss_item_list.len().tostring() + " items in the boss rig.")
		GoToSleep()
	}

	function	GoToSleep()
	{
		foreach(_item in boss_item_list)
		{
			ItemSetLinearVelocity(_item, Vector(0,0,0))
			ItemSetLinearDamping(_item, 0.0)
			ItemSetAngularDamping(_item, 0.0)
			ItemGetScriptInstance(_item).awaken = false
		}
	}

	function	WakeUp()
	{
		foreach(_item in boss_item_list)
		{

			ItemSetLinearDamping(_item, 1.0)
			ItemSetAngularDamping(_item, 1.0)
			ItemPhysicSetLinearFactor(_item, Vector(1,0,1))
			ItemPhysicSetAngularFactor(_item, Vector(0,1,0))
			ItemWake(_item)

			ItemGetScriptInstance(_item).awaken = true
		}

		dispatch = ChasePlayer
	}

	function	OnUpdate(item)
	{
		if ("OnUpdate" in base)
			base.OnUpdate(item)

		if (player == 0)
			player = SceneFindItem(g_scene, "player")

		if (player_script == 0)
			player_script = ItemGetScriptInstance(player)

		if (dispatch != 0)
			dispatch(item)
	}

	function	ChasePlayer(item)
	{
		position_dt =	player_script.position - ItemGetWorldPosition(item)
	}

	function	OnPhysicStep(item, dt)
	{
		if ("OnPhysicStep" in base)
			base.OnPhysicStep(item, dt)
/*
		position = ItemGetPosition(item)
		velocity = ItemGetLinearVelocity(item)
		local	distance_dt = position_dt.Len()

		local	_force = Vector(0,0,0)
		_force += (position_dt.Normalize().Scale(distance_dt) - velocity.Scale(inertia))
		_force = _force.Scale(strength)

		ItemApplyLinearForce(item, _force.Scale(ItemGetMass(item)))
*/
	}
}
