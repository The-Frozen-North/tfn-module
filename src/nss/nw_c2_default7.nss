//:://////////////////////////////////////////////////
//:: NW_C2_DEFAULT7
/*
  Default OnDeath event handler for NPCs.

  Adjusts killer's alignment if appropriate and
  alerts allies to our death.
 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 12/22/2002
//:://////////////////////////////////////////////////
//:://////////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified On: April 1st, 2008
//:: Added Support for Dying Wile Mounted
//:://///////////////////////////////////////////////

#include "x2_inc_compon"
#include "x0_i0_spawncond"
#include "x0_inc_henai"

void main()
{
    // Delete all items on death.
    object oItem = GetFirstItemInInventory();

    while (GetIsObjectValid(oItem))
    {
            DestroyObject(oItem);
            oItem = GetNextItemInInventory();
    }

    // Destroy equipped items.
    int nSlot;
    for ( nSlot = 0; nSlot < NUM_INVENTORY_SLOTS; ++nSlot )
        DestroyObject(GetItemInSlot(nSlot));

    int nClass = GetLevelByClass(CLASS_TYPE_COMMONER);
    int nAlign = GetAlignmentGoodEvil(OBJECT_SELF);
    object oKiller = GetLastKiller();
    //1.72: improved AI to immediatelly start doing something after current enemy was killed
    if(GetObjectType(oKiller) == OBJECT_TYPE_TRIGGER)
    {
        oKiller = GetTrapCreator(oKiller);
    }
    else if(GetObjectType(oKiller) == OBJECT_TYPE_CREATURE && GetAssociateType(oKiller) != ASSOCIATE_TYPE_NONE)
    {
        object oIntruder = GetNearestSeenEnemy(oKiller);
        if(!GetIsObjectValid(oIntruder))
        {
            oIntruder = GetNearestSeenEnemy(GetMaster(oKiller));
        }
        AssignCommand(oKiller,HenchmenCombatRound(oIntruder));
    }
    object oIntruder, oParty = GetFirstFactionMember(oKiller,FALSE);
    while(GetIsObjectValid(oParty))
    {
        if(oParty != oKiller && GetAssociateType(oParty) != ASSOCIATE_TYPE_NONE && GetCommandable(oParty) && !GetAssociateState(NW_ASC_MODE_STAND_GROUND,oParty) && !GetAssociateState(0x02000000,oParty))
        {
            oIntruder = GetAttackTarget(oParty);
            if(oIntruder == OBJECT_SELF || GetIsDead(oIntruder) || !GetIsObjectValid(oIntruder))
            {
                oIntruder = GetNearestSeenEnemy(oParty);
                if(!GetIsObjectValid(oIntruder))
                {
                    oIntruder = GetNearestSeenEnemy(GetMaster(oParty));
                }
                AssignCommand(oParty,HenchmenCombatRound(oIntruder));
            }
        }
        oParty = GetNextFactionMember(oKiller,FALSE);
    }

    if (GetLocalInt(GetModule(),"X3_ENABLE_MOUNT_DB")&&GetIsObjectValid(GetMaster(OBJECT_SELF))) SetLocalInt(GetMaster(OBJECT_SELF),"bX3_STORE_MOUNT_INFO",TRUE);


    // If we're a good/neutral commoner,
    // adjust the killer's alignment evil
    if(nClass > 0 && (nAlign == ALIGNMENT_GOOD || nAlign == ALIGNMENT_NEUTRAL))
    {
        AdjustAlignment(oKiller, ALIGNMENT_EVIL, 5);
    }

    // Call to allies to let them know we're dead
    SpeakString("NW_I_AM_DEAD", TALKVOLUME_SILENT_TALK);

    //Shout Attack my target, only works with the On Spawn In setup
    SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);

    // NOTE: the OnDeath user-defined event does not
    // trigger reliably and should probably be removed
    if(GetSpawnInCondition(NW_FLAG_DEATH_EVENT))
    {
         SignalEvent(OBJECT_SELF, EventUserDefined(1007));
    }
    craft_drop_items(oKiller);
}
