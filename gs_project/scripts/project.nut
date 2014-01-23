/*
*/

class	ProjectHandler
{
	reload					=	false
	scene_filename			=	"scenes/preloader.nms"
	scene					=	0

	function	OnSetup(project)
	{
		print("ProjectHandler::OnSetup()")

		RendererRegistrySetKey(g_render, "VSync:Enable", true)

		reload = true
		LoadScene(project)
	}

	function	OnUpdate(project)
	{
		if (reload)
			LoadScene(project)
	}

	function	LoadScene(project)
	{
		local	prev_scene = scene

		if (FileExists(scene_filename))
		{
			print("ProjectHandler::LoadScene('" + scene_filename + "')")
			scene = ProjectInstantiateScene(project, scene_filename)
			ProjectAddLayer(project, scene, 0.5)
		}
		else
			error("ProjectHandler::OnSetup() Could not find '" + scene_filename + "'.")

		if (prev_scene != 0)	ProjectUnloadScene(project, prev_scene)

		reload = false
	}

	function	LoadDemo()
	{
		UISetGlobalFadeEffect(SceneGetUI(g_scene), 1.0)	//	Fade out the whole screen
		scene_filename = "scenes/main_scene.nms"
		reload = true
	}
}
