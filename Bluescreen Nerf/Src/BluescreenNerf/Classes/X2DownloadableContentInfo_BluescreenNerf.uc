//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_BluescreenNerf.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_BluescreenNerf extends X2DownloadableContentInfo config(Bluescreen);


struct BluescreenCostOverride
{
	var name ItemName;
	var array<int> Difficulties;
	var StrategyCost NewCost;
};

var config(StrategyTuning) array<BluescreenCostOverride> BluescreenCostOverrides;
var config bool bAddToProvingGround;

var localized string OrganicDamageMalusLabel;

static event OnPostTemplatesCreated()
{
	PatchBluescreen();
}

static function PatchBluescreen()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local array<X2DataTemplate> DifficulityVariants;
	local X2DataTemplate DataTemplate;
	local X2AmmoTemplate AmmoTemplate;
	local BluescreenCostOverride ItemCostOverrideEntry;
	local int TemplateDifficulty;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	DifficulityVariants.Length = 0;
	ItemTemplateManager.FindDataTemplateAllDifficulties('BluescreenRounds', DifficulityVariants);

	if(DifficulityVariants.Length != 0)
	{
		AmmoTemplate = X2AmmoTemplate(DifficulityVariants[0]);

		if(class'X2Item_DefaultAmmo'.default.BLUESCREEN_ORGANIC_DMGMOD < 0)
		{
			AmmoTemplate.SetUIStatMarkup( default.OrganicDamageMalusLabel, , abs(class'X2Item_DefaultAmmo'.default.BLUESCREEN_ORGANIC_DMGMOD) );
		}

		if(default.bAddToProvingGround)
		{
			`Log(AmmoTemplate.DataName $ " is now only buildable with Experimental Ammo project", , 'BluescreenNerf');
			AmmoTemplate.CanBeBuilt = false; // Can't build this item if we want it to be added to the Proving Ground
			AmmoTemplate.RewardDecks.AddItem('ExperimentalAmmoRewards'); // Add BluescreenRounds to Experimental Ammo project
		}
	}

	foreach default.BluescreenCostOverrides(ItemCostOverrideEntry)
	{
		if (DifficulityVariants.Length == 1 && ItemCostOverrideEntry.Difficulties.Find(3) > -1)
		{
			AmmoTemplate = X2AmmoTemplate( DifficulityVariants[0] );
			`Log(AmmoTemplate.DataName $ " has had its cost overridden to non-legend values", , 'BluescreenNerf');
			AmmoTemplate.Cost = ItemCostOverrideEntry.NewCost;

			continue;
		}

		foreach DifficulityVariants(DataTemplate)
		{
			AmmoTemplate = X2AmmoTemplate(DataTemplate);

			if (AmmoTemplate.IsTemplateAvailableToAllAreas(class'X2DataTemplate'.const.BITFIELD_GAMEAREA_Rookie))
			{
				TemplateDifficulty = 0; // Rookie
			}
			else if (AmmoTemplate.IsTemplateAvailableToAllAreas(class'X2DataTemplate'.const.BITFIELD_GAMEAREA_Veteran))
			{
				TemplateDifficulty = 1; // Veteran
			}
			else if (AmmoTemplate.IsTemplateAvailableToAllAreas(class'X2DataTemplate'.const.BITFIELD_GAMEAREA_Commander))
			{
				TemplateDifficulty = 2; // Commander
			}
			else if (AmmoTemplate.IsTemplateAvailableToAllAreas(class'X2DataTemplate'.const.BITFIELD_GAMEAREA_Legend))
			{
				TemplateDifficulty = 3; // Legend
			}
			else
			{
				TemplateDifficulty = -1; // Untranslatable Bitfield
			}
			
			if (ItemCostOverrideEntry.Difficulties.Find(TemplateDifficulty) > -1)
			{
				`log(AmmoTemplate.DataName $ " on difficulty " $ TemplateDifficulty $ " has had its cost overridden", , 'BluescreenNerf');
				AmmoTemplate.Cost = ItemCostOverrideEntry.NewCost;
			}
		}
	}
}