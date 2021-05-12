/*

    Henchman Inventory And Battle AI

    This file is used for options for the henchman ai.

    The exe and hak versions are different than the erf version.

    The exe and hak version still use the small scripts to control options.

    The erf version can just be built directly using this file without using
    the small control files, it can be changed to anything including
    module properties, spawn script, etc.

*/


// void main() {    }


// how frequently shouts are done by monsters to call in allies to help
// DM clients can get flooded with these messages in which case the
// number can be increased to reduce the frequency.
const int HENCH_MONSTER_SHOUT_FREQUENCY = 5;

// This flag turns off when set to true monsters hearing other monsters and
// attacking them
const int HENCH_MONSTER_DONT_CHECK_HEARD_MONSTER = FALSE;


// general options
const int HENCH_GENAI_SOUINSTALLED  = 0x0001;     // expansion pack installed (includes HotU)
const int HENCH_GENAI_ENABLEHEARING = 0x0002;     // (obsolete) creatures use hearing
const int HENCH_GENAI_ENABLERAISE   = 0x0004;     // will use raise dead and resurrection


int GetGeneralOptions(int nSel)
{
    return HENCH_GENAI_SOUINSTALLED | HENCH_GENAI_ENABLERAISE;
}


// monster options
const int HENCH_MONAI_STEALTH = 0x0001;      // monsters use stealth
const int HENCH_MONAI_WANDER  = 0x0002;      // monsters can wander
const int HENCH_MONAI_UNLOCK  = 0x0004;      // monsters can unlock or bash locked doors
const int HENCH_MONAI_OPEN    = 0x0008;      // monsters can open doors
const int HENCH_MONAI_DISTRIB = 0x0010;      // monsters distribute themselves when attacking
const int HENCH_MONAI_HASTE   = 0x0020;      // monsters haste themselves after being damaged
const int HENCH_MONAI_HEALPT  = 0x0040;      // monsters generate heal potions
const int HENCH_MONAI_COMP    = 0x0080;      // monsters summon familiars and animal companions


int GetMonsterOptions(int nSel)
{
    int nReturn = HENCH_MONAI_STEALTH | HENCH_MONAI_COMP;

    if (nSel & HENCH_MONAI_WANDER)
    {
        if (d10() > 2)
        {
            nReturn = nReturn | HENCH_MONAI_WANDER;
        }
    }
    if (nSel & HENCH_MONAI_DISTRIB)
    {
            // monsters distribute themselves when attacking
        if (GetGameDifficulty() >= GAME_DIFFICULTY_CORE_RULES)
        {
            nReturn = nReturn | HENCH_MONAI_DISTRIB;
        }
    }
/*    if (nSel & HENCH_MONAI_HASTE)
    {
            // monsters haste themselves after being damaged
        if (GetGameDifficulty() == GAME_DIFFICULTY_DIFFICULT)
        {
            nReturn = nReturn | HENCH_MONAI_HASTE;
        }
    }*/
/*    if (nSel & HENCH_MONAI_HEALPT)
    {
         int iChance = d10();
        int iDifficulty = GetGameDifficulty();

        // Self healing below 50% if enemy is far, otherwise between 20% and 50% only
       if ((iDifficulty == GAME_DIFFICULTY_DIFFICULT && iChance > 2)  ||
             (iDifficulty == GAME_DIFFICULTY_CORE_RULES && iChance > 8))
        {
            nReturn = nReturn |  HENCH_MONAI_HEALPT;
        }
    } */
    return nReturn;
}


// henchman options
const int HENCH_HENAI_NOATTACK  = 0x0001;      // associates dont attack master on damage
const int HENCH_HENAI_INVENTORY = 0x0002;      // PC can use inventory on associates

const float fHenchHearingDistance = 5.0;
const float fHenchMasterHearingDistance = 100.0;


int GetHenchmanOptions(int nSel)
{
    return HENCH_HENAI_NOATTACK | HENCH_HENAI_INVENTORY;
}


// provides override for creature using items (i.e. Valen in HotU)
int GetCreatureUseItemsOverride(object oCreature)
{
//    if (GetTag(oCreature) == "x2_hen_valen")
//    {
//        return TRUE;
//    }
    return FALSE;
}


// prevent heartbeat detection of enemies
int GetUseHeartbeatDetect()
{
   return FALSE;
}





