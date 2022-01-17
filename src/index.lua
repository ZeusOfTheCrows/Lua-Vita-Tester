-- ztodo: red circle primitive radius of max range: "recommended deadzone"
-- ztodo: pngquant to shrink image size
-------------------------------------------------------------------------------
--               VPad Tester & Configurator by ⱿeusOfTheCrows                --
--            based on work by Keinta15 | Original work by Smoke5            --
-------------------------------------------------------------------------------

-- Initiating Sound Device
Sound.init()

-- init colors
white  = Color.new(235, 219, 178)
orange = Color.new(254, 128, 025)
red    = Color.new(204, 036, 029)
dred   = Color.new(204, 036, 029, 128)
green  = Color.new(152, 151, 026)
grey   = Color.new(189, 174, 147)
black  = Color.new(040, 040, 040)

-- init images
bgimg       = Graphics.loadImage("app0:/resources/img/bgd.png")
crossimg    = Graphics.loadImage("app0:/resources/img/crs.png")
squareimg   = Graphics.loadImage("app0:/resources/img/sqr.png")
circleimg   = Graphics.loadImage("app0:/resources/img/ccl.png")
triangleimg = Graphics.loadImage("app0:/resources/img/tri.png")
sttselctimg = Graphics.loadImage("app0:/resources/img/ssl.png")
homeimg     = Graphics.loadImage("app0:/resources/img/hom.png")
rtriggerimg = Graphics.loadImage("app0:/resources/img/rtr.png")
ltriggerimg = Graphics.loadImage("app0:/resources/img/ltr.png")
upimg       = Graphics.loadImage("app0:/resources/img/dup.png")
downimg     = Graphics.loadImage("app0:/resources/img/ddn.png")
leftimg     = Graphics.loadImage("app0:/resources/img/dlf.png")
rightimg    = Graphics.loadImage("app0:/resources/img/drt.png")
analogueimg = Graphics.loadImage("app0:/resources/img/anl.png")
frontTouch  = Graphics.loadImage("app0:/resources/img/gry.png")
backTouch   = Graphics.loadImage("app0:/resources/img/blu.png")

-- init font
varwFont = Font.load("app0:/resources/fnt/fir-san-reg.ttf")
monoFont = Font.load("app0:/resources/fnt/fir-cod-reg.ttf")
Font.setPixelSizes(varwFont, 25)
Font.setPixelSizes(monoFont, 25)

-- loading sounds
snd1 = Sound.openOgg("app0:/resources/snd/audio-test.ogg")
hsnd1={hsnd1,hsnd1}

--- semantic variables

-- offsets touch image to account for image size. should be half of resolution
-- ztodo? could be automatic, see Graphics.getImageWidth/Height(img)
--              x, y (arrays index from 1...)
touchoffset  = {30, 32}

-- multiplier for analogue stick size
anasizemulti = 7.5

-- short button names
cross = SCE_CTRL_CROSS
square = SCE_CTRL_SQUARE
circle = SCE_CTRL_CIRCLE
triangle = SCE_CTRL_TRIANGLE
start = SCE_CTRL_START
select = SCE_CTRL_SELECT
home = SCE_CTRL_PSBUTTON  -- not used: can't get it to register if disabled
rtrigger = SCE_CTRL_RTRIGGER
ltrigger = SCE_CTRL_LTRIGGER
up = SCE_CTRL_UP
down = SCE_CTRL_DOWN
left = SCE_CTRL_LEFT
right = SCE_CTRL_RIGHT

-- init vars to avoid nil
lx, ly, rx, ry = 0.0, 0.0, 0.0, 0.0
lxmax, lymax, rxmax, rymax = 0.0, 0.0, 0.0, 0.0
anaencfgfile = System.openFile("ux0:/data/AnalogsEnhancer/config.txt", FRDWR)
-- ztodo: put this in func so it can be called arbitrarily
anaencfg = System.readFile(anaencfgfile, 26) -- two extra bytes for "safety"
anaenprops = {}
-- %p is unstable: it matches any punctuation marks - i would rather = | ; | ,
-- match set of one or more of all alphanumeric chars (avoid null bytes at eof)
for p in string.gmatch(anaencfg, "[%w]+") do
	table.insert(anaenprops, p)
end

------------------------------ mini functions ---------------------------------

