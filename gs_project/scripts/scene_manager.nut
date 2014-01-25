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
	ui			=	0
	life_bar	=	0
	game_over	=	0

	dispatch	=	0

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

		game_over = Label(ui, 1024, 256, (1280 - 1024) * 0.5, (960 - 256) * 0.5)
		game_over.label = "OVER"
		game_over.label_color = 0xffffffff
		game_over.font = "visitor1"
		game_over.font_size = 256
		game_over.refresh()
		SpriteSetOpacity(game_over.window, 0.0)
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

	function	WaitForGameRestart(scene)
	{
//		if (false)
	}
}
