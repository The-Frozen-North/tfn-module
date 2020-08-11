#include "inc_xp"
#include "inc_gold"

// =======================================================
// PROTOTYPES
// =======================================================

// Levels up the henchman and gear appropriately.
// Equal to player level. 2 level minimum.
void ScaleHenchman(object oHench);

// Clears out the master for the henchman
void ClearMaster(object oHench);

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

    while ((nHenchmanLevel < nTargetLevel))
    {
// return early if it fails
        if (LevelUpHenchman(oHench) == 0)
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
            break;
            case 5:
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyACBonus(1), GetItemInSlot(INVENTORY_SLOT_CHEST, oHench));
            break;
            case 6:
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyACBonus(2), GetItemInSlot(INVENTORY_SLOT_NECK, oHench));

                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyEnhancementBonus(1), GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oHench));
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAttackBonus(1), GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oHench));
            break;
            case 7:
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyACBonus(2), GetItemInSlot(INVENTORY_SLOT_CLOAK, oHench));
            break;
            case 8:
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyACBonus(2), GetItemInSlot(INVENTORY_SLOT_CHEST, oHench));
            break;
            case 9:
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyACBonus(3), GetItemInSlot(INVENTORY_SLOT_NECK, oHench));

                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyEnhancementBonus(2), GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oHench));
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAttackBonus(2), GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oHench));
            break;
            case 10:
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyACBonus(3), GetItemInSlot(INVENTORY_SLOT_CLOAK, oHench));
            break;
            case 11:
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyACBonus(3), GetItemInSlot(INVENTORY_SLOT_CHEST, oHench));
            break;
            case 12:
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyEnhancementBonus(3), GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oHench));
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAttackBonus(3), GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oHench));
            break;
        }
    }
}

void ClearMaster(object oHench)
{
// Make sure this is a henchman
    if (GetStringLeft(GetResRef(oHench), 3) != "hen") return;

    string sResRef = GetResRef(oHench);

    DeleteLocalString(GetModule(), sResRef+"_master");

    RemoveHenchman(GetMaster(oHench), oHench);

    SetLocalInt(oHench, "pending_destroy", 1);
}

void SetMaster(object oHench, object oPlayer)
{
// Make sure this is a henchman
    if (GetStringLeft(GetResRef(oHench), 3) != "hen") return;

// Make sure oPlayer is actually a player
    if (!GetIsPC(oPlayer)) return;

    SetLocalString(GetModule(), GetResRef(oHench)+"_master", GetObjectUUID(oPlayer));

    AddHenchman(oPlayer, oHench);
    ScaleHenchman(oHench);
}

//void main(){}
