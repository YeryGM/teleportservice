--!strict

local DataTypes = {}

export type Id = string | number
export type Metadata = { [string]: any }

export type CreditsTransaction = {
	Amount: number,
	Reason: string,
	Timestamp: number,
}

export type CreditsData = {
	Balance: number,
	LastUpdated: number,
	TransactionHistory: { CreditsTransaction },
}

export type AchievementRequirementKey = string | number
export type AchievementRequirements = { [AchievementRequirementKey]: boolean }

export type AchievementEntry = {
	id: Id,
	requirements: AchievementRequirements,
	unlocked: boolean,
	unlockedAt: number?,
	metadata: Metadata,
}

export type AchievementDefinition = {
	requirements: AchievementRequirements?,
	metadata: Metadata?,
}

export type AchievementsData = {
	Achievements: { [Id]: AchievementEntry },
}

export type InventoryItemData = { [string]: any }

export type InventoryData = {
	Items: { [Id]: InventoryItemData },
}

export type StatId = string | number

export type StatsData = { [StatId]: number }

export type StoryDetailId = string | number
export type StoryChapterId = string | number

export type StoryDetailData = { [string]: any }

export type StoryChapterData = {
	details: { [StoryDetailId]: StoryDetailData },
}

export type StoryData = {
	Chapters: { [StoryChapterId]: StoryChapterData },
}

export type PurchaseEntry = {
	Id: Id,
	ProductId: number,
	ProductName: string,
	Type: string,
	Category: string,
	Price: number,
	Currency: string,
	Status: string,
	Timestamp: number,
	PurchaseId: Id?,
	ReceiptId: Id?,
	Metadata: Metadata,
	RefundTime: number?,
	RefundReason: string?,
}

export type PurchaseInput = {
	ProductId: number,
	Type: string,
	Price: number,
	ProductName: string?,
	Category: string?,
	Currency: string?,
	Status: string?,
	PurchaseId: Id?,
	ReceiptId: Id?,
	Metadata: Metadata?,
}

export type FailedPurchaseEntry = {
	ProductId: number,
	ProductName: string?,
	Type: string,
	Category: string,
	Reason: string,
	Timestamp: number,
	Metadata: Metadata,
}

export type FailedPurchaseInput = {
	ProductId: number,
	ProductName: string?,
	Type: string,
	Category: string?,
	Metadata: Metadata?,
}

export type PurchaseStatisticsByProduct = {
	Count: number,
	TotalSpent: number,
	LastPurchase: number?,
}

export type PurchaseStatisticsBucket = {
	Count: number,
	TotalSpent: number,
}

export type PurchaseStatistics = {
	ByProductId: { [number]: PurchaseStatisticsByProduct },
	ByType: { [string]: PurchaseStatisticsBucket },
	ByCategory: { [string]: PurchaseStatisticsBucket },
}

export type PurchaseData = {
	Purchases: { [Id]: PurchaseEntry },
	FailedPurchases: { FailedPurchaseEntry },
	TotalPurchases: number,
	TotalSpent: number,
	LastPurchaseTime: number?,
	FirstPurchaseTime: number?,
	Statistics: PurchaseStatistics,
}

return DataTypes