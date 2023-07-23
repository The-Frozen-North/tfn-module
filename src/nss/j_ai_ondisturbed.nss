/*/////////////////////// [On Disturbed] ///////////////////////////////////////
    Filename: J_AI_OnDisturbed or nw_c2_default8
///////////////////////// [On Disturbed] ///////////////////////////////////////
    This will attack pickpockets, and inventory disturbers. Note: Stupidly, Bioware
    made this only affect the creature by stealing. Still, oh well :-(

    This means that the only event which fires it is pickpocketing.
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - Changed why we determine combat round
        - Any change in inventory will trigger appropriate SetWeapons again.
        - Added turn of hide things.
    1.4 - Cleaned up a bit. Removed unused declared variable.
///////////////////////// [Workings] ///////////////////////////////////////////
    Only fired by stealing, great. Oh well, it will attack any disturber anyway.

    It *might* not be fired if the natural spot check to notice a theft doesn't
    work. No idea personally.
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: GetInventoryDisturbItem, GetLastDisturbed,
               GetInventoryDisturbType (I think it is always be stolen :-( ).
///////////////////////// [On Disturbed] /////////////////////////////////////*/

#include "J_INC_OTHER_AI"

void main()
{
    // Pre-disturbed-event. Returns TRUE if we interrupt this script call.
    if(FirePreUserEvent(AI_FLAG_UDE_DISTURBED_PRE_EVENT, EVENT_DISTURBED_PRE_EVENT)) return;

    // AI status check. Is the AI on?
    if(GetAIOff()) return;

    // Declare major variables
    object oDisturber = GetLastDisturbed();
    object oItem = GetInventoryDisturbItem();
    int nType = GetInventoryDisturbType();
    int nBase = GetBaseItemType(oItem);

    // We will reset weapons if it is a weapon.
    // Reset weapons, or specifically healers kits.
    if(GetIsObjectValid(oItem))
    {
        // Kits
        if(nBase == BASE_ITEM_HEALERSKIT)
        {
            SetLocalInt(OBJECT_SELF, AI_WEAPONSETTING_SETWEAPONS, 2);
            ExecuteScript(FILE_RE_SET_WEAPONS, OBJECT_SELF);
        }
        else // Think it is a weapon. Saves time :-)
        {
            SetLocalInt(OBJECT_SELF, AI_WEAPONSETTING_SETWEAPONS, 1);
            ExecuteScript(FILE_RE_SET_WEAPONS, OBJECT_SELF);
        }
    }
    // Fight! Or search!
    if(!GetIgnoreNoFriend(oDisturber) &&
      (nType == INVENTORY_DISTURB_TYPE_STOLEN || GetIsEnemy(oDisturber)))
    {
        // Turn of hiding, a timer to activate Hiding in the main file. This is
        // done in each of the events, with the opposition checking seen/heard.
        TurnOffHiding(oDisturber);

        // Can we attack?
        if(!CannotPerformCombatRound())
        {
            // Someone specific to attack
            AISpeakString(AI_SHOUT_I_WAS_ATTACKED);

            // One debug speak. We always do one.
            // 65: "[Disturbed] (pickpocket) Attacking Enemy Distrube [Disturber] " + GetName(oTarget) + " [Type] " + IntToString(iType)
            DebugActionSpeakByInt(65, oDisturber, nType);

            // Attack the disturber
            DetermineCombatRound(oDisturber);
        }
        else
        {
            // Get allies interested.
            AISpeakString(AI_SHOUT_CALL_TO_ARMS);
        }
    }

    // Fire End-heartbeat-UDE
    FireUserEvent(AI_FLAG_UDE_DISTURBED_EVENT, EVENT_DISTURBED_EVENT);
}
