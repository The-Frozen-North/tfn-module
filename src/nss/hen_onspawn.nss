/*/////////////////////// [On Spawn] ///////////////////////////////////////////
    Filename: J_AI_OnSpawn or nw_c2_default9
///////////////////////// [On Spawn] ///////////////////////////////////////////
    This file contains options that will determine some AI behaviour, and a lot
    of toggles for turning things on/off. A big read, but might be worthwhile.

    The documentation is actually fully in the readme files, under the name
    "On Spawn.html", under "AI File Explanations".

    The order of the options:

    - Important Spawn Settings                   N/A
    - Targeting & Fleeing                       (AI_TARGETING_FLEE_MASTER)
    - Fighting & Spells                         (AI_COMBAT_MASTER)
    - Other Combat - Healing, Skills & Bosses   (AI_OTHER_COMBAT_MASTER)
    - Other - Death corpses, minor things       (AI_OTHER_MASTER)
    - User Defined                              (AI_UDE_MASTER)
    - Shouts                                     N/A
    - Default Bioware settings (WP's, Anims)    (NW_GENERIC_MASTER)

    The OnSpawn file is a settings file. These things are set onto a creature, to
    define cirtain actions. If more than one creature has this script, they all
    use the settings, unless If/Else statements are used somehow. There is also
    the process of setting any spells/feats availible, and hiding and walk waypoints
    are started.

    Other stuff:
    - Targeting is imporant :-D
    - If you delete this script, there is a template for the On Spawn file
      in the zip it came in, for use in the "scripttemplate" directory.
///////////////////////// [History] ////////////////////////////////////////////
    Note: I have removed:
    - Default "Teleporting" and exit/return (this seemed bugged anyway, or useless)
    - Spawn in animation. This can be, of course, re-added.
    - Day/night posting. This is uneeded, with a changed walk waypoints that does it automatically.

    1.0-1.2 - Used short amount of spawn options.
    1.3 - All constants names are changed, I am afraid.
        - Added Set/Delete/GetAIInteger/Constant/Object. This makes sure that the AI
          doesn't ever interfere with other things - it pre-fixes all stored things
          with AI_INTEGER_ (and so on)
    1.4 - TO DO: Clear up some old non-working ones
        - Added in User Defined part of the script, an auto-turn-off-spells for
          Ranger and Paladin classes. Need to test - perhaps 1.64 fixed it?


        Spawn options changed:
        - Removed AI level settings (can still be done manually)
        - Added optional (and off by default) fear-visual for fleeing


///////////////////////// [Workings] ///////////////////////////////////////////
    Note: You can do without all the comments (it may be that you don't want
    the extra KB it adds or something, although it does not at all slow down a module)
    so as long as you have these at the end:

    AI_SetUpEndOfSpawn();
    DelayCommand(2.0, SpawnWalkWayPoints());

    Oh, and the include file (Below, "j_inc_spawnin") must be at the top like
    here. Also recommended is the AI_INTELLIGENCE and AI_MORALE being set (if
    not using custom AI).
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: GetIsEncounterCreature
///////////////////////// [On Spawn] /////////////////////////////////////////*/

// Treasure Includes - See end of spawn for uncomment options.

//#include "nw_o2_coninclude"
// Uncomment this if you want default NwN Treasure - Uses line "GenerateNPCTreasure()" at the end of spawn.
// - This generates random things from the default pallet based on the creatures level + race

//#include "x0_i0_treasure"
// Uncomment this if you want the SoU Treasure - Uses line "CTG_GenerateNPCTreasure()" at the end of spawn.
// - This will spawn treasure based on chests placed in the module. See "x0_i0_treasure" for more information.

// This is required for all spawn in options!
#include "inc_hai_spawn"
#include "inc_loot"
#include "nwnx_creature"

void main()
{
    ExecuteScript("hen_onspawne");

/************************ [User] ***********************************************
    This is the ONLY place you should add user things, on spawn, such as
    visual effects or anything, as it is after SetUpEndOfSpawn. By default, this
    does have encounter animations on. This is here, so is easily changed :-D

    Be careful otherwise.

    Notes:
    - SetListening is already set to TRUE, unless AI_FLAG_OTHER_LAG_NO_LISTENING is on.
    - SetListenPattern's are set from 0 to 7.
    - You can use the wrappers AI_SpawnInInstantVisual and AI_SpawnInPermamentVisual
      for visual effects (Instant/Permament as appropriate).
************************* [User] **********************************************/
    // Example (and default) of user addition:
    // - If we are from an encounter, set mobile (move around) animations.
    int iAreaCR = GetLocalInt(GetArea(OBJECT_SELF), "cr");

    switch (GetRacialType(OBJECT_SELF))
    {
        case RACIAL_TYPE_DWARF:
        case RACIAL_TYPE_ELF:
        case RACIAL_TYPE_GNOME:
        case RACIAL_TYPE_HALFLING:
        case RACIAL_TYPE_HALFORC:
        case RACIAL_TYPE_HUMAN:
        case RACIAL_TYPE_HALFELF:
            if (GetLocalInt(OBJECT_SELF, "no_potion") != 1 && d4() == 1)
            {
                object oPotion = CreateItemOnObject("cure_potion1", OBJECT_SELF);
                SetDroppableFlag(oPotion, FALSE);
                SetPickpocketableFlag(oPotion, TRUE);
            }

            if (d10() == 1)
            {
                object oItem = GenerateTierItem(GetHitDice(OBJECT_SELF), iAreaCR, OBJECT_SELF, "Misc");
                SetDroppableFlag(oItem, FALSE);
                SetPickpocketableFlag(oItem, TRUE);
            }

            object oGold = CreateItemOnObject("nw_it_gold001", OBJECT_SELF, d2(GetHitDice(OBJECT_SELF)));
            SetDroppableFlag(oGold, FALSE);
            SetPickpocketableFlag(oGold, TRUE);
        break;
    }

       NWNX_Creature_SetCorpseDecayTime(OBJECT_SELF, 1200000);
       NWNX_Creature_SetDisarmable(OBJECT_SELF, TRUE);



    //int nRace = GetRacialType(oCreature);

    string sScript = GetLocalString(OBJECT_SELF, "spawn_script");
    if (sScript != "") ExecuteScript(sScript);

    // If we are a ranger or paladin class, do not cast spells. This can be
    // manually removed if wished. To get the spells they have working correctly,
    // remove this, and use Monster Abilties instead of thier normal class spells.
//    if(GetLevelByClass(CLASS_TYPE_RANGER) >= 1 || GetLevelByClass(CLASS_TYPE_PALADIN) >= 1)
//    {
//        SetSpawnInCondition(AI_FLAG_OTHER_LAG_NO_SPELLS, AI_OTHER_MASTER);
//    }
}

