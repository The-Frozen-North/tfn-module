//::///////////////////////////////////////////////
//:: Henchman Death Script
//::
//:: NW_CH_AC7.nss
//::
//:: Copyright (c) 2001-2008 Bioware Corp.
//:://////////////////////////////////////////////
//:: Official Campaign Henchmen Respawn
//:://////////////////////////////////////////////
//::
//:: Modified by:   Brent, April 3 2002
//::                Removed delay in respawning
//::                the henchman - caused bugs
//:
//::                Georg, Oct 8 2003
//::                Rewrote teleport to temple routine
//::                because it was broken by
//::                some delicate timing issues in XP2
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified On: April 9th, 2008
//:: Added Support for Dying Wile Mounted
//:://///////////////////////////////////////////////

#include "nw_i0_generic"
#include "nw_i0_plot"
#include "inc_general"
#include "x0_inc_henai"

// -----------------------------------------------------------------------------
// Georg, 2003-10-08
// Rewrote that jump part to get rid of the DelayCommand Code that was prone to
// timing problems. If want to see a really back hack, this function is just that.
// -----------------------------------------------------------------------------
void WrapJump(string sTarget)
{
    if (GetIsDead(OBJECT_SELF))
    {
        // * Resurrect and heal again, just in case
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectResurrection(), OBJECT_SELF);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectHeal(GetMaxHitPoints(OBJECT_SELF)), OBJECT_SELF);

        // * recursively call self until we are alive again
        DelayCommand(1.0f,WrapJump( sTarget));
        return;
    }
    // * since the henchmen are teleporting very fast now, we leave a bloodstain on the ground
    object oBlood = CreateObject(OBJECT_TYPE_PLACEABLE,"plc_bloodstain", GetLocation(OBJECT_SELF));

    // * Remove blood after a while
    DestroyObject(oBlood,30.0f);

    // * Ensure the action queue is open to modification again
    SetCommandable(TRUE,OBJECT_SELF);

    // * Jump to Target
    JumpToObject(GetObjectByTag(sTarget), FALSE);

    // * Unset busy state
    ActionDoCommand(SetAssociateState(NW_ASC_IS_BUSY, FALSE));

    // * Make self vulnerable
    SetPlotFlag(OBJECT_SELF, FALSE);

    // * Set destroyable flag to leave corpse
    DelayCommand(6.0f, SetIsDestroyable(TRUE, TRUE, TRUE));
}

void main()
{
    SetLocalString(OBJECT_SELF,"sX3_DEATH_SCRIPT","nw_ch_ac7");
    DeleteLocalString(OBJECT_SELF,"sX3_DEATH_SCRIPT");

    //1.72: improved AI to immediatelly start doing something after current enemy was killed
    object oKiller = GetLastKiller();
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

    // * This is used by the advanced henchmen
    // * Let Brent know if it interferes with animal
    // * companions et cetera
    if (GetIsObjectValid(GetMaster()) == TRUE)
    {
        // * I am a familiar, give 1d6 damage to my master
        if (GetAssociate(ASSOCIATE_TYPE_FAMILIAR, GetMaster()) == OBJECT_SELF)
        {
            // April 2002: Made it so that familiar death can never kill the player
            // only wound them.
            int nDam =d6();
            if (nDam >= GetCurrentHitPoints(GetMaster()))
            {
                nDam = GetCurrentHitPoints(GetMaster()) - 1;
            }
            effect eDam = EffectDamage(nDam);
            FloatingTextStrRefOnCreature(63489, GetMaster(), FALSE);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eDam, GetMaster());
        }
    }

    if (GibsNPC(OBJECT_SELF))
    {
        DoMoraleCheckSphere(OBJECT_SELF, MORALE_PANIC_GIB_DC);
    }
    else
    {
        DoMoraleCheckSphere(OBJECT_SELF, MORALE_PANIC_DEATH_DC);
    }
}
