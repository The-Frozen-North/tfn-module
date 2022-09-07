#include "nwnx_events"
#include "nwnx_effect"
#include "inc_debug"

// Unfortunately there's no guarantee that the effect ID you're trying to save is actually ON the creature it seems
// at least, in the case of unique powers, it isn't, and a single DelayCommand pass is needed to pick it up
// Further thinking makes me wonder if there's truly any need to actually check the effect exists before saving its ID

void TryToSaveEffectID(object oItem, int nEventEffectID, int nRetries=5)
{
    string sEffectID = IntToString(nEventEffectID);
    effect eTest = GetFirstEffect(OBJECT_SELF);
    SendDebugMessage("Target effect ID: " + sEffectID);
    
    int nItemEffectListPos = 1;
    while (1)
    {
        if (!GetLocalInt(oItem, "SelfCastEffectID" + IntToString(nItemEffectListPos)))
        {
            break;
        }
        nItemEffectListPos++;
    }
    SendDebugMessage("Saved effect ID at index: " + IntToString(nItemEffectListPos));
    SetLocalInt(oItem, "SelfCastEffectID" + IntToString(nItemEffectListPos), nEventEffectID);
    return;
    
    /*while (GetIsEffectValid(eTest))
    {
        struct NWNX_EffectUnpacked eUnpacked = NWNX_Effect_UnpackEffect(eTest);
        SendDebugMessage("This effect ID: " + eUnpacked.sID);
        if (sEffectID == eUnpacked.sID)
        {
            int nItemEffectListPos = 1;
            while (1)
            {
                if (!GetLocalInt(oItem, "SelfCastEffectID" + IntToString(nItemEffectListPos)))
                {
                    break;
                }
                nItemEffectListPos++;
            }
            SendDebugMessage("Saved effect ID at index: " + IntToString(nItemEffectListPos));
            SetLocalInt(oItem, "SelfCastEffectID" + IntToString(nItemEffectListPos), nEventEffectID);
            return;
        }
        eTest = GetNextEffect(OBJECT_SELF);
    }
    nRetries--;
    if (nRetries > 0)
    {
        DelayCommand(0.0, TryToSaveEffectID(oItem, nEventEffectID, nRetries));
    }
    */
}

void main()
{
    if (GetLocalInt(OBJECT_SELF, "SelfCastItemSpell"))
    {
        int nItemSpell = GetLocalInt(OBJECT_SELF, "SelfCastItemSpell");
        object oItem = GetLocalObject(OBJECT_SELF, "SelfCastItem");
        object oCreator = StringToObject(NWNX_Events_GetEventData("CREATOR"));
        SendDebugMessage("SelfCastItemSpell is set: ItemSpell = " + IntToString(nItemSpell) + ", item = " + GetName(oItem) + ", creator = " + GetName(oCreator));
        SendDebugMessage("Event spell ID = " + NWNX_Events_GetEventData("SPELL_ID"));
        
        // Unique power doesn't get the usual NWNX spell ID
        if (nItemSpell == StringToInt(NWNX_Events_GetEventData("SPELL_ID")) 
            || (nItemSpell == 413 && NWNX_Events_GetEventData("SPELL_ID") == "4294967295"))
        {
            if (GetItemPossessor(oItem) == OBJECT_SELF && oCreator == OBJECT_SELF)
            {
                // Clear up all the old variables that aren't needed
                // Having someone who keeps their ring of force shield on forever end up with hundreds of effect IDs
                // is not ideal
                // This isn't written in a very efficient manner - based on the assumption that most items
                // can probably only apply a small number of possible effects, so this list should not get very large at all
                // Should be obvious via profiling if this becomes an issue, and if so finding a way
                // to track the list of active effects on a creature that isn't iterating over them repeatedly
                // should be the answer
                int nItemEffectListPos = 1;
                // "gaps" in this array should not be allowed. The script that removes all effects on unequip
                // needs to know definitively when there are no more in the array!
                while (1)
                {
                    if (!GetLocalInt(oItem, "SelfCastEffectID" + IntToString(nItemEffectListPos)))
                    {
                        nItemEffectListPos--;
                        break;
                    }
                    nItemEffectListPos++;
                }
                
                
                SendDebugMessage("Checking for obsolete effect ids");
                while (nItemEffectListPos >= 1)
                {
                    // See if the last thing in the array is valid
                    string sLastEffectID = IntToString(GetLocalInt(oItem, "SelfCastEffectID" + IntToString(nItemEffectListPos)));
                    effect eTest = GetFirstEffect(OBJECT_SELF);
                    SendDebugMessage("Target effect ID: " + sLastEffectID + " at index " + IntToString(nItemEffectListPos));
                    int bFound = 0;
                    while (GetIsEffectValid(eTest))
                    {
                        struct NWNX_EffectUnpacked eUnpacked = NWNX_Effect_UnpackEffect(eTest);
                        SendDebugMessage("This effect ID: " + eUnpacked.sID);
                        if (sLastEffectID == eUnpacked.sID)
                        {
                            bFound = 1;
                            break;
                        }                
                        eTest = GetNextEffect(OBJECT_SELF);
                    }
                    if (bFound)
                    {
                        // It's valid, can't do anything
                        break;
                    }
                    // It's not valid, clear it
                    SendDebugMessage("Clear obsolete effect ID: " + sLastEffectID);
                    DeleteLocalInt(oItem, "SelfCastEffectID" + IntToString(nItemEffectListPos));
                    nItemEffectListPos--;
                }
                
                // Find the effect we just added, if it's valid, save it
                SendDebugMessage("Saving new effect id");
                string sEffectID = NWNX_Events_GetEventData("UNIQUE_ID");
                int nEffectID = StringToInt(sEffectID);
                TryToSaveEffectID(oItem, nEffectID); 
                
            }
        }
    }
}