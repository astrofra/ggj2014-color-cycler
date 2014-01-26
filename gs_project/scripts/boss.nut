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
		ItemPhysicSetLinearFactor(item, Vector(1,0,1))
		ItemPhysicSetAngularFactor(item, Vector(0,1,0))
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
			print("BossPart::AutoLink() _idx = " + tail_index.tostring())

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

			print("BossPart::AutoLink() creating contraint between " + ItemGetName(_previous_item) + " and " + ItemGetName(item) + ".")

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
	
}
