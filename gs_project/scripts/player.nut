/*
	File: scripts/player.nut
	Author: astrofra
*/

Include("scripts/utils.nut")

/*!
	@short	Player
	@author	astrofra
*/
class	Player
{

	pad_device			=	0
	pad_vector			=	0

	function	OnSetup(item)
	{
		ItemPhysicSetLinearFactor(item, Vector(1,0,1))
		ItemPhysicSetAngularFactor(item, Vector(0,1,0))

		ItemSetLinearDamping(item, 0.1)

		pad_vector = Vector(0,0,0)

		pad_device = GetInputDevice("xinput0")
	}

	function	OnUpdate(item)
	{
		if (pad_device != 0)
		{
			pad_vector.x = DeviceInputValue(pad_device, DeviceAxisX)
			pad_vector.z = DeviceInputValue(pad_device, DeviceAxisY)
		}

		DumpVector(pad_vector, "pad_vector")
	}

	function	OnPhysicStep(item, dt)
	{
	}
}
