/*
	File: scripts/base_scene.nut
	Author: Astrofra
*/

/*!
	@short	BaseScene
	@author	Astrofra
*/
class	BaseScene
{
	render_user_callback	=	0

	dt_history				=	0
	dt_stability_iterations	=	0

	dispatch				=	0
	dispatch_next			=	0

	//	Save option
	save_to_video			=	false
	filename_base			=	0
	save_picture 			= 	0
	save_frame_idx			=	0

	function	OnRenderUser(scene)
	{
		RendererSetIdentityWorldMatrix(g_render)

		foreach(_callback in render_user_callback)
			_callback["RenderUser"](scene)
	}

	function	OnSetup(scene)
	{
		print("BaseScene::OnSetup()")

		render_user_callback = []
		dt_history = []
		dt_stability_iterations = 0
		if (save_to_video)
		{
			print("BaseScene::OnUpdate() Save Enabled.")
			filename_base = "frame"
			save_frame_idx = 0
			SceneSetFixedDeltaFrame(scene, 1.0 / 60.0)
			save_picture = PictureNew()
		}
	}

	function	OnUpdate(scene)
	{
		UpdateDtHistory()

		if (save_to_video)
			SaveCurrentFrameToTGA()
	}

	/*!
		@short	SaveCurrentFrameToTGA
		Save the current frame to a TGA file, ++ the index of the current frame.
		Use this to prepare a demonstration video file.
	*/
	function	SaveCurrentFrameToTGA()
	{
		RendererGrabDisplayToPicture(g_render, save_picture)
		local frame_idx = save_frame_idx.tostring()
		if (save_frame_idx < 10)		frame_idx = "0" + frame_idx
		if (save_frame_idx < 100)		frame_idx = "0" + frame_idx
		if (save_frame_idx < 1000)		frame_idx = "0" + frame_idx
		if (save_frame_idx < 10000)		frame_idx = "0" + frame_idx
		PictureSaveJPG(save_picture, "video/" + filename_base + "_" + frame_idx + ".jpg")
		save_frame_idx++
	}

	function	UpdateDtHistory()
	{
		dt_history.append(g_dt_frame)

		if (dt_history.len() > 30)
			dt_history.remove(0)
	}

	/*
	*/
	function	CheckDtFrameStability(scene)
	{

		if (dt_history.len() >= 21)
		{
			local	dt_median = clone(dt_history)
			dt_median.sort()
			dt_median = dt_median.slice(7,14)

			local	_sum = 0.0
			foreach(_dt in dt_median)
				_sum += _dt

			local	_avg_dt = _sum / (dt_median.len().tofloat())

			if (save_to_video)
				dispatch = dispatch_next
			else
			if (_avg_dt <= (g_dt_frame * 1.25))
			{
				print("BaseScene::CheckDtFrameStability(), " + dt_stability_iterations + " iterations, found a stable g_dt_frame = " + g_dt_frame)
				dispatch = dispatch_next
			}
			else
			if (dt_stability_iterations > 120)
			{
				print("BaseScene::CheckDtFrameStability() stability timeout, g_dt_frame = " + g_dt_frame)
				dispatch = dispatch_next
			}
		}

		dt_stability_iterations++
	}
}
