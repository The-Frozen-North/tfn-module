//::///////////////////////////////////////////////
//:: Pit Fiend Payload
//:: NW_S0_2PitFiend
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    DEATH --- DEATH --- BO HA HA HA
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 11, 2002
//:://////////////////////////////////////////////
/*
Patch 1.72

- poison immunity prevents all effects
- on hardcore rules or high difficult difficulty, the death effect ignores immunity to death spells
*/

void main()
{
    object oTarget = OBJECT_SELF;

    //if character is immune to poison, print immunity feedback and exit
    if(GetIsImmune(oTarget,IMMUNITY_TYPE_POISON,OBJECT_INVALID))
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectPoison(0),oTarget);
        return;
    }

    effect eDrain = EffectDeath();
    if(GetGameDifficulty() >= GAME_DIFFICULTY_CORE_RULES)
    {
        eDrain = SupernaturalEffect(eDrain);
    }
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH);

    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eDrain, oTarget);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
}
