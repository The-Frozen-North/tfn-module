/************************ [Debug] **********************************************
    Filename: J_Inc_Debug
************************* [Debug] **********************************************
    This contains DebugActionSpeak, the debug function.

    Makes it easier to uncomment debug lines.
************************* [History] ********************************************
    1.3 - Added
************************* [Workings] *******************************************
    DebugActionSpeak normally writes a timestamped log entry, and speak a silent
    string Server Admins can hear.

    To Do: Might make it more generic debug lines, where you can uncomment all
    "XX" lines HERE, not in the files, so it compiles without them, and only
    need an integer to speak one.

    1.3 added:
    - DebugActionSpeakByInt(int iInteger);
        - Removes many strings into this file
        - Can easily comment out all string so they are not added to compiled
          scripts if debugging unused (This saves space on compiled files :-D )
        - Always uncomment the right bits if not using any debugging.
************************* [Arguments] ******************************************
    Arguments: N/A
************************* [Debug] *********************************************/
#include "inc_debug"

// This will speak a cirtain integer number string (similar to a dialog reference).
// - I (Jass) have just moved all strings I used all the time into here, so
//   if the strings are uncommented, they will not be compiled
// - The numbers have no reference to much really.
// - Calls DebugActionSpeak!
// - See J_INC_DEBUG to uncomment/recomment in
void DebugActionSpeakByInt(int iInteger, object oInput = OBJECT_INVALID, int iInput = FALSE, string sInput = "");

// Speaks and stamps a debug string.
// - See J_INC_DEBUG to uncomment/recomment the debug strings.
// - Only used in special circumstances.
void DebugActionSpeak(string sString);

