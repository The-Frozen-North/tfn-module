//::///////////////////////////////////////////////
//:: Name
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    These bard lyrics will 'use' your bard song.

    The Lich Song:
        - always a Horrid Wilting once per day.

*/
//:://////////////////////////////////////////////
//:: Created By:
//:: Created On:
//:://////////////////////////////////////////////
/*
Patch 1.72
- caster level of the horrid wilting will be equal to bard level (minimum 10)
Patch 1.71
- not useable silenced anymore
- added deaf failure chance
*/

#include "x0_i0_spells"

void main()
{
    if (!GetHasFeat(FEAT_BARD_SONGS, OBJECT_SELF))
    {
        FloatingTextStrRefOnCreature(40063,OBJECT_SELF,FALSE);
    }
    else if (GetHasEffect(EFFECT_TYPE_SILENCE,OBJECT_SELF))
    {
        FloatingTextStrRefOnCreature(85764,OBJECT_SELF); // not useable when silenced
    }
    else if(GetGameDifficulty() >= GAME_DIFFICULTY_CORE_RULES && d100() < 21 && GetHasEffect(EFFECT_TYPE_DEAF,OBJECT_SELF))
    {                                                    // 20% chance to fail under deafness
        FloatingTextStrRefOnCreature(83576,OBJECT_SELF); //* You can not concentrate on using this ability effectively *
        return;
    }
    else
    {
        DecrementRemainingFeatUses(OBJECT_SELF, FEAT_BARD_SONGS);
        PlaySound("as_cv_flute2");

        int nLevel = GetLevelByClass(CLASS_TYPE_BARD);
        if(nLevel < 10) nLevel = 10;
        int prevCL = GetLocalInt(OBJECT_SELF,"SPECIAL_ABILITY_CASTER_LEVEL_OVERRIDE");
        SetLocalInt(OBJECT_SELF,"SPECIAL_ABILITY_CASTER_LEVEL_OVERRIDE",nLevel);
        ActionCastSpellAtObject(SPELL_HORRID_WILTING, OBJECT_SELF, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
        DelayCommand(1.1,SetLocalInt(OBJECT_SELF,"SPECIAL_ABILITY_CASTER_LEVEL_OVERRIDE",prevCL));//reset override to previous value to avoid affecting anything else
    }
}
