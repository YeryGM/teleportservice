local DEBUG_MODE = true

local Chapters = {
	Capitulo_1 = {
		DisplayName = "Capitulo 1",
		Places = {
			77738210933862, 
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

if DEBUG_MODE then
	print("[Chapters] Modulo cargado " .. tostring(#Chapters) .. " capitulos")
end

return Chapters
