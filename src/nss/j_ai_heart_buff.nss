/*/////////////////////// [On Heartbeat - Buff] ////////////////////////////////
    Filename: j_ai_heart_buff
///////////////////////// [On Heartbeat - Buff] ////////////////////////////////
    This is ExecuteScript'ed from the heartbeat file, if they want to buff
    themselves with spells to be prepared for any battle coming up.
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - Added
    1.4 - Will Add all the appropriate Hordes spells, notably the missing epic ones.
///////////////////////// [Workings] ///////////////////////////////////////////
    This contains Advance Buffing - IE quick protection spells.
    I've done what ones I think are useful - IE most protection ones & summons!

    This doesn't include any which are (potentionally) very short duration (IE:
    1 round/level, or a set value):

    Elemntal shield/Wounding whispers (though you can add all of these!)
    Aid, bless, aura of vitality, aura of glory, blood frenzy, prayer,
    divine* Range (Power, Might, Shield, Favor), Expeditious retreat,
    holy/unholy aura (or protection from /magic circle against),
    natures balance, one with the land, shield of faith, virtue, war cry, dirge,
    death armor, mestals acid sheath.
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: N/A
///////////////////////// [On Heartbeat - Buff] //////////////////////////////*/

// Constants for some unconstantanated spells
#include "J_INC_CONSTANTS"

// Wrapper, to stop repeating the same lines! :-)
int BuffCastSpell(int nSpell);