-- func for padding numbers - to avoid jumping text
function lPad(str, len, char)
	-- default arguments
	len = len or 5 -- 5 because of decimal point
	char = char or "0"
	str = tostring(str)
	if char == nil then char = '' end
	return string.rep(char, len - #str) .. str
end

-- func for calculating "max" of stick range from 0
function calcMax(currNum, currMax)
	num = math.abs(currNum - 127)
	max = math.abs(currMax)
	if num > max then
		return num
	else
		return max
	end
end

-- i hate this language.
function arrayToString(arrayval)
	r = ""
	for i, v in ipairs(arrayval) do
		-- for first iter don't print preceding ";"
		if i == 1 then
			r = r .. v
		else
			r = r .. "; " .. v
		end
	end
	return r
end


-- plays sound (i think {not mine})
function soundTest()
	for s=1,2 do
		if hsnd1[s]==nil then
			hsnd1[s] = Sound.openOgg("app0:/resources/snd/audio-test.ogg")
			Sound.play(hsnd1[s],NOLOOP)
			break
		end
	end
end

------------------------ monolithic functions ---------------------------------
function drawInfo(pad)
	-- ztodo: maybe split out into functions called by this one? to avoid rendering issue
	-- Starting drawing phase
	-- i'm not sure clearing the screen every frame is the best way to do this
	-- 		it also breaks psvremap
	Graphics.initBlend()
	Screen.clear()

	-- programmatically colour background
	Graphics.fillRect(0, 960, 0, 544, black)
	Graphics.drawImage(0, 40, bgimg)

	-- Display info
	Font.print(varwFont, 008, 008, "VPad Tester & Configurator v1.3.0 by ZeusOfTheCrows", orange)
	Font.print(varwFont, 205, 078, "Press Start + Select to exit", grey)
	Font.print(varwFont, 205, 103, "Press L + R to reset max stick range", grey)
	Font.print(varwFont, 205, 128, "Press X + O for Sound Test", grey)
	Font.print(varwFont, 205, 153, "Press Δ + Π for Gyro/Accelerometer [NYI]", grey)
	-- debug print
	Font.print(varwFont, 205, 178,  arrayToString(anaenprops) .. ".", grey)
	Font.print(monoFont, 720, 078,  battpercent .. "%", battcolr)
	Font.print(monoFont, 010, 480, "Left: " .. lPad(lx) .. ", " .. lPad(ly) ..
	                    "\nMax:  " .. lPad(lxmax) .. ", " .. lPad(lymax), white)
	Font.print(monoFont, 670, 482, "Right: " .. lPad(rx) .. ", " .. lPad(ry) ..
		                "\nMax:   " .. lPad(rxmax) .. ", " .. lPad(rymax), white)
	-- Screen.flip()  -- this was here before, but i don't think it needs to be?

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

	--- checks for input

	-- draw and move analogue sticks on screen
	-- default position:  90, 270 (+16px)
	Graphics.drawImage((73 + lx / 7.5), (252 + ly / 7.5), analogueimg)

	-- default position: 810, 270 (+16px)
	Graphics.drawImage((793 + rx / 7.5), (252 + ry / 7.5), analogueimg)

	-- draw recommended deadzones 137, 300
	Graphics.fillCircle(124, 304, ((math.max(lxmax, lymax) * 0.128) + 36), dred)

	Graphics.fillCircle(844, 304, ((math.max(rxmax, rymax) * 0.128) + 36), dred)

	--  Draw face buttons if pressed
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
		Graphics.fillRect(0, 960, 0, 544, Color.new(0, 0, 0))
		Graphics.drawImage(087, 376, homeimg)
	end
	if Controls.check(pad, ltrigger) then
		Graphics.drawImage(68, 43, ltriggerimg)
	end
	if Controls.check(pad, rtrigger) then
		Graphics.drawImage(775, 43, rtriggerimg)
	end
	--  Draw up directional button if pressed   x113, y91
	if Controls.check(pad, up) then
		Graphics.drawImage(77, 134, upimg)
	end
	--  Draw down directional button if pressed
	if Controls.check(pad, down) then
		--Graphics.drawRotateImage(94, 231, dpad, 3.14)
		-- couldn't make the intergers to work? I may be dumb
		Graphics.drawImage(77, 193, downimg)
	end
	--  Draw left directional button if pressed
	if Controls.check(pad, left) then
		--Graphics.drawRotateImage(65, 203, dpad, -1.57)
		-- couldn't make the intergers to work
		Graphics.drawImage(44, 167, leftimg)
	end
	--  Draw right directional button if pressed
	if Controls.check(pad, right) then
		--Graphics.drawRotateImage(123, 203, dpad, 1.57)
		-- couldn't make the intergers to work
		Graphics.drawImage(103, 167, rightimg)
	end

	--  Draw front touch on screen
	if tx1 ~= nil then
		Graphics.drawImage(tx1 - touchoffset[1], ty1 - touchoffset[2], frontTouch)
	end
	if tx2 ~= nil then
		Graphics.drawImage(tx2 - touchoffset[1], ty2 - touchoffset[2], frontTouch)
	end
	if tx3 ~= nil then
		Graphics.drawImage(tx3 - touchoffset[1], ty3 - touchoffset[2], frontTouch)
	end
	if tx4 ~= nil then
		Graphics.drawImage(tx4 - touchoffset[1], ty4 - touchoffset[2], frontTouch)
	end
	if tx5 ~= nil then
		Graphics.drawImage(tx5 - touchoffset[1], ty5 - touchoffset[2], frontTouch)
	end
	if tx6 ~= nil then
		Graphics.drawImage(tx6 - touchoffset[1], ty6 - touchoffset[2], frontTouch)
	end

	--  Draw rear touch on screen
	-- -50 and -56.5 added because image wasn't placed under finger
	if rtx1 ~= nil then
		Graphics.drawImage(rtx1 - touchoffset[1], rty1 - touchoffset[2], backTouch)
	end
	if rtx2 ~= nil then
		Graphics.drawImage(rtx2 - touchoffset[1], rty2 - touchoffset[2], backTouch)
	end
	if rtx3 ~= nil then
		Graphics.drawImage(rtx3 - touchoffset[1], rty3 - touchoffset[2], backTouch)
	end
	if rtx4 ~= nil then
		Graphics.drawImage(rtx4 - touchoffset[1], rty4 - touchoffset[2], backTouch)
	end

	-- Terminating drawing phase
	Screen.flip()
	Graphics.termBlend()
end

function handleControls(pad)
	-- reset stick max
	if Controls.check(pad, ltrigger) and Controls.check(pad, rtrigger) then
		lxmax, lymax, rxmax, rymax = 0.0, 0.0, 0.0, 0.0
	end

	-- Sound Testing
	if Controls.check(pad, cross) and Controls.check(pad, circle) then
		soundTest()
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

-- main loop
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

	for i=1,2 do
		if hsnd1[i] and not Sound.isPlaying(hsnd1[i]) then
			Sound.close(hsnd1[i])
			hsnd1[i]=nil
		end
	end

	handleControls(pad)

	drawInfo(pad)

end