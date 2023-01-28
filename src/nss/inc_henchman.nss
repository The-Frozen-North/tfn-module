#include "inc_xp"
#include "inc_gold"
#include "nwnx_visibility"
#include "nwnx_creature"
#include "x0_i0_match"
#include "x2_inc_itemprop"

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

object GetHenchmanByIndex(object oPlayer, int nIndex=0)
{
    if (GetIsPC(oPlayer))
    {
        object oParty = GetFirstFactionMember(oPlayer, FALSE);

        while (GetIsObjectValid(oParty))
        {
            if (GetStringLeft(GetResRef(oParty), 3) == "hen" && GetMaster(oParty) == oPlayer)
            {
                if (nIndex <= 0) { return oParty; }
                nIndex--;
            }
            oParty = GetNextFactionMember(oPlayer, FALSE);
        }
    }
    return OBJECT_INVALID;
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
    if (GetLocalString(oModule, "hen_dorna_master") == sUUID) SetMaster(GetObjectByTag("hen_dorna"), oPlayer);
    if (GetLocalString(oModule, "hen_mischa_master") == sUUID) SetMaster(GetObjectByTag("hen_mischa"), oPlayer);
    if (GetLocalString(oModule, "hen_xanos_master") == sUUID) SetMaster(GetObjectByTag("hen_xanos"), oPlayer);
}

object GetPawnshopForHenchman(object oHench)
{
    string sTag = GetTag(oHench);
    if (sTag == "hen_daelan" || sTag == "hen_bim" || sTag == "hen_linu" || sTag == "hen_tomi" || sTag == "hen_sharwyn")
    {
        return GetObjectByTag("mer_olgerd");
    }
    else if (sTag == "hen_boddyknock" || sTag == "hen_grimgnaw")
    {
        return GetObjectByTag("mer_haljal");
    }
    else if (sTag == "hen_valen" || sTag == "hen_nathyrra")
    {
        return GetObjectByTag("mer_ravyn");
    }
    else if (sTag == "hen_dorna" || sTag == "hen_mischa" || sTag == "hen_xanos")
    {
        return GetObjectByTag("mer_branson");
    }
    return OBJECT_INVALID;
}

void DismissHenchman(object oHench)
{
    // They take their store items and sell them at the local pawnshop. After all, they never upgrade their gear with "real" loot items
    // (I guess they wouldn't sell potions they picked up though, but those stay in their inventory)
    object oStore = GetLocalObject(oHench, "merchant");
    object oPawnshop = GetPawnshopForHenchman(oHench);
    object oTest = GetFirstItemInInventory(oStore);
    if (GetIsObjectValid(oPawnshop) && GetObjectType(oPawnshop) == OBJECT_TYPE_STORE)
    {
        WriteTimestampedLogEntry("Copy " + GetName(oHench) + "'s items to " + GetName(oPawnshop) + ", test item = " + GetName(oTest));
        while (GetIsObjectValid(oTest))
        {
            if (!GetPlotFlag(oTest))
            {
                CopyItem(oTest, oPawnshop, TRUE);
            }
            oTest = GetNextItemInInventory(oStore);
        }
    }
    else
    {
        if (!GetIsObjectValid(oPawnshop))
        {
            WriteTimestampedLogEntry("Warning: Henchman " + GetName(oHench) + " was dismissed but has no pawnshop to put their items in");
        }
        else if (GetObjectType(oPawnshop) != OBJECT_TYPE_STORE)
        {
            WriteTimestampedLogEntry("Warning: Henchmen " + GetName(oHench) + " had a valid pawnshop but this object is not a store");
        }
    }
    DestroyObject(oStore, 10.0);
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

void _ScaleHenchmanWeaponry(object oHench, int nBonus)
{
    IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oHench), ItemPropertyEnhancementBonus(nBonus), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
    // Don't duplicate enh and att bonus - enh goes on melee, att goes on range
    if (IPGetIsMeleeWeapon(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oHench)))
    {
        IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oHench), ItemPropertyEnhancementBonus(nBonus), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
    }
    else
    {
        IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oHench), ItemPropertyAttackBonus(nBonus), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
    }
    
    // Don't put deflection bonus on offhand melees
    if (!IPGetIsMeleeWeapon(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oHench)))
    {
        IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oHench), ItemPropertyACBonus(nBonus), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
    }
    
    IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_ARMS, oHench), ItemPropertyAttackBonus(nBonus), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
    IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_ARMS, oHench), ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_COLD, nBonus), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
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
            if (nHenchmanLevel == 7)
            {
                NWNX_Creature_AddFeatByLevel(oHench, FEAT_WEAPON_OF_CHOICE_HEAVYFLAIL, 7);
                NWNX_Creature_AddFeat(oHench, FEAT_WEAPON_OF_CHOICE_HEAVYFLAIL);
            }
        }
        else if (sResRef == "hen_nathyrra" && nHenchmanLevel == 8)
        {
            nClass = CLASS_TYPE_SHADOWDANCER;
            nPackage = 141;
        }
        else if (sResRef == "hen_dorna")
        {
            nClass = CLASS_TYPE_ROGUE;
            nPackage = 143;
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
        
        // We want more powerful itemprops to overwrite the weaker ones
        // Not doing this results in the henchman's equipment having a ILR that is too high to allow them to reequip it
        // if something like a Bebilith comes along and forces it off them
        
        // Eg level 12 Bim's Longsword has a gold value of 146k from just Enhancement +1-3 and Attack +1-3
        // Despite the fact it functions as regular Longsword +3 in all ways
        
        // Moving the attribute bonus onto the amulet in an attempt to go with the whole "this is the rest of the henchman's slots" thing
        // The result is that the amulet will have an absurd value, but that shouldn't matter... probably...
        // ...hopefully nobody writes a script that forcefully takes off amulets, or they'll need to fix this :)

        switch (nHenchmanLevel)
        {
            case 3:
                IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_NECK, oHench), ItemPropertyACBonus(1), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
            break;
            case 4:
                IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_CLOAK, oHench), ItemPropertyACBonus(1), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
                IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_CLOAK, oHench), ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_UNIVERSAL, 1), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
            break;
            case 5:
                IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_CHEST, oHench), ItemPropertyACBonus(1), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
                IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_NECK, oHench), ItemPropertyRegeneration(1), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
                IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_NECK, oHench), ItemPropertyAbilityBonus(GetLocalInt(oHench, "ability"), 1), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
            break;
            case 6:
                IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_NECK, oHench), ItemPropertyACBonus(2), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
                
                _ScaleHenchmanWeaponry(oHench, 1);
            break;
            case 7:
                IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_CLOAK, oHench), ItemPropertyACBonus(2), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
                IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_CLOAK, oHench), ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_UNIVERSAL, 2), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
            break;
            case 8:
                IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_CHEST, oHench), ItemPropertyACBonus(2), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
                IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_NECK, oHench), ItemPropertyAbilityBonus(GetLocalInt(oHench, "ability"), 2), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
            break;
            case 9:
                IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_NECK, oHench), ItemPropertyACBonus(3), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
                _ScaleHenchmanWeaponry(oHench, 2);
            break;
            case 10:
                IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_CLOAK, oHench), ItemPropertyACBonus(3), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
                IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_CLOAK, oHench), ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_UNIVERSAL, 3), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
            break;
            case 11:
                IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_CHEST, oHench), ItemPropertyACBonus(3), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
                IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_NECK, oHench), ItemPropertyAbilityBonus(GetLocalInt(oHench, "ability"), 3), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
            break;
            case 12:
                _ScaleHenchmanWeaponry(oHench, 3);
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
