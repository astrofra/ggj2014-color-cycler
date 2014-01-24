class	SoundEmitter
{
/*<
	<Parameter =
		<filename = <Name = "Filename"> <Description = "Path relative to the project root."> <Type = "String"> <Default = "sound.wav">>
		<loop_enabled = <Name = "Loop sound."> <Type = "Bool"> <Default = True>>
		<sound_volume = <Name = "Volume scale"> <Type = "Float"> <Default = 1.0>>
		<pitch_random = <Name = "Pitch Rand."> <Type = "Float"> <Default = 0.1>>
		<fade_enabled = <Name = "Fade in distance."> <Type = "Bool"> <Default = False>>
		<near_distance = <Name = "Near distance (m)"> <Type = "Float"> <Default = 10.0>>
		<far_distance = <Name = "Far distance (m)"> <Type = "Float"> <Default = 50.0>>
		<receptor_item = <Name = "Receptor Item"> <Type = "String"> <Default = "player">>
	>
>*/

	filename		=	0
	loop_enabled	=	0
	sound_volume	=	1.0
	pitch_random	=	0.1
	fade_enabled	=	0
	near_distance	=	Mtr(10.0)
	far_distance	=	Mtr(50.0)
	receptor_item	=	"player"

	sfx_mixer		=	0
	sfx_channel		=	-1
	sfx_sample		=	0

	function	OnSetup(item)
	{
		//	Make sure the sound does exist
		if (!FileExists(filename))
		{
			print("SoundEmitter::Cannot find : " + filename)
			return
		}

		receptor_item = SceneFindItem(g_scene, receptor_item)

		//	Cast values to the proper Float type.
		sound_volume = sound_volume.tofloat()
		near_distance	=	near_distance.tofloat()
		far_distance	=	far_distance.tofloat()
		pitch_random	=	pitch_random.tofloat() * Rand(0.5, 1.0) * (Rand(0.0,100.0) < 50.0?-1.0:1.0)
		print("SoundEmitter::OnSetup() pitch_random = " + pitch_random.tostring())

		//	Allocate a channel & load the audio file.
		sfx_mixer = EngineGetMixer(g_engine)
		sfx_channel = MixerChannelLock(sfx_mixer)
		sfx_sample = EngineLoadSound(g_engine, filename)
		MixerChannelStart(sfx_mixer, sfx_channel, sfx_sample)
		MixerChannelSetLoopMode(sfx_mixer, sfx_channel, LoopRepeat)
		MixerChannelSetGain(sfx_mixer, sfx_channel, sound_volume)
		MixerChannelSetPitch(sfx_mixer, sfx_channel, 1.0 + pitch_random)
		
		print("SoundEmitter::Playing sound (" + filename + "), 'Loop' is " + (loop_enabled?"enabled":"disabled") + ", 'Fade in distance' is " + (fade_enabled?"enabled":"disabled") + ".")
	}

	function	OnUpdate(item)
	{
		if (sfx_channel == -1)
			return

		if (!fade_enabled)
			return

		//	Ramp the volume according to the distance between the current camera & the sound emitter.
		local	_current_pos = ItemGetWorldPosition(receptor_item)
		local	_dist = _current_pos.Dist(ItemGetWorldPosition(item))
		local	_vol = Clamp(RangeAdjust(_dist, near_distance, far_distance, sound_volume, 0.0), 0.0, sound_volume)
		MixerChannelSetGain(sfx_mixer, sfx_channel, _vol)	
	}

	function	OnDelete(item)
	{
		//	De-allocate the channel if the item is deleted.
		if (sfx_channel != 0)
			MixerChannelUnlock(sfx_mixer, sfx_channel)
	}
}
