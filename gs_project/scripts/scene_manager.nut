/*
	File: scripts/scene_manager.nut
	Author: astrofra
*/

Include("scripts/ui.nut")

/*!
	@short	SceneManager
	@author	astrofra
*/
class	SceneManager
{
	ui					=	0
	life_bar			=	0
	enemy_count_label	=	0
	game_over			=	0

	dispatch			=	0

	player_script		=	0

	wave				=	0
	enemy_count			=	0
	wave_label			=	0

	function	OnSetup(scene)
	{
		ui = SceneGetUI(scene)

		UILoadFont("ui/fonts/visitor1.ttf")

		local	texture = ResourceFactoryLoadTexture(g_factory, "ui/loader_bar.png")
		life_bar = UIAddSprite(ui, -1, texture, 8, 8, TextureGetWidth(texture), TextureGetHeight(texture))
		SpriteSetOpacity(life_bar, 0.5)

		local	life_label = Label(ui, TextureGetWidth(texture) * 0.35, TextureGetHeight(texture), SpriteGetPosition(life_bar).x , SpriteGetPosition(life_bar).y - 4)
		life_label.label = "LIFE"
		life_label.label_color = 0x000000ff
		life_label.font = "visitor1"
		life_label.font_size = 48
		life_label.refresh()

		enemy_count_label = Label(ui, TextureGetWidth(texture), TextureGetHeight(texture), SpriteGetPosition(life_bar).x + TextureGetWidth(texture) + 8.0, SpriteGetPosition(life_bar).y - 4)
		enemy_count_label.label = "00 ENEMY"
		enemy_count_label.label_color = 0xffffffff
		enemy_count_label.font = "visitor1"
		enemy_count_label.font_size = 48
		enemy_count_label.refresh()
		SpriteSetOpacity(enemy_count_label.window, 0.5)

		game_over = Label(ui, 1280, 512, (1280 - 1280) * 0.5, (960 - 512) * 0.5)
		game_over.label = "COLORCYCLER\nIS OVER"
		game_over.label_color = 0xffffffff
		game_over.font = "visitor1"
		game_over.font_size = 190
		game_over.refresh()
		SpriteSetOpacity(game_over.window, 0.0)

		wave_label = Label(ui, 1024, 256, (1280 - 1024) * 0.5, (960 - 256) * 0.5)
		wave_label.label = "WAVE 0"
		wave_label.label_color = 0xffffffff
		wave_label.font = "visitor1"
		wave_label.font_size = 190
		wave_label.refresh()
		SpriteSetOpacity(wave_label.window, 0.0)

		if (player_script == 0)
			player_script = ItemGetScriptInstance(SceneFindItem(g_scene, "player"))

		FreezeAllWaves()
	}

	function	OnSetupDone(scene)
	{
		dispatch = GoToStandBy
	}

	function 	EndGame()
	{
		local	_chan = MixerStartStream(g_mixer, "audio/M_Iddleloose.ogg")
		MixerChannelSetGain(g_mixer, _chan, 1.0)
		MixerChannelSetPitch(g_mixer, _chan, 1.0)
		MixerChannelSetLoopMode(g_mixer, _chan, LoopNone)
		dispatch = GoToStandBy
	}

	function	OnUpdate(scene)
	{
		if (dispatch != 0)
			dispatch(scene)
	}

	function	SetLifeBar(_life)
	{
		SpriteSetScale(life_bar, _life / 100.0, 1.0)
	}

	function	GoToStandBy(scene)
	{
		UISetCommandList(ui, "nop 2.0;globalfade 1.0, 0.5;")
		WindowSetCommandList(game_over.window, "toalpha 0,0;toalpha 0.25,1;")
		dispatch = StandBy
	}

	function	StandBy(scene)
	{
		dispatch = WaitForGameRestart
	}

	function	ResetGame(scene)
	{
		UISetCommandList(ui, "globalfade 0.1,0.0;")
		WindowSetCommandList(game_over.window, "toalpha 0,0.25;toalpha 0.1,0.0;")
		player_script.ResetGame(SceneFindItem(g_scene, "player"))
		WipeAllEnemies(scene)
		StartWave()
		wave = 0
		dispatch = 0
	}

	function	WipeAllEnemies(scene)
	{
		foreach(_item in SceneGetItemList(scene))
			if (_item != null && ObjectIsValid(_item) && ItemGetName(_item) != null && (ItemGetName(_item) == "new_enemy" || ItemGetName(_item) == "new_bullet"))
				SceneDeleteItem(scene, _item)

		SceneFlushDeletionQueue(scene)
	}

	function	WaitForGameRestart(scene)
	{
		if (player_script != 0)
			if (player_script.pad_device != 0)
				if (DeviceKeyPressed(player_script.pad_device, KeyButton0))
					dispatch = ResetGame
	}

	function	StartWave()
	{
		wave_label.label = "WAVE #" + wave.tostring()
		wave_label.refresh()
		WindowSetCommandList(wave_label.window, "toalpha 0,0;toalpha 0.2,1.0;nop 0.25;toalpha 0.2,0.0;")

		enemy_count = 0
		foreach(_item in SceneGetItemList(g_scene))
			if (_item != null && ObjectIsValid(_item) && ItemGetName(_item) != null && (ItemGetName(_item) == "enemy_generator_" + wave.tostring()))
				if (ItemGetScriptInstanceCount(_item) > 0)
				{
					local	_script = ItemGetScriptInstance(_item)
					_script.generator_enabled = true
					enemy_count += _script.wave_size
				}

		RefreshEnemyCount()
	}

	function	FreezeAllWaves()
	{
		foreach(_item in SceneGetItemList(g_scene))
			if (_item != null && ObjectIsValid(_item) && ItemGetName(_item) != null && (ItemGetName(_item).find("enemy_generator_") != null))
				if (ItemGetScriptInstanceCount(_item) > 0)
				{
					local	_script = ItemGetScriptInstance(_item)
					_script.generator_enabled = false
				}
	}

	function	DecreaseEnemyCount()
	{
		enemy_count--
		RefreshEnemyCount()
	}

	function	RefreshEnemyCount()
	{
		enemy_count_label.label = enemy_count.tostring() + (enemy_count > 1?" ENEMIES":" ENEMY")
		enemy_count_label.refresh()
	}
}
