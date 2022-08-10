#include "inc_xp"
#include "inc_gold"
#include "nwnx_visibility"
#include "nwnx_creature"
#include "x0_i0_match"

// =======================================================
// PROTOTYPES
// =======================================================

// Levels up the henchman and gear appropriately.
// Equal to player level. 2 level minimum.
void ScaleHenchman(object oHench);

// Clears out the master for the henchman
// If bTagDestroy, the henchman will walk at doors in the expectation that something will destroy them
void ClearMaster(object oHench, int bTagDestroy=1);

// Set the master for the henchman
void SetMaster(object oHench, object oPlayer);

// Return how much the henchman will cost. Modified by charisma
// and appraise.
int GetHenchmanCost(object oHench, object oPlayer);

// Return how much the henchman will cost at a 50% discount.
int GetHenchmanCostPersuade(object oHench, object oPlayer);

// Check if there is a master assigned. If there is and there is no master online,
// increment a counter. After 50 increments (5 minutes), make the henchman dissappear.
// Else reset the increment.
void CheckMasterAssignment(object oHench);

// Dismiss the henchman, have them move to the nearest door and dissappear.
void DismissHenchman(object oHench);

// Returns TRUE if the player has a henchman.
int PlayerHasHenchman(object oPlayer);

// Rehire the current henchman. Used when a player is relogging.
void RehireHenchman(object oPlayer);

// retrieves master by uuid for this henchman.
// useful for when the master is dead (not in party)
object GetMasterByUUID(object oHench);

// Respawn the named henchman if they are not in existence somewhere.
// Respawning also clears their master
void TFNRespawnHenchman(string sResRef);


// =======================================================
// FUNCTIONS
// =======================================================

int GetHenchmanCount(object oPlayer)
{
    int nCount = 0;

    if (GetIsPC(oPlayer))
    {
        object oParty = GetFirstFactionMember(oPlayer, FALSE);

        while (GetIsObjectValid(oParty))
        {
            if (GetStringLeft(GetResRef(oParty), 3) == "hen" && GetMaster(oParty) == oPlayer) nCount = nCount + 1;
            oParty = GetNextFactionMember(oPlayer, FALSE);
        }
    }
    return nCount;
}

void PlayVoiceByStrRef(int nStrRef)
{
    SpeakStringByStrRef(nStrRef);
    PlaySoundByStrRef(nStrRef, FALSE);
}

object GetMasterByUUID(object oHench)
{
    return GetObjectByUUID(GetLocalString(GetModule(), GetResRef(oHench)+"_master"));
}

void RehireHenchman(object oPlayer)
{
    string sUUID = GetObjectUUID(oPlayer);
    object oModule = GetModule();

    if (GetLocalString(oModule, "hen_daelan_master") == sUUID) SetMaster(GetObjectByTag("hen_daelan"), oPlayer);
    if (GetLocalString(oModule, "hen_linu_master") == sUUID) SetMaster(GetObjectByTag("hen_linu"), oPlayer);
    if (GetLocalString(oModule, "hen_tomi_master") == sUUID) SetMaster(GetObjectByTag("hen_tomi"), oPlayer);
    if (GetLocalString(oModule, "hen_sharwyn_master") == sUUID) SetMaster(GetObjectByTag("hen_sharwyn"), oPlayer);
    if (GetLocalString(oModule, "hen_boddyknock_master") == sUUID) SetMaster(GetObjectByTag("hen_boddyknock"), oPlayer);
    if (GetLocalString(oModule, "hen_grimgnaw_master") == sUUID) SetMaster(GetObjectByTag("hen_grimgnaw"), oPlayer);
    if (GetLocalString(oModule, "hen_valen_master") == sUUID) SetMaster(GetObjectByTag("hen_valen"), oPlayer);
    if (GetLocalString(oModule, "hen_nathyrra_master") == sUUID) SetMaster(GetObjectByTag("hen_nathyrra"), oPlayer);
    if (GetLocalString(oModule, "hen_bim_master") == sUUID) SetMaster(GetObjectByTag("hen_bim"), oPlayer);
}

void DismissHenchman(object oHench)
{
    ClearMaster(oHench);
    PlayVoiceChat(VOICE_CHAT_GOODBYE, oHench);
    AssignCommand(oHench, ActionMoveToObject(GetNearestObject(OBJECT_TYPE_DOOR)));
    DestroyObject(oHench, 10.0);
}

