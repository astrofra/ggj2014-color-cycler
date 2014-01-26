/*
	File: scripts/preloader.nut
	Author: Astrofra
*/

/*!
	@short	Preload
	@author	Astrofra
*/
class	Preload
{
	
	object_list = [
		"assets/boss_head.nmg"
"assets/boss_tail.nmg"
"assets/boss_torax.nmg"
"assets/bullet.nmg"
"assets/bullet_player.nmg"
"assets/cube.nmg"
"assets/enemy.nmg"
"assets/enemy_0.nmg"
"assets/enemy_1.nmg"
"assets/enemy_2.nmg"
"assets/plane.nmg"
"assets/plane_opaque.nmg"
"assets/player_0.nmg"
"assets/plane2.nmg"
"assets/sphere.nmg"
"audio/M_Iddleloose.ogg"
"audio/M_IddleWin.ogg"
"audio/M_Loopennemies_01.ogg"
"audio/M_Loopennemies_02.ogg"
"audio/M_Loopennemies_03.ogg"
	]

	current_object		=	0
	progress			=	0
	preloading			=	true
	ui					=	0
	bar					=	0

	toggle				=	false

	timeout				=	0

//object_list = []

	function	OnSetup(scene)
	{
		print("Preload::OnSetup()")
		current_object	=	0
		ui	=	SceneGetUI(scene)
		
		local	_logo_text=EngineLoadTexture(g_engine, "ui/LOGO5.png")
		UIAddSprite(ui, -1, _logo_text, (1280 - TextureGetWidth(_logo_text)) * 0.5, (960 - TextureGetHeight(_logo_text)) * 0.5 - 64, TextureGetWidth(_logo_text), TextureGetHeight(_logo_text))

		local	_preloader_back_texture, _preloader_bar_texture, _w, _h
		_preloader_bar_texture = EngineLoadTexture(g_engine, "ui/loader_bar.png")

		_w = 480
		_h = 4

		local	_back = UIAddSprite(ui, -1, _preloader_bar_texture, (1280 - _w) * 0.5, (960 - _h) * 0.5 + 256, _w, _h)
		SpriteSetScale(_back, 1.0, 1.0)
		SpriteSetOpacity(_back, 0.45)

		bar = UIAddSprite(ui, -1, _preloader_bar_texture, (1280 - _w) * 0.5, (960 - _h) * 0.5 + 256, _w, _h)
		SpriteSetScale(bar, 1.0, 0.5)

	}

	function	OnSetupDone(scene)
	{
		timeout=g_clock
	}

	function	OnUpdate(scene)
	{
		if (object_list.len() > 0)
			progress	=	(((object_list.len() - current_object) * 100.0) / object_list.len()).tointeger()

		progress = Clamp(100 - progress, 0.0, 100)

		WindowSetScale(bar, Clamp((progress / 100.0), 0.01, 1.0), 1.0)

		print("Preload::OnUpdate() progress = " + progress)

		toggle != toggle

		if (toggle)
			return

		if (preloading && UIIsCommandListDone(ui))
		{
			if (current_object < object_list.len() || g_clock-timeout<SecToTick(5.0))
			{
				if (current_object < object_list.len() && FileExists(object_list[current_object]))
				{
					if (object_list[current_object].find(".nmg") != null)
						ResourceFactoryLoadGeometry(g_factory, object_list[current_object])
					else
					if (object_list[current_object].find(".png") != null)
						ResourceFactoryLoadTexture(g_factory, object_list[current_object])
					else
					if (object_list[current_object].find(".jpg") != null)
						ResourceFactoryLoadTexture(g_factory, object_list[current_object])
					else
					if (object_list[current_object].find(".tga") != null)
						ResourceFactoryLoadTexture(g_factory, object_list[current_object])
					else
					if (object_list[current_object].find(".ogg") != null)
						ResourceFactoryLoadSound(g_factory, object_list[current_object])
					else
					if (object_list[current_object].find(".ttf") != null)
						UILoadFont(object_list[current_object])
				}				
			}
			else
			{
				ProjectGetScriptInstance(g_project).LoadGame()
//				UISetCommandList(SceneGetUI(scene), "globalfade 0,1;")
				preloading = false
			}

			current_object++
		}
	}

}
