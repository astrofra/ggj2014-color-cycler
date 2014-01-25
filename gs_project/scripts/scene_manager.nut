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
	game_over			=	0

	dispatch			=	0

	player_script		=	0

	wave				=	0

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

		game_over = Label(ui, 1280, 512, (1280 - 1280) * 0.5, (960 - 512) * 0.5)
		game_over.label = "COLORCYCLER\nIS OVER"
		game_over.label_color = 0xffffffff
		game_over.font = "visitor1"
		game_over.font_size = 190
		game_over.refresh()
		SpriteSetOpacity(game_over.window, 0.0)

		if (player_script == 0)
			player_script = ItemGetScriptInstance(SceneFindItem(g_scene, "player"))
	}

	function	OnSetupDone(scene)
	{
		EndGame()
	}

	function 	EndGame()
	{
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
		foreach(_item in SceneGetItemList(scene))
			if (_item != null && ObjectIsValid(_item) && ItemGetName(_item) != null && (ItemGetName(_item) == "enemy_generator_" + wave.tostring()))
				if (ItemGetScriptInstanceCount(_item) > 0)
				{
					local	_script = ItemGetScriptInstance(_item)
					_script.enable = true
				}
	}
}
