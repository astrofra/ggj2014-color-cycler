/*
	File: scripts/camera.nut
	Author: astrofra
*/

Include("scripts/utils.nut")

/*!
	@short	CameraHandler
	@author	astrofra
*/
class	CameraHandler
{
	y_pos				=	0.0
	target_item			=	0
	target_pos			=	0
	filtered_target_pos	=	0

	function	OnSetup(item)
	{
		y_pos = ItemGetPosition(item).y
		target_item = SceneFindItem(g_scene, "player")
		target_pos = ItemGetPosition(target_item)
		filtered_target_pos = LinearFilter(120)
	}

	function	OnUpdate(item)
	{
		if (target_item == 0)
			return

		filtered_target_pos.SetNewValue(ItemGetPosition(target_item))
		local	_pos = filtered_target_pos.GetFilteredValue()
		_pos.y = y_pos
		ItemSetPosition(item, _pos)
	}

}
