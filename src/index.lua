-------------------------------------------------------------------------------
--               VPad Tester & Configurator by ⱿeusOfTheCrows                --
--            based on work by Keinta15 | Original work by Smoke5            --
-------------------------------------------------------------------------------

-- ztodo: pngquant to shrink image size
-- ztodo: change package name? ZVPTSTCFG (zeus' vpad tester & configurator)

----------------------------------- globals -----------------------------------
-- globals marked "/!\ will change" are manipulated in code. i know it's bad
-- practice, but i find it makes more sense

-- global colours
white  = Color.new(235, 219, 178)
bright = Color.new(251, 241, 199)
orange = Color.new(254, 128, 025)
red    = Color.new(204, 036, 029)
dred   = Color.new(204, 036, 029, 128)
green  = Color.new(152, 151, 026)
grey   = Color.new(189, 174, 147)
black  = Color.new(040, 040, 040)

-- load images from files
bgimg       = Graphics.loadImage("app0:resources/img/bgd.png")
crossimg    = Graphics.loadImage("app0:resources/img/crs.png")
squareimg   = Graphics.loadImage("app0:resources/img/sqr.png")
circleimg   = Graphics.loadImage("app0:resources/img/ccl.png")
triangleimg = Graphics.loadImage("app0:resources/img/tri.png")
sttselctimg = Graphics.loadImage("app0:resources/img/ssl.png")
homeimg     = Graphics.loadImage("app0:resources/img/hom.png")
rtriggerimg = Graphics.loadImage("app0:resources/img/rtr.png")
ltriggerimg = Graphics.loadImage("app0:resources/img/ltr.png")
dpupimg     = Graphics.loadImage("app0:resources/img/dup.png")
dpdownimg   = Graphics.loadImage("app0:resources/img/ddn.png")
dpleftimg   = Graphics.loadImage("app0:resources/img/dlf.png")
dprightimg  = Graphics.loadImage("app0:resources/img/drt.png")
analogueimg = Graphics.loadImage("app0:resources/img/ana.png")
frontTouch  = Graphics.loadImage("app0:resources/img/gry.png")
backTouch   = Graphics.loadImage("app0:resources/img/blu.png")

-- load fonts
varwFont = Font.load("app0:/resources/fnt/fir-san-reg.ttf")  -- variable width
monoFont = Font.load("app0:/resources/fnt/fir-cod-reg.ttf")  -- monospace
Font.setPixelSizes(varwFont, 24)
Font.setPixelSizes(monoFont, 24)

-- audio related vars
Sound.init()
-- i think it's polish: "kanał lewy, kanał prawy" (left channel, right channel)
audiopath = "app0:resources/snd/audio-test.ogg"
audiofile = 0  -- /!\ will change -- ztodo: i don't think i need this here
audioplaying = false  -- /!\ will change - declared here so it's global

-- offsets touch image to account for image size. should be half of resolution
-- ztodo? could be automatic, see Graphics.getImageWidth/Height(img)
--               x, y (arrays index from 1...)
touchoffset  = {30, 32}
-- multiplier for analogue stick size
anasizemulti = 7.5
-- global file handle for analogsenhancer config file
-- anaencfgprops = {}  -- /!\ will change
anaendbg = ""
-- analogsenhancer config paths. oh look, it's a 2d array because fuck you
anaencfgpaths ={
{"ur0:tai/AnaEnCfg.txt", "config loaded for ur0: mod"},
{"ux0:data/AnalogsEnhancer/config.txt", "config loaded for default plugin"}
}

-- short button names
cross    = SCE_CTRL_CROSS
square   = SCE_CTRL_SQUARE
circle   = SCE_CTRL_CIRCLE
triangle = SCE_CTRL_TRIANGLE
start    = SCE_CTRL_START
select   = SCE_CTRL_SELECT
home     = SCE_CTRL_PSBUTTON  -- not used: see draw function line ~270
rtrigger = SCE_CTRL_RTRIGGER
ltrigger = SCE_CTRL_LTRIGGER
dpup     = SCE_CTRL_UP
dpdown   = SCE_CTRL_DOWN
dpleft   = SCE_CTRL_LEFT
dpright  = SCE_CTRL_RIGHT

-- init vars to avoid nil
lx, ly, rx, ry = 0.0, 0.0, 0.0, 0.0  -- /!\ will change
lxmax, lymax, rxmax, rymax = 0.0, 0.0, 0.0, 0.0  -- /!\ will change
-- for converting keyread to keydown - updates at end of frame
padprevframe = 0  -- /!\ will change
-- current page (0=home, 1=deadzone config, etc.)
currPage = 0  -- /!\ will change

---------------------------- function declarations ----------------------------

function lPad(str, len, char)  -- for padding numbers, to avoid jumping text
	-- default arguments
	len = len or 3
	char = char or "0"
	str = tostring(str)
	if char == nil then char = '' end
	return string.rep(char, len - #str) .. str
end

function arrayToStr(arrayval, sepchars)  -- i hate this language.
	-- i know table.concat exists, but this doesn't have a tizz when told to
	-- concatenate a string (advanced programming i know)
	sepchars = sepchars or "; "
	-- check if is already string (not necessary, but saves headaches)
	if type(arrayval) == "string" then
		return arrayval
	else
		r = ""
		for i, v in ipairs(arrayval) do
			-- for first iter don't print preceding ";"
			if i == 1 then
				r = r .. v
			else
				r = r .. sepchars .. v
			end
		end
		return r
	end
end

function calcMax(currNum, currMax)  -- calculating "max" of stick range from 0
	num = math.abs(currNum - 127)
	max = math.abs(currMax)
	if num > max then
		return num
	else
		return max
	end
end

function openFile(filepaths)  -- find existing file and return, or return false
	for i, value in ipairs(filepaths) do
		file = value[1]
		if System.doesFileExist(file) then
			return System.openFile(file, FREAD), value[2]
		end
	end
	return false, "cannot find file: is plugin installed?"
end

function parseCfgFile(filepaths)  -- read config file and return info (check)
	anaenprops = {}
	file, output = openFile(filepaths)
	if file then
		file = System.readFile(file, System.sizeFile(file))
		-- match set of one or more of all alphanumeric chars
		for p in string.gmatch(file, "[%w]+") do
			table.insert(anaenprops, p)
		end
		-- System.closeFile(file)
		return anaenprops, output
	else
		return false, output
	end
end

function toggleAudio()  -- no arguments because it has to be a global, i think
	-- /!\ Sound.isPlaying does not work. whether 'tis my bug or native, i do
	-- /!\ not know; but once toggled twice it always returns false
	audioplaying = not audioplaying  -- toggle bool
	if audioplaying then
		-- i don't think this is great for performance, but i have to Sound.close
		-- the file as Sound.pause doesn't consistently pause
		audiofile = Sound.open(audiopath)
		Sound.play(audiofile)
	else
		-- Sound.stop(audiofile)  -- why is this not a valid function? i need it
		-- pause then close to update Sound.isPlaying(). it doesn't work, and is
		-- probably unnecessary, but it seems uncouth to close it whilst playing
		Sound.pause(audiofile)
		-- close to prevent bug of overlapping audio
		Sound.close(audiofile)
	end
end

function drawDecs()  -- draw decorations (title, frame etc.)
	-- colour background & draw bg image
	Graphics.fillRect(0, 960, 0, 544, black)
	Graphics.drawImage(0, 40, bgimg)

	-- draw header info
	Font.print(varwFont, 008, 004,
		"VPad Tester & Configurator v1.3.0 by ZeusOfTheCrows", orange)
	Font.print(monoFont, 904, 004,  battpercent .. "%", battcolr)
end

function drawHomePage()
	-- Display info
	Font.print(varwFont, 205, 078, "press Start + Select to exit", grey)
	Font.print(varwFont, 205, 103, "press L + R to reset max stick range", grey)
	Font.print(varwFont, 205, 128, "press X + O for audio test", grey)
	Font.print(varwFont, 205, 153, "press Δ + Π for deadzone config", grey)
	-- debug print
	-- Font.print(varwFont, 205, 178, "placeholder", grey)
end

function drawDZPage(statustext, statuscolour)  -- draw deadzone config page
	statuscolour = grey or statuscolour
	-- Display info
	Font.print(varwFont, 205, 078, arrayToStr(statustext, "; "), statuscolour)
	-- Font.print(varwFont, 205, 103, arrayToStr("test", ", "), grey)
	-- Font.print(varwFont, 205, 128, "Press X + O for Sound Test", grey)
	-- Font.print(varwFont, 205, 153, "placeholder", grey)
	-- debug print
	-- Font.print(varwFont, 205, 178, "placeholder", grey)
end

function drawBtnInput()  -- all digital buttons

	--[[ bitmask
		1      select
		2      ?
		4      ?
		8      start
		16     dpad up
		32     dpad right
		64     dpad down
		128    dpad left
		256    l trigger
		512    r trigger
		1024   ?
		2048   ?
		4096   triangle
		8193   circle
		16384  cross
		32768  square
	]]

	--  Draw buttons if pressed
	if Controls.check(pad, circle) then
		Graphics.drawImage(888, 169, circleimg)
	end
	if Controls.check(pad, cross) then
		Graphics.drawImage(849, 207, crossimg)
	end
	if Controls.check(pad, triangle) then
		Graphics.drawImage(849, 130, triangleimg)
	end
	if Controls.check(pad, square) then
		Graphics.drawImage(812, 169, squareimg)
	end

	if Controls.check(pad, select) then
		Graphics.drawImage(807, 378, sttselctimg)
	end
	if Controls.check(pad, start) then
		Graphics.drawImage(858, 378, sttselctimg)
	end
	if Controls.check(pad, home) then
		-- this only gets called while the quick settings are shown and the
		-- home button is enabled - why? (i may as well leave it in though)
		Graphics.drawImage(087, 376, homeimg)
	end

	if Controls.check(pad, ltrigger) then
		Graphics.drawImage(68, 43, ltriggerimg)
	end
	if Controls.check(pad, rtrigger) then
		Graphics.drawImage(775, 43, rtriggerimg)
	end

	-- i don't use drawRotateImage due a bug (probably in vita2d) that draws the
	-- images incorrectly (fuzzy broken borders, misplaced pixels). if you're
	-- editing this in the future, check if it's been fixed
	if Controls.check(pad, dpup) then
		-- Graphics.drawRotateImage(97, 158, dpupimg, 0)
		Graphics.drawImage(77, 134, dpupimg)
	end
	if Controls.check(pad, dpdown) then
		-- Graphics.drawRotateImage(98, 216, dpupimg, 3.141593)
		Graphics.drawImage(77, 193, dpdownimg)
	end
	if Controls.check(pad, dpleft) then
		-- Graphics.drawRotateImage(69, 188, dpupimg, 4.712389)
		Graphics.drawImage(44, 167, dpleftimg)
	end
	if Controls.check(pad, dpright) then
		-- Graphics.drawRotateImage(128, 187, dpupimg, 1.570796)
		Graphics.drawImage(103, 167, dprightimg)
	end
end

function drawSticks()  -- fullsize analogue sticks
	-- draw and move analogue sticks on screen
	-- default position: 90, 270 (-(128/anasizemulti)
	Graphics.drawImage(
		(073+(lx/anasizemulti)),
		(252+(ly/anasizemulti)),
		analogueimg)

	-- default position: 810, 270
	Graphics.drawImage(
		(793+(rx/anasizemulti)),
		(252+(ry/anasizemulti)),
		analogueimg)
end

function drawStickText()  -- bottom two lines of info numbers
	Font.print(monoFont, 010, 480, "Left: " .. lPad(lx) .. ", " .. lPad(ly) ..
	                    "\nMax:  " .. lPad(lxmax) .. ", " .. lPad(lymax), white)
	Font.print(monoFont, 670, 482, "Right: " .. lPad(rx) .. ", " .. lPad(ry) ..
		                "\nMax:   " .. lPad(rxmax) .. ", " .. lPad(rymax), white)
end

function drawMiniSticks()  -- smaller stick circle for deadzone config
	-- draw recommended deadzones 137, 300
	Graphics.fillCircle(124, 304, ((math.max(lxmax, lymax) * 0.3) + 4), dred)
	Graphics.fillCircle(844, 304, ((math.max(rxmax, rymax) * 0.3) + 4), dred)

	-- default position: 124, 304 (-(128/3.33†)) †stick movement multiplier
	Graphics.fillCircle((086 + lx / 3.33), (266 + ly / 3.33), 4, bright)
	-- default position: 844, 304
	Graphics.fillCircle((806 + rx / 3.33), (266 + ry / 3.33), 4, bright)
end

function drawTouch()  -- fingerprint denoting front/rear touch
	if tx1 ~= nil then
		Graphics.drawImage(tx1-touchoffset[1], ty1-touchoffset[2], frontTouch)
	end
	if tx2 ~= nil then
		Graphics.drawImage(tx2-touchoffset[1], ty2-touchoffset[2], frontTouch)
	end
	if tx3 ~= nil then
		Graphics.drawImage(tx3-touchoffset[1], ty3-touchoffset[2], frontTouch)
	end
	if tx4 ~= nil then
		Graphics.drawImage(tx4-touchoffset[1], ty4-touchoffset[2], frontTouch)
	end
	if tx5 ~= nil then
		Graphics.drawImage(tx5-touchoffset[1], ty5-touchoffset[2], frontTouch)
	end
	if tx6 ~= nil then
		Graphics.drawImage(tx6-touchoffset[1], ty6-touchoffset[2], frontTouch)
	end

	if rtx1 ~= nil then
		Graphics.drawImage(rtx1-touchoffset[1], rty1-touchoffset[2], backTouch)
	end
	if rtx2 ~= nil then
		Graphics.drawImage(rtx2-touchoffset[1], rty2-touchoffset[2], backTouch)
	end
	if rtx3 ~= nil then
		Graphics.drawImage(rtx3-touchoffset[1], rty3-touchoffset[2], backTouch)
	end
	if rtx4 ~= nil then
		Graphics.drawImage(rtx4-touchoffset[1], rty4-touchoffset[2], backTouch)
	end
end

------------------------------ caller functions -------------------------------
---------------- (functions that call other smaller functions) ----------------

function drawInfo(pad, page, dzstatus)  -- main draw function that calls others

	page = page or 0  -- default value for current page

	-- Starting drawing phase
	-- i'm not sure clearing the screen every frame is the best way to do this,
	-- but it's the only way i know (it also breaks psvremap)
	Graphics.initBlend()
	Screen.clear()

	drawDecs()
	drawBtnInput()
	drawStickText()
	if page == 0 then
		drawHomePage()
		drawSticks()
		drawTouch()
	elseif page == 1 then
		drawDZPage(anaendbg)
		drawMiniSticks()
	end

	-- Terminating drawing phase
	Screen.flip()
	Graphics.termBlend()
end

function homePageCtrls(pad, ppf) -- ppf = pad prev frame
	-- reset stick max
	if Controls.check(pad, ltrigger) and Controls.check(pad, rtrigger) then
		lxmax, lymax, rxmax, rymax = 0.0, 0.0, 0.0, 0.0
	end

	-- Sound Testing
	-- this is the mess that comes of not having a keydown event
	if (Controls.check(pad, cross) and
	   (Controls.check(pad, circle) and not Controls.check(ppf, circle))) or
	   (Controls.check(pad, circle) and
	   (Controls.check(pad, cross) and not Controls.check(ppf, cross))) then
		toggleAudio()
	end

	if (Controls.check(pad, square) and
	   (Controls.check(pad, triangle) and not Controls.check(ppf, triangle))) or
	   (Controls.check(pad, triangle) and
	   (Controls.check(pad, square) and not Controls.check(ppf, square))) then
		currPage = 1
		anaendbg, dzstatus = parseCfgFile(anaencfgpaths)
	end

	if Controls.check(pad, start) and Controls.check(pad, select) then
		System.exit()
	end

	-- toggle homebutton lock (can't make it work)
	-- if Controls.check(pad, start) and Controls.check(pad, select) then
	-- 	if homeButtonLocked == false then
	-- 		-- lock home button and declare so
	-- 		homeButtonLocked = true
	-- 		Controls.lockHomeButton()
	-- 	else
	-- 		homeButtonLocked = false
	-- 		Controls.unlockHomeButton()
	-- 	end
	-- end
end

---------------------------------- main loop ----------------------------------
while true do

	pad = Controls.read()

	-- init battery stats
	battpercent = System.getBatteryPercentage()
	if System.isBatteryCharging() then
		battcolr = green
	elseif battpercent < 15 then
		battcolr = red
	else
		battcolr = grey
	end

	-- update sticks
	lx,ly = Controls.readLeftAnalog()
	rx,ry = Controls.readRightAnalog()

	-- calculate max stick values
	lxmax = calcMax(lx, lxmax)
	lymax = calcMax(ly, lymax)
	rxmax = calcMax(rx, rxmax)
	rymax = calcMax(ry, rymax)

	-- init/update touch registration
	tx1, ty1, tx2, ty2, tx3, ty3, tx4, ty4, tx5, ty5, tx6, ty6 =
	                                                        Controls.readTouch()
	rtx1, rty1, rtx2, rty2, rtx4, rty4 = Controls.readRetroTouch()

	dzstatus = ""  -- localscope for now

	homePageCtrls(pad, padprevframe)

	drawInfo(pad, currPage, dzstatus)

	padprevframe = pad

end