/*

    Henchman Inventory And Battle AI

    This file is used for strings for the henchman ai.

    This file contains all strings shown to the PC. (Useful for
    multilanguage support and customization.)

*/


// void main() {    }

// weapons equipping
const string sHenchCantUseShield = "I don't know how to use this shield!";
const string sHenchCantUseRanged = "I can't use ranged weapons.";
const string sHenchSwitchToMissle = "I'm switching back to my missile weapon!";
const string sHenchSwitchToRanged = "I'm switching to my melee weapon for now!";
// generic
const string sHenchSomethingFishy = "There's something fishy near that door...";
// hen shout
const string sHenchPeacefulModeCancel = "***Peaceful Follow Mode Canceled***";
const string sHenchHenchmanFollow = "I will follow but not attack our enemies until you tell me otherwise.";
const string sHenchFamiliarFollow = "I will be happy to follow you, avoiding combat until you tell me otherwise!";
const string sHenchAnCompFollow = " understands that it should follow, waiting for your command to attack.>";
const string sHenchOtherFollow1 = "<The ";
const string sHenchOtherFollow2 = " will now follow you, and be peaceful until told otherwise.>";
// hen util
const string sHenchUnableToEquip1 = "I was physically unable to equip the ";
const string sHenchUnableToEquip2 = "! I'll keep it in my backpack.";
const string sHenchUnableToEquip3 = "I decided not to equip the ";
const string sHenchUnableToEquip4 = ". It's in my backpack.";
const string sHenchAbleToEquip = "I managed to equip the ";
const string sHenchSelectItem1 = "I really like the ";
const string sHenchSelectItem2 = "I like my ";
const string sHenchSelectItem3 = " better than the ";
const string sHenchDecisions = "Hmmm, decisions, decisions...";
const string sHenchEquipArmor = "piece of armor";
const string sHenchEquipShield = "Thanks for the shield... I'll try to use it well.";
const string sHenchEquipCloak = "cloak";
const string sHenchEquipBoots = "pair of boots";
const string sHenchEquipHandwear = "handwear";
const string sHenchEquipHelmet = "helmet";
const string sHenchEquipBelt = "belt";
const string sHenchEquipRing = "ring";
const string sHenchEquipAmulet = "amulet";
const string sHenchEquipWeapon = "Thanks for the weaponry. We'll have to wait until combat to see how well I can use it!";
const string sHenchEquipWait = "Please wait a little while I try to sort out my equipment.";
const string sHenchEquipDecency = "Will you give me some clothes to wear for goodness' sake?";
// hench heartbeat
const string sHenchWaitTrapsCleared = "I'm not doing anything until these traps are cleared";
const string sHenchSomethingImportant = "There is something important here you should look at";
const string sHenchFoundSomething = "Look what I found";
const string sHenchGiveThings = "Here are some things for you";
const string sHenchGiveGold = "Here's some gold for you";
// main ai
const string sHenchCantHealMaster = "Sorry, I can't heal you!";
const string sHenchAskHealMaster = "Should I heal you?";
const string sHenchHenchmanAskAttack = "Should I attack?";
const string sHenchFamiliarAskAttack = "Be careful! Let me know if I should attack!";
const string sHenchAnCompAskAttack = " is waiting for you to give the command to attack.>";
const string sHenchOtherAskAttack = " patiently awaits your command to attack.>";
const string sHenchWeakAttacker = "Don't make me laugh!";
const string sHenchModAttacker = "We'll best them yet!";
const string sHenchStrongAttacker = "Watch out for this one!";
const string sHenchOverpoweringAttacker = "Gods help us!";
const string sHenchFamiliarFlee1 = "Time for me to get out of here!";
const string sHenchFamiliarFlee2 = "Eeeeek!";
const string sHenchFamiliarFlee3 = "Make way, make way!";
const string sHenchFamiliarFlee4 = "I'll be back!";
const string sHenchAniCompFlee = "<Danger>";
const string sHenchHealMe = "Help! I can't heal myself!";
// hen identify
const string sHenchIdentObject = "Object #";
const string sHenchIdentSuccess = ": This looks like a ";
const string sHenchIdentFail = ": I'm not sure what this thing is.";
const string sHenchIdentNoItems = "Are you playing games with me?";
// hen show items
const string sHenchShowEquipKnown = ": equipped. Qty: ";
const string sHenchShowEquipUnknown = "Unidentified object: equipped. Qty: ";
const string sHenchShowInventoryKnown = ": in backpack. Qty: ";
const string sHenchShowInventoryUnknown = "Unidentified object: in backpack. Qty: ";
const string sHenchShowNoItems = "I don't have anything!";
// hench heartbeat
const string sHenchGetOutofWay = "Please get out of my way.";
// hench block
const string sHenchMonsterOnOtherSide = "Something is on the other side of this door.";
// hench heal
const string sHenchCantSeeTarget = "I can't see ";


void HenchBattleCry()
{
    if (GetIsDead(OBJECT_SELF)) return;

    string sBattlecryScript = GetLocalString(OBJECT_SELF, "battlecry_script");
    if (sBattlecryScript != "")
    {
        ExecuteScript(sBattlecryScript, OBJECT_SELF);
    }
    else
    {
        int nRand = 40;
        if (GetLocalInt(OBJECT_SELF, "boss") == 1) nRand = nRand/2;

        switch (Random(nRand))
        {
            case 0: PlayVoiceChat(VOICE_CHAT_BATTLECRY1, OBJECT_SELF); break;
            case 1: PlayVoiceChat(VOICE_CHAT_BATTLECRY2, OBJECT_SELF); break;
            case 2: PlayVoiceChat(VOICE_CHAT_BATTLECRY3, OBJECT_SELF); break;
            case 3: PlayVoiceChat(VOICE_CHAT_ATTACK, OBJECT_SELF); break;
            case 4: PlayVoiceChat(VOICE_CHAT_TAUNT, OBJECT_SELF); break;
            case 5: PlayVoiceChat(VOICE_CHAT_LAUGH, OBJECT_SELF); break;
        }
    }
}


void MonsterBattleCry()
{


}


