local types = require(script.Parent.Parent.enums.EPurchases)

local ProductsList = {
	--DEV PRODUCTS
	-- Currency Products
	[3456747226] = {
		Name = "100 Credits",
		Category = types.Categories.Currency,
		Type = types.Types.DevProduct,
		Currency = types.Currencies.Credits,
		Metadata = { --metadata de la compra, not the item metadata
			amount = 100,
		},
		MaxPurchasesPerPlayer = nil,
	},
	-- GAME PRODUCTS
	-- Consumable Items
	[345678] = {
		Name = "Cola",
		Category = types.Categories.Consumable,
		Type = types.Types.GameProduct,
		Amount = 1,
		Price = 100,
		Currency = types.Currencies.Credits,
        Stock = -1,
        MaxPurchasesPerPlayer = 5,
        ImageId = "rbxassetid://222222222",
        Metadata = nil,
	},
	
}

return ProductsList