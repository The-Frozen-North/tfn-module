/************************ [On Disturbed] ***************************************
    Filename: j_ai_ondisturbed or nw_c2_default8
************************* [On Disturbed] ***************************************
    This will attack pickpockets, and inventory disturbers. Note: Stupidly, Bioware
    made this only affect the creature by stealing. Still, oh well :-(

    This means that the only event which fires it is pickpocketing.
************************* [History] ********************************************
    1.3 - Changed why we determine combat round
        - Any change in inventory will trigger appropriate SetWeapons again.
        - Added turn of hide things.
************************* [Workings] *******************************************
    Only fired by stealing, great. Oh well, it will attack any disturber anyway.

    It *might* not be fired if the natural spot check to notice a theft doesn't
    work. No idea personally.
************************* [Arguments] ******************************************
    Arguments: GetInventoryDisturbItem, GetLastDisturbed,
               GetInventoryDisturbType (I think it is always be stolen :-( ).
************************* [On Disturbed] **************************************/

#include "j_inc_other_ai"

void main()
{
    // Pre-disturbed-event
    if(FireUserEvent(AI_FLAG_UDE_DISTURBED_PRE_EVENT, EVENT_DISTURBED_PRE_EVENT))
        // We may exit if it fires
        if(ExitFromUDE(EVENT_DISTURBED_PRE_EVENT)) return;

    // AI status check. Is the AI on?
    if(GetAIOff()) return;

    // We will set weapons if it is a weapon.
    object oItem = GetInventoryDisturbItem();
    int nBase = GetBaseItemType(oItem);
    object oDisturber = GetLastDisturbed();
    int iType = GetInventoryDisturbType();
    string Middle;
    // Reset weapons, or specifically healers kits.
    if(GetIsObjectValid(oItem))
    {
        // Kits
        if(nBase == BASE_ITEM_HEALERSKIT)
        {
            SetLocalInt(OBJECT_SELF, AI_WEAPONSETTING_SETWEAPONS, i2);
            ExecuteScript(FILE_RE_SET_WEAPONS, OBJECT_SELF);
        }
        else // Think it is a weapon. Saves time :-)
        {
            SetLocalInt(OBJECT_SELF, AI_WEAPONSETTING_SETWEAPONS, i1);
            ExecuteScript(FILE_RE_SET_WEAPONS, OBJECT_SELF);
        }
    }
    // Fight! Or search!
    if(GetIsObjectValid(oDisturber) && !GetIsDM(oDisturber) && !GetFactionEqual(oDisturber) &&
      (iType == INVENTORY_DISTURB_TYPE_STOLEN || GetIsEnemy(oDisturber)))
    {
        // Turn of hiding, a timer to activate Hiding in the main file. This is
        // done in each of the events, with the opposition checking seen/heard.
        TurnOffHiding(oDisturber);
        if(!CannotPerformCombatRound())
        {
            AISpeakString(CALL_TO_ARMS);
            // One debug speak. We always do one.
            // 65: "[Disturbed] (pickpocket) Attacking Enemy Distrube [Disturber] " + GetName(oTarget) + " [Type] " + IntToString(iType)
            DebugActionSpeakByInt(65, oDisturber, iType);
            DetermineCombatRound(oDisturber);
        }
    }

    // Fire End-heartbeat-UDE
    FireUserEvent(AI_FLAG_UDE_DISTURBED_EVENT, EVENT_DISTURBED_EVENT);
}