void main()
{
    // For summons counter.
    int nCnt, bBreak;
    // FAST BUFF SELF
    // Stop what we are doing first, to perform the actions.
    ClearAllActions();

    // Always cast "Epic Warding" and "Epic Mage Armor".
    BuffCastSpell(FEAT_EPIC_SPELL_EPIC_WARDING);
    BuffCastSpell(FEAT_EPIC_SPELL_MAGE_ARMOUR);

    // Combat Protections
    if(!BuffCastSpell(SPELL_PREMONITION))
        if(!BuffCastSpell(SPELL_GREATER_STONESKIN))
            BuffCastSpell(SPELL_STONESKIN);

    // Visage Protections
    if(!BuffCastSpell(SPELL_SHADOW_SHIELD))
        if(!BuffCastSpell(SPELL_ETHEREAL_VISAGE))
            BuffCastSpell(SPELL_GHOSTLY_VISAGE);

    // Mantle Protections
    if(!BuffCastSpell(SPELL_GREATER_SPELL_MANTLE))
        if(!BuffCastSpell(SPELL_SPELL_MANTLE))
            BuffCastSpell(SPELL_LESSER_SPELL_MANTLE);

    // True seeing, see invisibility. We take true seeing to be better then the latter.
    if(BuffCastSpell(SPELL_TRUE_SEEING))
        BuffCastSpell(SPELL_SEE_INVISIBILITY);

    // Elemental Protections. 4 lots. From 40/- to 10/-
    if(!BuffCastSpell(SPELL_ENERGY_BUFFER))
        if(!BuffCastSpell(SPELL_PROTECTION_FROM_ELEMENTS))
            if(!BuffCastSpell(SPELL_RESIST_ELEMENTS))
                BuffCastSpell(SPELL_ENDURE_ELEMENTS);

    // Mental Protections
    if(!BuffCastSpell(SPELL_MIND_BLANK))
        if(!BuffCastSpell(SPELL_LESSER_MIND_BLANK))
            BuffCastSpell(SPELL_CLARITY);

    // Globes
    if(!BuffCastSpell(SPELL_GLOBE_OF_INVULNERABILITY))
        BuffCastSpell(SPELL_MINOR_GLOBE_OF_INVULNERABILITY);

    // Invisibility
    // Note: Improved has 50% consealment, etherealness has just invisiblity.
    if(!BuffCastSpell(SPELL_IMPROVED_INVISIBILITY))
        BuffCastSpell(SPELL_DISPLACEMENT);//50% consealment
    if(!BuffCastSpell(SPELL_ETHEREALNESS))
        if(!BuffCastSpell(SPELL_INVISIBILITY_SPHERE))
            if(!BuffCastSpell(SPELL_INVISIBILITY))
                BuffCastSpell(SPELL_SANCTUARY);

    // The stat-increasing ones.
    if(!BuffCastSpell(SPELL_GREATER_BULLS_STRENGTH))
        BuffCastSpell(SPELL_BULLS_STRENGTH);
    if(!BuffCastSpell(SPELL_GREATER_CATS_GRACE))
        BuffCastSpell(SPELL_CATS_GRACE);
    if(!BuffCastSpell(SPELL_GREATER_EAGLE_SPLENDOR))
        BuffCastSpell(SPELL_EAGLE_SPLEDOR);
    if(!BuffCastSpell(SPELL_GREATER_FOXS_CUNNING))
        BuffCastSpell(SPELL_FOXS_CUNNING);
    if(!BuffCastSpell(SPELL_GREATER_ENDURANCE))
        BuffCastSpell(SPELL_ENDURANCE);
    if(!BuffCastSpell(AI_SPELL_OWLS_INSIGHT))
        if(!BuffCastSpell(SPELL_GREATER_OWLS_WISDOM))
            BuffCastSpell(SPELL_OWLS_WISDOM);

    // Mage armor or shield. Don't stack them.
    if(!BuffCastSpell(SPELL_SHIELD))
        BuffCastSpell(SPELL_MAGE_ARMOR);
    // Entropic Shield (20% consealment, 1 turn/level)
    BuffCastSpell(SPELL_ENTROPIC_SHIELD);

    // Protection from negative energy
    if(!BuffCastSpell(SPELL_UNDEATHS_ETERNAL_FOE))
        BuffCastSpell(SPELL_DEATH_WARD);
    //Misc Protections which have no more powerful.
    BuffCastSpell(SPELL_BARKSKIN);
    BuffCastSpell(SPELL_ENTROPIC_SHIELD);
    BuffCastSpell(SPELL_PROTECTION_FROM_SPELLS);
    BuffCastSpell(SPELL_REGENERATE);
    BuffCastSpell(SPELL_DARKVISION);
    BuffCastSpell(SPELL_REGENERATE);
    BuffCastSpell(SPELL_SPELL_RESISTANCE);
    BuffCastSpell(SPELL_FREEDOM_OF_MOVEMENT);
    BuffCastSpell(SPELL_FREEDOM_OF_MOVEMENT);

//  Low durations (Rounds per caster level)
//    if(!BuffCastSpell(SPELL_ELEMENTAL_SHIELD))
//        BuffCastSpell(SPELL_WOUNDING_WHISPERS);
//        BuffCastSpell(SPELL_DEATH_ARMOR);


    //Summon Ally.
    // Spell ID's: These are quite odd. Spells.2da:
/*
    174        Summon_Creature_I    1
    175        Summon_Creature_II   2
    176        Summon_Creature_III  3
    177        Summon_Creature_IV   4
    178        Summon_Creature_IX   9
    179        Summon_Creature_V    5
    180        Summon_Creature_VI   6
    181        Summon_Creature_VII  7
    182        Summon_Creature_VIII 8
*/
    // We can loop through. 9 first, then 8-5, then undead ones, then 4-1
    if(!BuffCastSpell(SPELL_SUMMON_CREATURE_IX))// 9
    {
        // 8, 7, 6, 5.
        for(nCnt = SPELL_SUMMON_CREATURE_VIII;
           (nCnt >= SPELL_SUMMON_CREATURE_V && bBreak != TRUE);
            nCnt--)
        {
            if(BuffCastSpell(nCnt)) bBreak = TRUE;
        }
        // Then undead
        if(bBreak != TRUE)
        {
            if(!BuffCastSpell(SPELL_CREATE_GREATER_UNDEAD))
            {
                if(!BuffCastSpell(SPELL_CREATE_UNDEAD))
                {
                    if(!BuffCastSpell(SPELL_ANIMATE_DEAD))
                    {
                        // Lastly, the 4-1 ones.
                        for(nCnt = SPELL_SUMMON_CREATURE_IV;
                            nCnt >= SPELL_SUMMON_CREATURE_I;
                            nCnt--)
                        {
                            if(BuffCastSpell(nCnt)) break;
                        }
                    }
                }
            }
        }
    }
    // Finally, equip the best melee weapon to look more prepared.
    // Don't use a ranged, we can equip it manually if need be :=P
    // but sneak attackers would have a field day if we didn't have
    // a melee weapon out...
    ActionEquipMostDamagingMelee();
}

// Wrapper, to stop repeating the same lines! :-)
int BuffCastSpell(int nSpell)
{
    if(GetHasSpell(nSpell))
    {
        ActionCastSpellAtObject(nSpell, OBJECT_SELF, METAMAGIC_ANY, FALSE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
        return TRUE;
    }
    return FALSE;
}
