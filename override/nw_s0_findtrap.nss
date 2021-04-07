//::///////////////////////////////////////////////
//:: Find Traps
//:: NW_S0_FindTrap
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Finds and removes all traps within 30m.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 29, 2001
//:://////////////////////////////////////////////
/*
Patch 1.72
- trap will be revealed for all party members
Patch 1.71
- won't reveal undetectable traps anymore
- won't disable undisarmable traps anymore
- at DnD rules and higher difficulty setting, the spell no longer disarm traps at all
*/

#include "70_inc_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Range = 30.0;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_KNOCK);
    int nCnt = 1;
    object oParty, oTrap = GetNearestObject(OBJECT_TYPE_TRIGGER | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, spell.Caster, nCnt);
    while(GetIsObjectValid(oTrap) && GetDistanceToObject(oTrap) <= spell.Range)
    {
        if(GetIsTrapped(oTrap))
        {
            if(GetTrapDetectable(oTrap))
            {

                if ((spell.DC - 10 + d20()) >= GetTrapDisarmDC(oTrap))
                {
                    SetTrapDetectedBy(oTrap, spell.Caster);
                    DelayCommand(2.0, SetTrapDisabled(oTrap));
                }
 //1.72: reveal trap for all party members (even if they are not in same area)
                else
                {
                    FloatingTextStringOnCreature("*The spell failed to disarm the trap.*",spell.Caster);

                    oParty = GetFirstFactionMember(spell.Caster,FALSE);
                    while(GetIsObjectValid(oParty))
                    {
                        SetTrapDetectedBy(oTrap, oParty);
                        oParty = GetNextFactionMember(spell.Caster,FALSE);
                    }
                }

                ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, GetLocation(oTrap));
            }
        }
        oTrap = GetNearestObject(OBJECT_TYPE_TRIGGER | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, spell.Caster, ++nCnt);
    }
}
