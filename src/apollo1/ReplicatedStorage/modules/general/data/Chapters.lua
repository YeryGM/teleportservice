local debugOn = true

local Chapters = {
	Capitulo_1 = {
		DisplayName = "Capitulo 1",
		Places = {
			127835015610242, 
		},
	},
	Capitulo_2 = {
		DisplayName = "Capitulo 2",
		Places = {
			0, -- TODO
		},
	},
	Capitulo_3 = {
		DisplayName = "Capitulo 3",
		Places = {
			0, -- TODO
		},
	},
}

if debugOn then
	print("[Chapters] Modulo cargado " .. tostring(#Chapters) .. " capitulos")
end

return Chapters
