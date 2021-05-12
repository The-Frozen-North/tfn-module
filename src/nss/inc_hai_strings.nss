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
    string sName = GetName(OBJECT_SELF);
    // Probability of Battle Cry. MUST be a number from 1 to at least 8
    int iSpeakProb = Random(125)+1;
    if (FindSubString(sName,"Sharw") == 0)
    switch (iSpeakProb) {
       case 1: SpeakString("Take this, fool!"); break;
       case 2: SpeakString("Spare me your song and dance!"); break;
       case 3: SpeakString("To hell with you, hideous fiend!"); break;
       case 4: SpeakString("Come here. Come here I say!"); break;
       case 5: SpeakString("How dare you, impetuous beast?"); break;
       case 6: SpeakString("Pleased to meet you!"); break;
       case 7: SpeakString("Fantastic. Just fantastic!"); break;
       case 8: SpeakString("You CAN do better than this, can you not?"); break;

       default: break;
    }

    if (FindSubString(sName,"Tomi") == 0)
    switch (iSpeakProb) {
       case 1: SpeakString("Tomi's got a little present for you here!"); break;
       case 2: SpeakString("Poor sod, soon to bite the earth!"); break;
       case 3: SpeakString("Think twice before messing with Tomi!"); break;
       case 4: SpeakString("Tomi's fast; YOU are slow!"); break;
       case 5: SpeakString("Your momma raised ya to become THIS?"); break;
       case 6: SpeakString("Hey! Where's your manners!"); break;
       case 7: SpeakString("Tomi's got a BIG problem with you. Scram!"); break;
       case 8: SpeakString("You're an ugly little beastie, ain't ya?"); break;

       default: break;
    }

    if (FindSubString(sName,"Grim") == 0)
    switch (iSpeakProb) {
       case 1: SpeakString("Destruction for all!"); break;
       case 2: SpeakString("Embrace Death, and long for it!"); break;
       case 3: SpeakString("My Silent Lord comes to take you!"); break;
       case 4: SpeakString("Be still: your End approaches."); break;
       case 5: SpeakString("Prepare yourself! Your time is near!"); break;
       case 6: SpeakString("Eternal Silence engulfs you!"); break;
       case 7: SpeakString("I am at one with my End. And you?"); break;
       case 8: SpeakString("Suffering ends; but Death is eternal!"); break;
       default: break;
    }

    if (FindSubString(sName,"Dael") == 0)
    switch (iSpeakProb) {
       case 1: SpeakString("I'd spare you if you would only desist."); break;
       case 2: SpeakString("It needn't end like this. Leave us be!"); break;
       case 3: SpeakString("You attack us, only to die. Why?"); break;
       case 4: SpeakString("Must you all chase destruction? Very well!"); break;
       case 5: SpeakString("It does not please me to crush you like this."); break;
       case 6: SpeakString("Do not provoke me!"); break;
       case 7: SpeakString("I am at my wit's end with you all!"); break;
       case 8: SpeakString("Do you even know what you face?"); break;
       default: break;
    }

    if (FindSubString(sName,"Linu") == 0)
    switch (iSpeakProb) {
       case 1: SpeakString("Oooops! I nearly fell!"); break;
       case 2: SpeakString("What is your grievance? Begone!"); break;
       case 3: SpeakString("I won't allow you to harm anyone else!"); break;
       case 4: SpeakString("Retreat or feel Sehanine's wrath!"); break;
       case 5: SpeakString("By Sehanine Moonbow, you will not pass unchecked."); break;
       case 6: SpeakString("Smite you I will, though unwillingly."); break;
       case 7: SpeakString("Sehanine willing, you'll soon be undone!"); break;
       case 8: SpeakString("Have you no shame? Then suffer!"); break;
       default: break;
    }

    if (FindSubString(sName,"Boddy") == 0)
    switch (iSpeakProb) {
       case 1: SpeakString("You face a sorcerer of considerable power!"); break;
       case 2: SpeakString("I find your resistance illogical."); break;
       case 3: SpeakString("I bind the powers of the very Planes!"); break;
       case 4: SpeakString("Fighting for now, and research for later."); break;
       case 5: SpeakString("Sad to destroy a fine specimen such as yourself."); break;
       case 6: SpeakString("Your chances of success are quite low, you know?"); break;
       case 7: SpeakString("It's hard to argue with these fools."); break;
       case 8: SpeakString("Now you are making me lose my patience."); break;
       default: break;
    }
}


void MonsterBattleCry()
{


}


