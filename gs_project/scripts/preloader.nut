/*
	File: scripts/preloader.nut
	Author: Astrofra
*/

Include("scripts/scene_manager.nut")

/*!
	@short	Preload
	@author	Astrofra
*/
class	Preload
{
	
	object_list = [
"assets/grid.png"
"assets/logo_seal.png"
"assets/star.png"
"assets/logo_reflexion.png"
"ui/fonts/homenaje-regular.ttf"
"ui/fonts/dosis.book.ttf"
"SubTitleSetupTitle"
"SubTitleSetupMainSub"
"SubTitleSetupMachineTitle"
"audio/apple2_boot.ogg",
"audio/gameboy_boot.ogg",
"audio/med_music.ogg",
"assets/background.png"
"assets/background.nmg"
"assets/black.nmm"
"assets/computer.nmg"
"assets/computer_edge.nmg"
"assets/computer_screen.nmg"
"assets/computer_shadow.nmg"
"assets/gameboy.nmg"
"assets/gameboy_controls.nmg"
"assets/gameboy_edge.nmg"
"assets/gameboy_screen.nmg"
"assets/gameboy_screen_on.nmg"
"assets/logo_emucamp.nmg"
"assets/plane_grid.nmg"
"assets/seal.nmg"
"assets/star.nmg"
	]

	current_object		=	0
	progress			=	0
	preloading			=	true
	ui					=	0
	bar					=	0

	toggle				=	false

	scene_manager		=	0

//object_list = []

	function	OnSetup(scene)
	{
		print("Preload::OnSetup()")
		current_object	=	0
		ui	=	SceneGetUI(scene)
		
		local	_preloader_back_texture, _preloader_bar_texture, _w, _h
		_preloader_bar_texture = EngineLoadTexture(g_engine, "ui/loader_bar.png")

		_w = 480
		_h = 4

		local	_back = UIAddSprite(ui, -1, _preloader_bar_texture, (1280 - _w) * 0.5, (960 - _h) * 0.5, _w, _h)
		SpriteSetScale(_back, 1.0, 1.0)
		SpriteSetOpacity(_back, 0.45)

		bar = UIAddSprite(ui, -1, _preloader_bar_texture, (1280 - _w) * 0.5, (960 - _h) * 0.5, _w, _h)
		SpriteSetScale(bar, 1.0, 0.5)

		scene_manager = SceneManager()
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
			if (current_object < object_list.len())
			{
				if (FileExists(object_list[current_object]))
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
				else
				{
					if (object_list[current_object].find("SubTitleSetup") != null)
						scene_manager[object_list[current_object]]()
				}
				
			}
			else
			{
				ProjectGetScriptInstance(g_project).LoadDemo()
//				UISetCommandList(SceneGetUI(scene), "globalfade 0,1;")
				preloading = false
			}

			current_object++
		}
	}

}
