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
		print("BossPart::OnSetup()")
		ItemPhysicSetLinearFactor(item, Vector(0,0,0))
		ItemPhysicSetAngularFactor(item, Vector(0,1,0))

		ItemSetLinearVelocity(item, Vector(0,0,0))
		ItemSetLinearDamping(item, 0.0)
		ItemSetAngularDamping(item, 0.0)
	}

	function	OnSetupDone(item)
	{
		AutoLink(item)
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
				_previous_item = SceneFindItem(g_scene, "boss_head")
				tail_padding = Mtr(1.5)
			}
			else
			{
				_previous_item = SceneFindItem(g_scene, "boss_tail_" + (tail_index - 1).tostring())
			}

			//	print("BossPart::AutoLink() creating contraint between " + ItemGetName(_previous_item) + " and " + ItemGetName(item) + ".")

			SceneAddPointConstraint(g_scene, "constraint_" + tail_index.tostring(), item, _previous_item, Vector(tail_padding,0,0), Vector(-tail_padding,0,0))
		}
	}
}


/*!
	@short	Boss
	@author	astrofra
*/
class	Boss	extends BossPart
{
	boss_item_list		=	0
	first_update_done	=	false

	function	OnSetup(item)
	{
		base.OnSetup(item)
		boss_item_list = []
	}

	function	OnSetupDone(item)
	{
		first_update_done = true
		boss_item_list.append(item)
		foreach(_item in SceneGetItemList(g_scene))
			if (_item != null && ItemGetName(_item) != null && ItemGetName(_item).find("boss_tail_") != null)
				boss_item_list.append(_item)

		print("Boss::OnSetupDone() found " + boss_item_list.len().tostring() + " items in the boss rig.")
		GoToSleep(item)
	}

	function	GoToSleep(item)
	{
		foreach(_item in boss_item_list)
		{
			ItemSetLinearVelocity(_item, Vector(0,0,0))
			ItemSetLinearDamping(_item, 0.0)
			ItemSetAngularDamping(_item, 0.0)
		}
	}

	function	WakeUp(item)
	{
		foreach(_item in boss_item_list)
		{
			ItemSetLinearDamping(_item, 1.0)
			ItemSetAngularDamping(_item, 1.0)
			ItemPhysicSetLinearFactor(_item, Vector(1,0,1))
			ItemPhysicSetAngularFactor(_item, Vector(0,1,0))
			ItemWake(_item)
		}
	}

	function	OnUpdate(item)
	{
	}
}
