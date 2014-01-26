/*
	File: scripts/music.nut
	Author: astrofra
*/

/*!
	@short	MusicHandler
	@author	astrofra
*/
class	MusicHandler
{
	music_table		=	0
	gain_table		=	0
	music_index		=	-1

	constructor()
	{
		local	m_file = ["audio/M_Loopennemies_01.ogg","audio/M_Loopennemies_02.ogg","audio/M_Loopennemies_03.ogg"]

		music_table		=	[]
		gain_table		=	[]

		foreach(_m in m_file)
		{
			if (FileExists(_m))
			{
				local	_chan = MixerStartStream(g_mixer, _m)
				MixerChannelSetGain(g_mixer, _chan, 0.0)
				MixerChannelSetPitch(g_mixer, _chan, 1.0)
				MixerChannelSetLoopMode(g_mixer, _chan, LoopRepeat)
				music_table.append(_chan)
				gain_table.append(0.0)
			}
		}
	}

	function	StopAllGameMusic()
	{
		music_index = -1
	}

	function	SelectMusic(_index)
	{
		music_index = _index
	}

	function	Update()
	{
		if (music_table.len() < 3)
			return

		foreach(_idx, _chan in music_table)
		{
			if (music_index < 0)
				gain_table[_idx] = Clamp(gain_table[_idx] - 5.0 * g_dt_frame, 0.0, 1.0)
			else
			{
				if (music_index == _idx)
					gain_table[_idx] = Clamp(gain_table[_idx] + g_dt_frame, 0.0, 1.0)
				else
					gain_table[_idx] = Clamp(gain_table[_idx] - g_dt_frame, 0.0, 1.0)
			}

			MixerChannelSetGain(g_mixer, _chan, gain_table[_idx])
		}
	}
}
