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
	pad_heading			=	0
	velocity			=	0
	angular_velocity	=	0
	vector_front		=	0

	direction_item		=	0
	angle				=	0
	direction_overide	=	0.0

	item_matrix			=	0

	strength			=	100.0
	angular_strength	=	5.0

	function	OnSetup(item)
	{
		ItemPhysicSetLinearFactor(item, Vector(1,0,1))
		ItemPhysicSetAngularFactor(item, Vector(0,1,0))

		ItemSetLinearDamping(item, 0.1)
		ItemSetAngularDamping(item, 0.5)

		pad_vector = Vector(0,0,0)
		pad_heading = Vector(0,0,0)
		velocity = Vector(0,0,0)
		angular_velocity = Vector(0,0,0)
		vector_front = Vector(0,0,1)
		item_matrix = ItemGetMatrix(item)

		pad_device = GetInputDevice("xinput0")

		direction_item = ItemGetChild(item, "player_direction")
	}

	function	OnUpdate(item)
	{
		if (pad_device != 0)
		{
			pad_vector.x = DeviceInputValue(pad_device, DeviceAxisX)
			pad_vector.z = DeviceInputValue(pad_device, DeviceAxisY)
			pad_heading.x = DeviceInputValue(pad_device, DeviceAxisS)
			pad_heading.z = DeviceInputValue(pad_device, DeviceAxisT)
		}

		if (fabs(pad_heading.z) > 0.0)
			direction_overide = Clamp(direction_overide + g_dt_frame, 0.0, 1.0)
		else
			direction_overide = Clamp(direction_overide - g_dt_frame, 0.0, 1.0)

		angle = Vector(0,0,1).AngleWithVector(pad_vector) * ((Vector(0,0,1).Cross(pad_vector)).y < 0.0?-1.0:1.0)
		ItemSetRotation(direction_item, Vector(0, angle, 0))

		DumpVector(pad_vector, "pad_vector")
		print("angle = " + angle)
	}

	function	OnPhysicStep(item, dt)
	{
		local	_force = Vector(0,0,0)
		local	_angular_force = Vector(0,0,0)

		velocity = ItemGetLinearVelocity(item)
		angular_velocity = ItemGetAngularVelocity(item)
		item_matrix = ItemGetMatrix(item)

		_force = pad_vector - velocity.Scale(0.25)
		_force = _force.Scale(strength)

//		_angular_force = pad_heading.x - angular_velocity.y * 0.25

		ItemApplyLinearForce(item, _force)
//		ItemApplyTorque(item, Vector(0,_angular_force * PI * angular_strength,0))
		
	}
}
