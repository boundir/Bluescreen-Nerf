//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_BluescreenNerf.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_BluescreenNerf extends X2DownloadableContentInfo;

var localized string OrganicDamageMalusLabel;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame() {
}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState) {
}


static event OnPostTemplatesCreated() {
    local X2ItemTemplateManager				ItemTemplateManager;
	local X2EquipmentTemplate			    EquipmentTemplate;
	local X2DataTemplate					DifficultyTemplate;
	local array<X2DataTemplate>				DifficultyTemplates;

    ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemTemplateManager.FindDataTemplateAllDifficulties( 'BluescreenRounds', DifficultyTemplates );

	foreach DifficultyTemplates( DifficultyTemplate ) {
		EquipmentTemplate = X2EquipmentTemplate( DifficultyTemplate );
		if( EquipmentTemplate != none ) {
			EquipmentTemplate.SetUIStatMarkup( default.OrganicDamageMalusLabel, , class'X2Item_DefaultAmmo'.default.BLUESCREEN_ORGANIC_DMGMOD );
		}
	}
}