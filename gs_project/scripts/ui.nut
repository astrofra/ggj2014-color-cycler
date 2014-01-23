
if (!("g_picture_cache" in getroottable()))
	g_picture_cache	<-	{}

/*!
	@short	Label
	Text label class.
*/
class	Label
{
	window				=	0

	texture				=	0
	picture				=	0

	label				=	"Label"
	label_color			=	0xffffffff
	label_align			=	"center"
	font				=	"default"
	font_size			=	64
	font_tracking		=	0
	font_leading		=	0
	font_vcenter		=	0

	drop_shadow			=	false
	glow				=	false
	glow_radius			=	1.0
	drop_shadow_color	=	0x000000ff

	function	refresh()
	{
		local size = WindowGetSize(window)

		local cache_uid = SHA1(label + "_" + font_size.tostring() + "_" + font + "_" + label_color.tointeger().tostring())
		print("Label::refresh() cache_uid = " + cache_uid)

		if (!(cache_uid in g_picture_cache))
		{
			print("Texture/Picture was not found in the cache. Creating a new one.")
			picture = NewPicture(size.x, size.y)
			PictureFill(picture, Vector(0, 0, 0, 0))
	
			if	(label != "")
			{
				local rect = PictureGetRect(picture)
				local parm = { size = font_size, color = label_color, align = label_align, format = "paragraph", tracking = font_tracking leading = font_leading }
	
				if	(font_vcenter)
				{
					local out_rect = TextComputeRect(rect, label, font, parm)
					rect.sy += (rect.GetHeight() - out_rect.GetHeight()) / 2.0
				}
	
				rect.sx += 2; rect.ex -= 2
	
				if	(drop_shadow)
				{
					parm.color = drop_shadow_color
					rect.sx -= 1; rect.sy += 1
					PictureTextRender(picture, rect, label, font, parm)
					rect.sx -= 1; rect.sy += 1
					PictureTextRender(picture, rect, label, font, parm)
					rect.sx += 2; rect.sy -= 2
					parm.color = label_color
				}
	
				if (glow)
				{
					parm.color = drop_shadow_color
	
					local	i
					for(i = 0; i < 360; i += 20)
					{
						rect.sx -= glow_radius * 2.0 * cos(DegreeToRadian(i)); rect.sy += glow_radius * sin(DegreeToRadian(i))
						PictureTextRender(picture, rect, label, font, parm)
						rect.sx += glow_radius * 2.0 * cos(DegreeToRadian(i)); rect.sy -= glow_radius * sin(DegreeToRadian(i))
					}
	
					applyBlur()
	
					parm.color = label_color
				}			
				
				PictureTextRender(picture, rect, label, font, parm)
	
				rect.sx -= 2; rect.ex += 2
			}

			g_picture_cache.rawset(cache_uid, picture)
		}
		else
		{
			print("Recycling a texture/picture from the cache.")
			picture = g_picture_cache[cache_uid]
		}

		TextureUpdate(texture, picture)
		picture = 0
	}

	function	applyBlur(iterations = 1)
	{
		local	kernel =
		[
			0, 1, 2, 4, 2, 1, 0,
			1, 2, 4, 6, 4, 2, 1,
			2, 3, 5, 8, 5, 3, 2,
			2, 4, 8, 8, 8, 4, 2,
			2, 3, 5, 8, 5, 3, 2,
			1, 2, 4, 6, 4, 2, 1,
			0, 1, 2, 4, 2, 1, 0
		]

		local	i
		for(i = 0; i < iterations; i++)
			PictureApplyConvolution(picture, 7, 7, kernel, 1.25, 2)
	}

	function	rebuild()
	{
		TextureRelease(texture)
	}

	constructor(ui, w, h, x = 0, y = 0, center = false, vcenter = false)
	{
		texture = EngineNewTexture(g_engine)
		window = UIAddSprite(ui, -1, texture, x, y, w, h)

		if	(center)
			WindowSetPivot(window, w / 2, h / 2)

		font_vcenter = vcenter
	}
}