// This will speak a cirtain integer number string (similar to a dialog reference).
// - I (Jass) have just moved all strings I used all the time into here, so
//   if the strings are uncommented, they will not be compiled
// - The numbers have no reference to much really.
// - Calls DebugActionSpeak!
// - See J_INC_DEBUG to uncomment/recomment in
void DebugActionSpeakByInt(int iInteger, object oInput = OBJECT_INVALID, int iInput = FALSE, string sInput = "")
{
    // TO UNCOMMENT/COMMENT:
    // - Add/Remove in "//" before the next lines "/*"
    // - Recompile all files

    string sDebug;
    switch(iInteger)
    {
        // - Generic AI stuff
        case 1: sDebug =  "[DCR:Melee] Most Damaging Weapon. Target: " + GetName(oInput); break;
        case 2: sDebug =  "[DCR:Melee] Most Damaging as Not Effective"; break;
        case 3: sDebug =  "[DCR:Melee] Melee Code. No valid melee target/Dead. Exiting"; break;
        case 4: sDebug =  "[DCR:Melee] Melee attack. [Target] " + GetName(oInput) + " [Feat/Attack] " + IntToString(iInput); break;
        case 5: sDebug =  "[DCR:Caster] Defensive Casting Mode ON [Enemy] " + GetName(oInput); break;
        case 6: sDebug =  "[DCR:Caster] Moving away from AOO's. [Enemy] " + GetName(oInput); break;
        case 7: sDebug =  "[DCR:Casting] Talent(item) [TalentID] " + IntToString(iInput) + " [Target] " + GetName(oInput) + " [Location] " + sInput; break;
        case 8: sDebug =  "[DCR:Casting] Workaround for Spontaeous [SpellID] " + IntToString(iInput) + " [Target] " + GetName(oInput); break;
        case 9: sDebug =  "[DCR:Casting] NormalSpell [ID] " + IntToString(iInput) + " [Target] " + GetName(oInput) + " [Location] " + sInput; break;
        case 10: sDebug = "[DCR:Casting] TalentSpell. [ID] " + IntToString(iInput) + " [Target] " + GetName(oInput) + " [Location] " + sInput; break;
        case 11: sDebug = "[DCR:Casting] SubSpecialSpell. [ID] " + IntToString(iInput) + " [Target] " + GetName(oInput) + " [Location] " + sInput; break;
        case 12: sDebug = "[DCR:Casting] NormalRandomSpell. [ID] " + IntToString(iInput) + " [Target] " + GetName(oInput) + " [Location] " + sInput; break;
        case 13: sDebug = "[DCR:Casting] Backup spell caught: " + IntToString(iInput); break;
        case 14: sDebug = "[DCR:Feat] [ID] " + IntToString(iInput) + " [Enemy] " + GetName(oInput); break;
        case 15: sDebug = "[DCR:Casting] Grenade [ID] " + IntToString(iInput) + " [Target] " + GetName(oInput) + " [Location] " + sInput; break;
        case 16: sDebug = "[AOE Call] Moving out of/Dispeling an AOE. [Tag] " + GetTag(oInput); break;
        case 17: sDebug = "[DCR:Special] Darkness + Caster. No seen enemy. Dispel/Move."; break;
        case 18: sDebug = "[DRC:Talent] Using Talent (Healing). [TalentID] " + IntToString(iInput) + " [Target] " + GetName(oInput); break;
        case 19: sDebug = "[DCR:Healing] (Should) Healing [Target]" + GetName(oInput) + " [CurrentHP|Max|ID|Rank|Power] " + IntToString(iInput); break;
        case 20: sDebug = "[DCR Healing] Boss Action, create Critical Wounds potion"; break;
        case 21: sDebug = "[DCR:Casting] Healing self with healing kit, [Kit] " + GetName(oInput); break;
        case 22: sDebug = "[DCR:Feat] Summoning my familiar"; break;
        case 23: sDebug = "[DCR:Feat] Summoning my animal companion"; break;
        case 24: sDebug = "[DCR:Fleeing] Stupid/Panic/Flee moving from enemies/position - We are a commoner/no morale/failed < 3 int"; break;
        case 25: sDebug = "[DCR:Fleeing] Fleeing to allies. [ID Array] " + sInput + " [Ally] " + GetName(oInput); break;
        case 26: sDebug = "[DCR:GFTK] Attacking a PC who is dying/asleep! [Enemy]" + GetName(oInput); break;
        case 27: sDebug = "[DCR:Moving] Archer Retreating back from the enemy [Enemy]" + GetName(oInput); break;
        case 28: sDebug = "[DCR:Turning] Using Turn Undead"; break;
        case 29: sDebug = "[DCR:Bard Song] Using"; break;
        case 30: sDebug = "[DCR:Bard Curse Song] Using"; break;
        case 31: sDebug = "[DCR:All Spells] Error! No casting (No spells, items, target Etc)."; break;
        case 32: sDebug = "[DCR:All Spells] [Modifier|BaseDC|SRA] " + IntToString(iInput); break;
        case 33: sDebug = "[DCR:Casting] Cheat Spell. End of Spells. [Spell] " + IntToString(iInput) + "[Target]" + GetName(oInput); break;
        case 34: sDebug = "[DCR:All Spells] Ranged Spells. Should use closer spells/move nearer"; break;
        case 35: sDebug = "[DCR:Dragon] Breath weapon & attacking [Breath ID] " + IntToString(iInput) + " [Target] " + GetName(oInput); break;
        case 36: sDebug = "[DCR:Dragon] Wing Buffet [Target] " + GetName(oInput); break;
        case 37: sDebug = "[DCR:Beholder] Teleport"; break;
        case 38: sDebug = "[DCR:Beholder] Rays"; break;
        case 39: sDebug = "[DCR:Targeting] No valid enemies in sight, moving to allies target's. [Target] " + GetName(oInput); break;
        case 40: sDebug = "[DCR:Targeting] Override Target Seen. [Name]" + GetName(oInput); break;
        case 41: sDebug = "[DCR:Targeting] No seen in LOS, Attempting to MOVE to something [Target]" + GetName(oInput); break;
        case 42: sDebug = "[DCR:Skill] Using agressive skill (+Attack). [Skill] " + IntToString(iInput) + " [Enemy]" + GetName(oInput); break;
        case 43: sDebug = "[DCR:Pre-Melee Spells] All Potions Using. [Spell ID] " + IntToString(iInput); break;
        case 44: sDebug = "[DCR:Pre-Melee Spells] True Strike Emptive attack [Target] " + GetName(oInput); break;
        case 45: sDebug = "[DCR:CounterSpell] Counterspelling. [Target] " + GetName(oInput); break;
        case 46: sDebug = "[DRC] START [Intruder]" + GetName(oInput); break;
        case 47: sDebug = "[DCR] [PREMITURE EXIT] Cannot Do Anything."; break;
        case 48: sDebug = "[DCR] [PREMITURE EXIT] Dazed move away."; break;
        case 49: sDebug = "[DCR] [PREMITURE EXIT] Fleeing or otherwise"; break;
        case 50: sDebug = "[DRC] END - DELETE PAST TARGETS"; break;
        // Perception
        case 51: sDebug = "[Perception] Our Enemy Target changed areas. Stopping, moving too...and attack... [Percieved] " + GetName(oInput); break;
        case 52: sDebug = "[Perception] Enemy Vanished (Same area) Retargeting/Searching [Percieved] " + GetName(oInput); break;
        case 53: sDebug = "[Perception] Enemy seen, and was old enemy/cannot see current. Re-evaluating (no spell) [Percieved] " + GetName(oInput); break;
        case 54: sDebug = "[Perception] Enemy Seen. Not in combat, attacking. [Percieved] " + GetName(oInput); break;
        case 55: sDebug = "[Perception] Percieved Dead Friend! Moving and Searching [Percieved] " + GetName(oInput); break;
        case 56: sDebug = "[Perception] Percieved Alive Fighting Friend! Moving to and attacking. [Percieved] " + GetName(oInput); break;
        // Conversation
        case 57: sDebug = "[Shout] Friend (may be PC) in combat. Attacking! [Friend] " + GetName(oInput); break;
        case 58: sDebug = "[Shout] Responding to shout [Enemy] " + GetName(oInput) + " Who has spoken!"; break;
        // Phisical Attacked
        case 59: sDebug = "[Phisically Attacked] Attacking back. [Attacker(enemy)] " + GetName(oInput); break;
        case 60: sDebug = "[Phisically Attacked] Not same area. [Attacker(enemy)] " + GetName(oInput); break;
        // Damaged
        case 61: sDebug = "[Damaged] Morale Penalty for 600 seconds [Penalty]" + IntToString(iInput); break;
        case 62: sDebug = "[Damaged] Not in combat: DCR [Damager]" + GetName(oInput); break;
        case 63: sDebug = "[Damaged] Not in combat: DCR. Ally hit us. [Damager(Ally?)]" + GetName(oInput); break;
        // Death
        case 64: sDebug = "[Death] Checking corpse status in " + IntToString(iInput) + " [Killer] " + GetName(oInput) + " [Times Died Now] " + sInput; break;
        // Disturbed
        case 65: sDebug = "[Disturbed] (pickpocket) Attacking Enemy [Disturber] " + GetName(oInput) + " [Type] " + IntToString(iInput); break;
        // Rest
        case 66: sDebug = "[Rested] Resting. [Type(should be invalid)] " + IntToString(iInput); break;
        // Spell Cast at
        case 67: sDebug = "[Spell] Caster isn't a creature! May look for target [Caster] " + GetName(oInput); break;
        case 68: sDebug = "[Spell:Enemy/Hostile] Not in combat. Attacking: [Caster] " + GetName(oInput); break;
        case 69: sDebug = "[Spell] (ally). Not in combat. May Attack/Move [Caster] " + GetName(oInput); break;
        // Spell Other AI
        // - Shouts
        case 70: sDebug = "[Shout] Reacting To Shout. [ShoutNo.] " + IntToString(iInput) + " [Shouter] " + GetName(oInput); break;
        // Constants
        // - Search
        case 71: sDebug = "[Search] Resting"; break;
        case 72: sDebug = "[Search] Searching, No one to attack. [Time] " + sInput; break;
        // - DCR
        case 73: sDebug = "[Call for DCR] Default AI [Pre-Set Target]" + GetName(oInput); break;
        case 74: sDebug = "[Call for DCR] Custom AI [" + sInput + "] [Pre-Set Target]" + GetName(oInput); break;
        // Destroy self
        case 75: sDebug = "[Dead] Setting to selectable/destroyable (so we go) for Bioware corpses."; break;
        case 76: sDebug = "[Dead] Destroying self finally."; break;
        // Waypoints
        case 77: sDebug = "[Waypoints] Returning to spawn location. [Area] " + GetName(oInput); break;

        default: return; break;
    }
    if(sDebug != "")
    {
        DebugActionSpeak(sDebug);
    }
}

void DebugActionSpeak(string sString)
{
// You MUST uncomment this line, IF you use either of the below things
    string sNew = "[Debug]" + GetName(OBJECT_SELF) + "[ObjectID]" + ObjectToString(OBJECT_SELF) + " [Debug] " + sString;

// Note, uncomment this, so that DM's can hear the debug speaks, normally it is
// only server admins who can hear the debug. If you are not testing, it might
// be best to keep this uncommented.
// Futher: - Must have debug mode set to 1
//         - Only the server admin can seem to see this.
    //SpeakString(sNew, TALKVOLUME_SILENT_TALK);

// Note, uncomment this line to send a message to the first PC in the module.
// - Useful for singleplayer testing
    if (GetIsObjectValid(GetMaster()))
    {
        SendDebugMessage(sNew);
    }

// This writes the entry to the log, very important, if debugging
// Futher: - If left up for a long time, logs can get very big with the AI
//         - Use to find problems in the AI and report to me :-D (Jasperre)
    //WriteTimestampedLogEntry(sNew);
}