void CheckMasterAssignment(object oHench)
{
// No master assigned? Exit!
    if (GetLocalString(GetModule(), GetResRef(oHench)+"_master") == "") return;

    if (GetIsObjectValid(GetMaster(oHench))) DeleteLocalInt(oHench, "no_master_count");

    int nCount = GetLocalInt(oHench, "no_master_count");

    if (nCount >= 50)
    {
        DismissHenchman(oHench);
    }
    else
    {
        SetLocalInt(oHench, "no_master_count", nCount + 1);
    }
}

void ScaleHenchman(object oHench)
{
    object oMaster = GetMaster(oHench);

// Stop if there is no master.
    if (!GetIsObjectValid(oMaster)) return;

    int nTargetLevel = GetHitDice(oMaster);
    if (nTargetLevel < 2) nTargetLevel = 2; //failsafe if less than 2

    int nHenchmanLevel = GetHitDice(oHench);

// Don't do anything if the henchman is higher or equal to the target level.
    if (nHenchmanLevel >= nTargetLevel) return;

// Henchman cannot be higher than level 12
    if (nHenchmanLevel > 12) return;

    string sResRef = GetResRef(oHench);

    int nClass = CLASS_TYPE_INVALID;
    int nPackage = PACKAGE_INVALID;

    while ((nHenchmanLevel < nTargetLevel))
    {
        if (sResRef == "hen_valen" && nHenchmanLevel == 6)
        {
            NWNX_Creature_AddFeatByLevel(oHench, FEAT_WHIRLWIND_ATTACK, 6);
        }
        else if (sResRef == "hen_valen" && nHenchmanLevel > 6)
        {
            nClass = CLASS_TYPE_WEAPON_MASTER;
            nPackage = 139;
        }
        else if (sResRef == "hen_nathyrra" && nHenchmanLevel == 8)
        {
            nClass = CLASS_TYPE_SHADOWDANCER;
            nPackage = 141;
        }
        else
        {
            nClass = CLASS_TYPE_INVALID;
            nPackage = PACKAGE_INVALID;
        }

// return early if it fails
        if (LevelUpHenchman(oHench, nClass, FALSE, nPackage) == 0)
        {
            SendDebugMessage("Henchman failed to level up");
            return;
        }
        nHenchmanLevel = GetHitDice(oHench);

        switch (nHenchmanLevel)
        {
            case 3:
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyACBonus(1), GetItemInSlot(INVENTORY_SLOT_NECK, oHench));
            break;
            case 4:
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyACBonus(1), GetItemInSlot(INVENTORY_SLOT_CLOAK, oHench));
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_UNIVERSAL, 1), GetItemInSlot(INVENTORY_SLOT_CLOAK, oHench));
            break;
            case 5:
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyACBonus(1), GetItemInSlot(INVENTORY_SLOT_CHEST, oHench));
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyRegeneration(1), GetItemInSlot(INVENTORY_SLOT_NECK, oHench));
AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAbilityBonus(GetLocalInt(oHench, "ability"), 1), GetItemInSlot(INVENTORY_SLOT_CHEST, oHench));
            break;
            case 6:
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyACBonus(2), GetItemInSlot(INVENTORY_SLOT_NECK, oHench));

                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyEnhancementBonus(1), GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oHench));
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAttackBonus(1), GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oHench));
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyACBonus(1), GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oHench));

                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAttackBonus(1), GetItemInSlot(INVENTORY_SLOT_ARMS, oHench));
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_COLD, 1), GetItemInSlot(INVENTORY_SLOT_ARMS, oHench));
            break;
            case 7:
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyACBonus(2), GetItemInSlot(INVENTORY_SLOT_CLOAK, oHench));
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_UNIVERSAL, 1), GetItemInSlot(INVENTORY_SLOT_CLOAK, oHench));
            break;
            case 8:
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyACBonus(2), GetItemInSlot(INVENTORY_SLOT_CHEST, oHench));
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAbilityBonus(GetLocalInt(oHench, "ability"), 1), GetItemInSlot(INVENTORY_SLOT_CHEST, oHench));
            break;
            case 9:
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyACBonus(3), GetItemInSlot(INVENTORY_SLOT_NECK, oHench));

                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyEnhancementBonus(2), GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oHench));
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAttackBonus(2), GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oHench));
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyACBonus(2), GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oHench));

                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAttackBonus(2), GetItemInSlot(INVENTORY_SLOT_ARMS, oHench));
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_COLD, 2), GetItemInSlot(INVENTORY_SLOT_ARMS, oHench));
            break;
            case 10:
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyACBonus(3), GetItemInSlot(INVENTORY_SLOT_CLOAK, oHench));
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_UNIVERSAL, 1), GetItemInSlot(INVENTORY_SLOT_CLOAK, oHench));
            break;
            case 11:
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyACBonus(3), GetItemInSlot(INVENTORY_SLOT_CHEST, oHench));
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAbilityBonus(GetLocalInt(oHench, "ability"), 1), GetItemInSlot(INVENTORY_SLOT_CHEST, oHench));
            break;
            case 12:
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyEnhancementBonus(3), GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oHench));
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAttackBonus(3), GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oHench));
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyACBonus(3), GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oHench));

                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAttackBonus(3), GetItemInSlot(INVENTORY_SLOT_ARMS, oHench));
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_COLD, 3), GetItemInSlot(INVENTORY_SLOT_ARMS, oHench));
            break;
        }
    }
}

