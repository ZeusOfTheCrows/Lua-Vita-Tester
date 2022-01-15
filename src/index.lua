-- ztoto: inverted flat buttons
-- ztodo: pull out draw()
-- ztodo: fingerprint icon
-------------------------------------------------------------------------------
--  Zeus' Enhanced Vita Snooper by ZeusOfTheCrows, based on work by Keinta15 --
--                        Original work by Smoke5                            --
-------------------------------------------------------------------------------

-- Initiating Sound Device
Sound.init()

-- init colors
white  = Color.new(235, 219, 178, 255)
orange = Color.new(254, 128, 025, 255)
red    = Color.new(204, 036, 029, 255)
green  = Color.new(152, 151, 026, 255)
grey   = Color.new(189, 174, 147, 255)
black  = Color.new(040, 040, 040, 255)

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

-- init short button names
cross = SCE_CTRL_CROSS
square = SCE_CTRL_SQUARE
circle = SCE_CTRL_CIRCLE
triangle = SCE_CTRL_TRIANGLE
start = SCE_CTRL_START
select = SCE_CTRL_SELECT
rtrigger = SCE_CTRL_RTRIGGER
ltrigger = SCE_CTRL_LTRIGGER
up = SCE_CTRL_UP
down = SCE_CTRL_DOWN
left = SCE_CTRL_LEFT
right = SCE_CTRL_RIGHT

-- init num vars to zero (to avoid nil)
lx, ly, rx, ry = 0.0, 0.0, 0.0, 0.0
lxmax, lymax, rxmax, rymax = 0.0, 0.0, 0.0, 0.0

-- func for padding numbers - to avoid jumping text
lPad = function(str, len, char)
	-- default arguments
	len = len or 5 -- 5 because of decimal point
	char = char or "0"
	str = tostring(str)
	if char == nil then char = '' end
	return string.rep(char, len - #str) .. str
end

-- func for calculating "max" of stick range from 0
calcMax = function(currNum, currMax)
	num = math.abs(currNum - 127)
	max = math.abs(currMax)
	if num > max then
		return num
	else
		return max
	end
end

function soundTest()
	for s=1,2 do
		if hsnd1[s]==nil then
			hsnd1[s] = Sound.openOgg("app0:/resources/snd/audio-test.ogg")
			Sound.play(hsnd1[s],NOLOOP)
			break
		end
	end
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

	--- controls:
	-- reset stick max
	if Controls.check(pad, ltrigger) and Controls.check(pad, rtrigger) then
		lxmax, lymax, rxmax, rymax = 0.0, 0.0, 0.0, 0.0
	end

	-- Sound Testing
	if Controls.check(pad, cross) and Controls.check(pad, circle) then
		soundTest()
	end

	-- Controls to exit app
	if Controls.check(pad, start) and Controls.check(pad, select) then
		System.exit()
	end

	-- ui
	-- Starting drawing phase
	Graphics.initBlend()
	Screen.clear()

	-- programmatically colour background
	Graphics.fillRect(0, 960, 0, 544, black)
	Graphics.drawImage(0, 40, bgimg)

	--  Display info
	Font.print(varwFont, 008, 008, "Enhanced VPad Snooper v1.2.0 by ZeusOfTheCrows", orange)
	Font.print(varwFont, 205, 078, "Press Start + Select to exit", grey)
	Font.print(varwFont, 205, 103, "Press L + R to reset max stick range", grey)
	Font.print(varwFont, 205, 128, "Press X and O for Sound Test", grey)
	Font.print(monoFont, 720, 078,  battpercent .. "%", battcolr)
	Font.print(monoFont, 010, 480,  "Left: " .. lPad(lx) .. ", " .. lPad(ly) ..
	              "\nMax:  " .. lPad(lxmax) .. ", " .. lPad(lymax), white)
	Font.print(monoFont, 670, 482, "Right: " .. lPad(rx) .. ", " .. lPad(ry) ..
		          "\nMax:   " .. lPad(rxmax) .. ", " .. lPad(rymax), white)
	Screen.flip()

	--- checks for input
	-- Draw and move left analog stick on screen
	Graphics.drawImage((74 + lx / 8), (254 + ly / 8), analogueimg)
	-- Graphics.drawImage((90), (270), analogueimg)

	-- Draw and move right analog on screen
	Graphics.drawImage((794 + rx / 8), (254 + ry / 8), analogueimg)
	-- Graphics.drawImage((810), (270), analogueimg)

	--  Draw circle button if pressed
	if Controls.check(pad, circle) then
		Graphics.drawImage(888, 169, circleimg)
	end
	--  Draw cross button if pressed
	if Controls.check(pad, cross) then
		Graphics.drawImage(849, 207, crossimg)
	end
	--  Draw triangle button if pressed
	if Controls.check(pad, triangle) then
		Graphics.drawImage(849, 130, triangleimg)
	end
	--  Draw square button if pressed
	if Controls.check(pad, square) then
		Graphics.drawImage(812, 169, squareimg)
	end
	--  Draw select button if pressed
	if Controls.check(pad, select) then
		Graphics.drawImage(807, 378, sttselctimg)
	end
	--  Draw start button if pressed
	if Controls.check(pad, start) then
		Graphics.drawImage(858, 378, sttselctimg)
	end
	--  Draw home button if pressed ztodo
	if Controls.check(pad, start) then
		Graphics.drawImage(087, 376, homeimg)
	end
	--  Draw left trigger button if pressed
	if Controls.check(pad, ltrigger) then
		-- Graphics.drawImage(38, 30, ltriggerimg)
		Graphics.drawImage(68, 43, ltriggerimg)
	end
	--  Draw right trigger button if pressed
	if Controls.check(pad, rtrigger) then
		-- Graphics.drawImage(720, 30, rtriggerimg)
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
		Graphics.drawImage(tx1- 50,ty1- 56.5, frontTouch)
	end
	if tx2 ~= nil then
		Graphics.drawImage(tx2- 50,ty2- 56.5, frontTouch)
	end
	if tx3 ~= nil then
		Graphics.drawImage(tx3- 50,ty3- 56.5, frontTouch)
	end
	if tx4 ~= nil then
		Graphics.drawImage(tx4- 50,ty4- 56.5, frontTouch)
	end
	if tx5 ~= nil then
		Graphics.drawImage(tx5- 50,ty5- 56.5, frontTouch)
	end
	if tx6 ~= nil then
		Graphics.drawImage(tx6- 50,ty6- 56.5, frontTouch)
	end

	-- -50 and -56.5 added because image wasn't placed under finger

	--  Draw rear touch on screen
	if rtx1 ~= nil then
		Graphics.drawImage(rtx1- 50,rty1- 113, backTouch)
	end
	if rtx2 ~= nil then
		Graphics.drawImage(rtx2- 50,rty2- 113, backTouch)
	end
	if rtx3 ~= nil then
		Graphics.drawImage(rtx3- 50,rty3- 113, backTouch)
	end
	if rtx4 ~= nil then
		Graphics.drawImage(rtx4- 50,rty4- 113, backTouch)
	end

	-- Terminating drawing phase
	Screen.flip()
	Graphics.termBlend()

end
