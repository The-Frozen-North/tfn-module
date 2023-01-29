#include "inc_debug"
#include "nwnx_util"
#include "inc_loot"


// run via dm_runscript
// Kills everything in the area, as if you went and did it properly, and brings all the loot to you
// And tells you how much gold value there was in it

void KillCreature(object oCreature)
{
    SendMessageToPC(OBJECT_SELF, "Kill: " + GetName(oCreature));
    // Hopefully nothing lives this
    //ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oCreature);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(9999), oCreature);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(9999, DAMAGE_TYPE_DIVINE), oCreature);
    // idk something that should damage placeables
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(9999, DAMAGE_TYPE_PIERCING), oCreature);
}

void DelayedAction(int nStartXP)
{
    int nOldInstructionLimit = NWNX_Util_GetInstructionLimit();
    NWNX_Util_SetInstructionLimit(52428888);

    object oDev = OBJECT_SELF;

    int nXPDelta = GetXP(oDev) - nStartXP;
    SendMessageToPC(oDev, "XP delta = " + IntToString(nXPDelta));

    // This is just some placeable without scripts attached and that has a workable inventory
    object oMyContainer = CreateObject(OBJECT_TYPE_PLACEABLE, "x2_plc_bbarrel", GetLocation(oDev));
    SetLocalInt(oMyContainer, "dev_lootvortex_container", 1);
    DelayCommand(120.0f, DestroyObject(oMyContainer));


    int nTotalGoldValue = 0;

    object oArea = GetArea(oDev);
    object oTest = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oTest))
    {
        if (GetResRef(oTest) == "_loot_container")
        {
            //SendMessageToPC(oDev, "Found loot container!");
            object oPersonalLoot = GetObjectByUUID(GetLocalString(oTest, "personal_loot_"+GetPCPublicCDKey(oDev, TRUE)));

            object oInvItem = GetFirstItemInInventory(oPersonalLoot);

            while (GetIsObjectValid(oInvItem))
            {
                SetIdentified(oInvItem, TRUE);
                nTotalGoldValue += GetGoldPieceValue(oInvItem);
                object oNew = CopyItem(oInvItem, oMyContainer);
                DelayCommand(115.0, DestroyObject(oNew));
                DelayCommand(0.1, DestroyObject(oInvItem));
                oInvItem = GetNextItemInInventory(oPersonalLoot);
            }
            DelayCommand(0.5, DecrementLootAndDestroyIfEmpty(oDev, oTest, oPersonalLoot));
        }
        oTest = GetNextObjectInArea(oArea);
    }

    SendMessageToPC(oDev, "Total gold value = " + IntToString(nTotalGoldValue));
    DeleteLocalObject(GetModule(), "dev_lootvortex");
    NWNX_Util_SetInstructionLimit(nOldInstructionLimit);
}

void main()
{
    object oDev = OBJECT_SELF;
    if (!GetIsDevServer())
    {
        SendMessageToAllDMs(GetName(oDev) + " tried to run dev_lootvortex, but the server is not in developer mode");
        return;
    }

    if (!GetIsDeveloper(oDev))
    {
        SendMessageToAllDMs(GetName(oDev) + " tried to run dev_lootvortex, but they are not a developer");
        return;
    }
    SendMessageToAllDMs(GetName(oDev) + " is running dev_lootvortex in area: " + GetName(GetArea(oDev)));
    SendDiscordLogMessage(GetName(oDev) + " is running dev_lootvortex in area: " + GetName(GetArea(oDev)));


    SetLocalObject(GetModule(), "dev_lootvortex", oDev);

    // This is way easier than circumvention...
    int nOldInstructionLimit = NWNX_Util_GetInstructionLimit();
    NWNX_Util_SetInstructionLimit(52428888);

    object oArea = GetArea(oDev);
    object oTest = GetFirstObjectInArea(oArea);
    int nStartXP = GetXP(oDev);
    while (GetIsObjectValid(oTest))
    {
        int nObjType = GetObjectType(oTest);
        if (nObjType == OBJECT_TYPE_CREATURE)
        {
            if (!GetIsDead(oTest) && !GetIsPC(oTest))
            {
                DelayCommand(0.1, KillCreature(oTest));
                DelayCommand(0.2, ExecuteScript("party_credit", oTest));
            }
        }
        else if (nObjType == OBJECT_TYPE_PLACEABLE)
        {
            if (GetLocalInt(oTest, "cr") > 0 && GetResRef(oTest) != "_loot_container")
            {
                SetPlotFlag(oTest, FALSE);
                DelayCommand(0.1, KillCreature(oTest));
                DelayCommand(0.2, ExecuteScript("party_credit", oTest));
            }
        }
        oTest = GetNextObjectInArea(oArea);
    }
    DelayCommand(6.0f, DelayedAction(nStartXP));
    NWNX_Util_SetInstructionLimit(nOldInstructionLimit);
}

