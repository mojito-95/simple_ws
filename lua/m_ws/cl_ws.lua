Mojito = Mojito || {}
Mojito.WS = Mojito.WS || {}

local weaponSelectorIndex = 1
local weaponSelectorDeltaIndex = 1
local weaponSelectorInfoAlpha = 0
local weaponSelectorAlpha = 0
local weaponSelectorAlphaDelta = 0
local weaponSelectorFadeTime = 0
local weaponSelectorMarkUp = nil

hook.Add("HUDShouldDraw", "HideHUD", function(name)
	
	if (name == "CHudWeaponSelection") then return false end

end)

local function onIndexChanged()

    weaponSelectorAlpha = 1
	weaponSelectorFadeTime = CurTime() + 5
		
	local ply = LocalPlayer()
	local weapon = ply:GetWeapons()[weaponSelectorIndex]

	weaponSelectorMarkUp = nil

	if (IsValid(weapon)) then

		local text = ""

		if (text != "") then
			
            weaponSelectorMarkUp = markup.Parse("<font=Mojito.WS.Font>"..text, ScrW() * 0.3)
			weaponSelectorInfoAlpha = 0
			
        end

		if (Mojito.WS.SoundEnable) then

			ply:EmitSound(Mojito.WS.Sounds["select"])

		end

	end

end

hook.Add("HUDPaint", "Mojito.WS.HUDPaint", function()

    local frameTime = FrameTime()

	weaponSelectorAlphaDelta = Lerp(frameTime * 10, weaponSelectorAlphaDelta, weaponSelectorAlpha)

	local fraction = weaponSelectorAlphaDelta

	if (fraction > 0) then

		local ply = LocalPlayer()
		local weapons = ply:GetWeapons()
		local total = table.Count(weapons)
		local x, y = ScrW() * 0.5, ScrH() * 0.5
		local spacing = math.pi * Mojito.WS.TextSpacing
		local radius = 240 * weaponSelectorAlphaDelta

		weaponSelectorDeltaIndex = Lerp(frameTime * 12, weaponSelectorDeltaIndex, weaponSelectorIndex)

		local index = weaponSelectorDeltaIndex
			
		for k, v in ipairs(weapons) do

			if (!weapons[weaponSelectorIndex]) then

				weaponSelectorIndex = total

			end

			local theta = (k - index) * 0.1
            local color = ColorAlpha(Mojito.WS.TextColor, (255 - math.abs(theta * 3) * 255) * fraction)
            if (k == weaponSelectorIndex) then

                color = ColorAlpha(Mojito.WS.SelectedTextColor, (255 - math.abs(theta * 3) * 255) * fraction)

            end
			local lastY = 0
			local shiftX = ScrW() * 0.02

			if (weaponSelectorMarkUp && k < weaponSelectorIndex) then
					
                local w, h = weaponSelectorMarkUp:Size()

				lastY = (h * fraction)

				if (k == weaponSelectorIndex - 1) then
					
                    weaponSelectorInfoAlpha = Lerp(frameTime * 3, weaponSelectorInfoAlpha, 255)

					weaponSelectorMarkUp:Draw(x + 6 + shiftX, y + 30, 0, 0, weaponSelectorInfoAlpha * fraction)
					
                end

			end

			surface.SetFont("Mojito.WS.Font")
			local tx, ty = surface.GetTextSize(v:GetPrintName():upper())
			local scale = (1 - math.abs(theta * 2))

			local matrix = Matrix()
			matrix:Translate(Vector(
				shiftX + x + math.cos(theta * spacing + math.pi) * radius + radius,
				y + lastY + math.sin(theta * spacing + math.pi) * radius - ty / 2,
			1))
			matrix:Rotate(angle or Angle(0, 0, 0))
			matrix:Scale(Vector(1, 1, 0) * scale)

			cam.PushModelMatrix(matrix)

                draw.DrawText(v:GetPrintName():upper(), "Mojito.WS.Font", 2, ty / 2, color, TEXT_ALIGN_LEFT)

			cam.PopModelMatrix()
			
        end

		if (weaponSelectorFadeTime < CurTime() && weaponSelectorAlpha > 0) then
				
            weaponSelectorAlpha = 0
		
        end

	end

end)

hook.Add("PlayerBindPress", "Mojito.WS.PlayerBindPress", function(ply, bind, pressed)

    local weapon = ply:GetActiveWeapon()

	if (!ply:InVehicle() && (!IsValid(weapon) || !ply:KeyDown(IN_ATTACK))) then
		
        bind = bind:lower()

		if (bind:find("invprev") && pressed) then
			
            weaponSelectorIndex = weaponSelectorIndex + 1

			if (weaponSelectorIndex > table.Count(ply:GetWeapons())) then
					
                weaponSelectorIndex = 1
			
            end

			onIndexChanged()

			return true

		elseif (bind:find("invnext") && pressed) then
				
            weaponSelectorIndex = weaponSelectorIndex - 1

			if (weaponSelectorIndex < 1) then
					
                weaponSelectorIndex = table.Count(ply:GetWeapons())

		    end

			onIndexChanged()
				
            return true

		elseif (bind:find("slot")) then

			weaponSelectorIndex = math.Clamp(tonumber(bind:match("slot(%d)")) || 1, 1, table.Count(ply:GetWeapons()))
				
            onIndexChanged()
			
            return true
		
        elseif (bind:find("attack") && pressed && weaponSelectorAlpha > 0) then

			if (Mojito.WS.SoundEnable) then

				ply:EmitSound(Mojito.WS.Sounds["click"])

			end

            RunConsoleCommand('use', ply:GetWeapons()[weaponSelectorIndex]:GetClass())
			weaponSelectorAlpha = 0

			return true

		end

	end

end)