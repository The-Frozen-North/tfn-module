//------------------------------------------------------------------------------
//                       Item Creation Feat Wrapper
//------------------------------------------------------------------------------
// This is the point where we link the craft item scripts into every
// spellcast script. It's called from x2_inc_spellhook
// The reason why it is wrapped in its own script is to allow it being cached
// and modified without recompiling every single spellscript
//------------------------------------------------------------------------------
// GZ, 2003-10-25; (c) 2003 Bioware Corp.
//------------------------------------------------------------------------------
/*
Patch 1.72
- new feature to override maximum brew potion/craft wand spell level
Patch 1.71
- handle stacked empty bottles/scrolls properly
- new feature to specify custom potion and wand via 2DA
- handle stacked material components properly
- new feature to specify material component for wand crafting/brewing
*/

#include "x2_inc_spellhook"

void main()
{
    object oTarget = GetSpellTargetObject();
    int nRet = (CIGetSpellWasUsedForItemCreation(oTarget));
    SetExecutedScriptReturnValue (nRet);
}