void ClearMaster(object oHench, int bTagDestroy=1)
{
// Make sure this is a henchman
    if (GetStringLeft(GetResRef(oHench), 3) != "hen") return;

    string sResRef = GetResRef(oHench);

    DeleteLocalString(GetModule(), sResRef+"_master");

    object oMerchant = GetLocalObject(oHench, "merchant");

    if (GetIsObjectValid(oMerchant))
        DestroyObject(oMerchant);

    object oPlayer = GetMaster(oHench);
    RemoveHenchman(oPlayer, oHench);
    if (bTagDestroy)
    {
        SetLocalInt(oHench, "pending_destroy", 1);
    }

// Reset the henchman visibility override
    object oParty = GetFirstFactionMember(oPlayer);
    while (GetIsObjectValid(oParty))
    {
        NWNX_Visibility_SetVisibilityOverride(oPlayer, oHench, NWNX_VISIBILITY_DEFAULT);
        oParty = GetNextFactionMember(oPlayer);
    }
}

void SetMaster(object oHench, object oPlayer)
{
    if (GetIsDead(oHench)) return;
    if (GetHasEffect(EFFECT_TYPE_PETRIFY, oHench)) return;

// Make sure this is a henchman
    if (GetStringLeft(GetResRef(oHench), 3) != "hen") return;

// Make sure oPlayer is actually a player
    if (!GetIsPC(oPlayer)) return;

    if (!GetIsObjectValid(GetLocalObject(oHench, "merchant")))
    {
        object oMerchant = CreateObject(OBJECT_TYPE_STORE, "mer_henchman", GetLocation(oHench));
        SetLocalObject(oHench, "merchant", oMerchant);
    }

    SetLocalString(GetModule(), GetResRef(oHench)+"_master", GetObjectUUID(oPlayer));

    AddHenchman(oPlayer, oHench);
    ScaleHenchman(oHench);
    
    NWNX_Creature_SetCorpseDecayTime(oHench, 37627000);

// Ensure the henchman is always visible to the player
    object oParty = GetFirstFactionMember(oPlayer);
    while (GetIsObjectValid(oParty))
    {
        NWNX_Visibility_SetVisibilityOverride(oPlayer, oHench, NWNX_VISIBILITY_VISIBLE);
        oParty = GetNextFactionMember(oPlayer);
    }
}

void TFNRespawnHenchman(string sResRef)
{
    if (!GetIsObjectValid(GetObjectByTag(sResRef)))
    {
        SendDebugMessage("Respawning henchman: " + sResRef, TRUE);
        object oHench = CreateObject(OBJECT_TYPE_CREATURE, sResRef, GetLocation(GetObjectByTag(sResRef + "_spawn_point")));
        ClearMaster(oHench, 0);
        NWNX_Creature_SetFaction(oHench, STANDARD_FACTION_MERCHANT);
    }        
}

//void main(){}
