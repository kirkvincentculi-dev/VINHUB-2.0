-- VinHub 2.0 | shared settings
-- Type: ModuleScript | Name: VinHub2Config | Parent: ReplicatedStorage

local Config = {}

Config.Title = "VinHub 2.0"

-- Logo on the movable toggle button.
-- Upload VinHub2_Logo.png (Creator Hub > Asset Manager > Images) and paste its asset ID here.
-- While this is 0 the button shows the text "VinHub" instead.
Config.LogoImageId = 0
Config.ButtonSize = Vector2.new(150, 42) -- keep the same shape as the logo image

-- Who can open the panel (your admins).
-- The game owner always can, and so does everyone while you test in Studio.
-- Add other admins by user ID, or set AllowEveryone = true to open it to all players.
Config.AllowedUserIds = {
	-- 12345678,
}
Config.AllowEveryone = false

-- Slider limits. The server enforces these too.
-- Default = what a slider shows before you touch it (match your game's normal values).
Config.Limits = {
	Speed = { Min = 0, Max = 10000, Default = 16 },
	Jump = { Min = 0, Max = 10000, Default = 50 },
	Spin = { Min = 0, Max = 10, Default = 0 },
	Size = { Min = 0.1, Max = 10, Default = 1 },
}

-- Spin 10 turns at 10 x this many radians per second (5 = about 8 turns per second).
Config.SpinPerStep = 5

-- Music. Name = the file name without .mp3 / .wav, Id = the asset ID after you upload it.
Config.Music = {
	{ Name = "Mthu_-_Its_Like_Im_Not_Even_Here_Slowed_Instrumental", Id = 0 },
	{ Name = "mthu_-_its_like_im_not_even_here", Id = 0 },
	{ Name = "Nope_your_too_late_i_already_died", Id = 0 },
}
Config.MusicVolume = 0.5
-- false = only the player who picks a track hears it. true = everyone in the server hears it.
Config.MusicForEveryone = false

return Config
