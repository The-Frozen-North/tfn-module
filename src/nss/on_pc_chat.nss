#include "x3_inc_string"
#include "inc_debug"
#include "inc_general"

int CheckDeadSpeak(object oPC)
{
    int bDead = GetIsDead(oPC);
    if (bDead)
    {
        SetPCChatMessage("");
        SendColorMessageToPC(oPC, "The dead cannot speak", MESSAGE_COLOR_DANGER);
    }
    return bDead;
}

void DebugBusyNPC(int nTries=0)
{
    WriteTimestampedLogEntry("Reacting to TALKTOME: " + GetName(OBJECT_SELF));
    WriteTimestampedLogEntry("    action = " + IntToString(GetCurrentAction(OBJECT_SELF)));
    WriteTimestampedLogEntry("    in conversation = " + IntToString(IsInConversation(OBJECT_SELF)));

    if (IsInConversation(OBJECT_SELF))
    {
        object oSpeaker = GetPCSpeaker();
        WriteTimestampedLogEntry("    in conversation with = " + GetName(oSpeaker) + " or " + ObjectToString(oSpeaker));
        if (!GetIsObjectValid(oSpeaker) || GetArea(oSpeaker) != GetArea(OBJECT_SELF))
        {
            if (nTries == 0)
            {
                ClearAllActions();
                SpeakString("Huh? I thought I was talking to someone else.");
                WriteTimestampedLogEntry("    -> clear all actions");
                DelayCommand(1.0, DebugBusyNPC(nTries+1));
                return;
            }
            else if (nTries == 1)
            {
                ClearAllActions();
                SpeakString("What if I take a tiny, metaphorical walk to clear my head?");
                WriteTimestampedLogEntry("    -> move to own location");
                ActionMoveToLocation(GetLocation(OBJECT_SELF));
                DelayCommand(1.0, DebugBusyNPC(nTries+1));
                return;
            }
            else if (nTries == 2)
            {
                ClearAllActions();
                SpeakString("Maybe I should stop being shy and try starting up conversation myself?");
                location lLoc = GetLocation(OBJECT_SELF);
                object oTest = GetFirstObjectInShape(SHAPE_SPHERE, 10.0, lLoc, TRUE);
                while (GetIsObjectValid(oTest))
                {
                    if (!GetIsDead(oTest) && GetIsPC(oTest))
                    {
                        ActionStartConversation(oTest);
                        WriteTimestampedLogEntry("    -> try talking to " + GetName(oTest));
                        DelayCommand(1.0, DebugBusyNPC(nTries+1));
                        return;
                    }
                    oTest = GetNextObjectInShape(SHAPE_SPHERE, 10.0, lLoc, TRUE);
                }
                WriteTimestampedLogEntry("    (couldn't find PC to talk to)");
                return;
            }
        }
    }

    if (nTries > 0)
    {
        SpeakString("Sorry about that. I'm ready to speak to you now.");
    }
}

void main()
{
  object oPC = GetPCChatSpeaker();

  if(!GetIsPC(oPC))
  {
       return;
  }

  string sVolume;
  switch (GetPCChatVolume())
  {
     case TALKVOLUME_TALK:
        if (CheckDeadSpeak(oPC)) return;
        sVolume = "TALK";
        break;
     case TALKVOLUME_WHISPER:
        if (CheckDeadSpeak(oPC)) return;
        sVolume = "WHISPER";
        break;
     case TALKVOLUME_SHOUT: sVolume = "SHOUT"; break;
     case TALKVOLUME_SILENT_SHOUT: sVolume = "SILENT_SHOUT"; break;
     case TALKVOLUME_PARTY:
        sVolume = "PARTY";
     break;
  }

  string sMessage = GetPCChatMessage();

  WriteTimestampedLogEntry(PlayerDetailedName(oPC)+" ["+sVolume+"]: "+sMessage);

  if (GetIsDead(oPC)) return;

  string sLCMessage = GetStringLowerCase(sMessage);
  int nMessageLength = GetStringLength(sLCMessage);

  if(nMessageLength == 0) return;

  if (GetStringLeft(sLCMessage, 5) == "/roll")
  {
        string sType;
        int nModifier = 0;

// abilities
        if (sLCMessage == "/roll str" || sLCMessage == "/roll strength") {sType = "Strength"; nModifier = GetAbilityModifier(ABILITY_STRENGTH, oPC);}
        else if (sLCMessage == "/roll dex" || sLCMessage == "/roll dexterity") {sType = "Dexterity"; nModifier = GetAbilityModifier(ABILITY_DEXTERITY, oPC);}
        else if (sLCMessage == "/roll con" || sLCMessage == "/roll constitution") {sType = "Constitution"; nModifier = GetAbilityModifier(ABILITY_CONSTITUTION, oPC);}
        else if (sLCMessage == "/roll wis" || sLCMessage == "/roll wisdom") {sType = "Wisdom"; nModifier = GetAbilityModifier(ABILITY_WISDOM, oPC);}
        else if (sLCMessage == "/roll cha" || sLCMessage == "/roll charisma") {sType = "Charisma"; nModifier = GetAbilityModifier(ABILITY_CHARISMA, oPC);}
// saves
        else if (sLCMessage == "/roll fortitude") {sType = "a Fortitude save"; nModifier = GetFortitudeSavingThrow(oPC);}
        else if (sLCMessage == "/roll reflex") {sType = "a Reflex save"; nModifier = GetReflexSavingThrow(oPC);}
        else if (sLCMessage == "/roll will") {sType = "a Will save"; nModifier = GetWillSavingThrow(oPC);}
// skills
        else if (sLCMessage == "/roll animal empathy") {sType = "Animal Empathy"; nModifier = GetSkillRank(SKILL_ANIMAL_EMPATHY, oPC);}
        else if (sLCMessage == "/roll appraise") {sType = "Appraise"; nModifier = GetSkillRank(SKILL_APPRAISE, oPC);}
        else if (sLCMessage == "/roll concentration") {sType = "Concentration"; nModifier = GetSkillRank(SKILL_CONCENTRATION, oPC);}
        else if (sLCMessage == "/roll craft armor") {sType = "Craft Armor"; nModifier = GetSkillRank(SKILL_CRAFT_ARMOR, oPC);}
        else if (sLCMessage == "/roll craft weapon") {sType = "Craft Weapon"; nModifier = GetSkillRank(SKILL_CRAFT_WEAPON, oPC);}
        else if (sLCMessage == "/roll craft trap") {sType = "Craft Trap"; nModifier = GetSkillRank(SKILL_CRAFT_TRAP, oPC);}
        else if (sLCMessage == "/roll disable trap") {sType = "Disable Trap"; nModifier = GetSkillRank(SKILL_DISABLE_TRAP, oPC);}
        else if (sLCMessage == "/roll discipline") {sType = "Discipline"; nModifier = GetSkillRank(SKILL_DISCIPLINE, oPC);}
        else if (sLCMessage == "/roll heal") {sType = "Heal"; nModifier = GetSkillRank(SKILL_HEAL, oPC);}
        else if (sLCMessage == "/roll hide") {sType = "Hide"; nModifier = GetSkillRank(SKILL_HIDE, oPC);}
        else if (sLCMessage == "/roll intimidate") {sType = "Intimidate"; nModifier = GetSkillRank(SKILL_INTIMIDATE, oPC);}
        else if (sLCMessage == "/roll listen") {sType = "Listen"; nModifier = GetSkillRank(SKILL_LISTEN, oPC);}
        else if (sLCMessage == "/roll lore") {sType = "Lore"; nModifier = GetSkillRank(SKILL_LORE, oPC);}
        else if (sLCMessage == "/roll move silently") {sType = "Move Silently"; nModifier = GetSkillRank(SKILL_MOVE_SILENTLY, oPC);}
        else if (sLCMessage == "/roll open lock") {sType = "Open Lock"; nModifier = GetSkillRank(SKILL_OPEN_LOCK, oPC);}
        else if (sLCMessage == "/roll parry") {sType = "Parry"; nModifier = GetSkillRank(SKILL_PARRY, oPC);}
        else if (sLCMessage == "/roll perform") {sType = "Perform"; nModifier = GetSkillRank(SKILL_PERFORM, oPC);}
        else if (sLCMessage == "/roll persuade") {sType = "Persuade"; nModifier = GetSkillRank(SKILL_PERSUADE, oPC);}
        else if (sLCMessage == "/roll pick pocket") {sType = "Pick Pocket"; nModifier = GetSkillRank(SKILL_PICK_POCKET, oPC);}
        else if (sLCMessage == "/roll ride") {sType = "Ride"; nModifier = GetSkillRank(SKILL_RIDE, oPC);}
        else if (sLCMessage == "/roll search") {sType = "Search"; nModifier = GetSkillRank(SKILL_SEARCH, oPC);}
        else if (sLCMessage == "/roll spot") {sType = "Spot"; nModifier = GetSkillRank(SKILL_SPOT, oPC);}
        else if (sLCMessage == "/roll taunt") {sType = "Taunt"; nModifier = GetSkillRank(SKILL_TAUNT, oPC);}
        else if (sLCMessage == "/roll tumble") {sType = "Tumble"; nModifier = GetSkillRank(SKILL_TUMBLE, oPC);}
        else if (sLCMessage == "/roll use magic device" || sLCMessage == "/roll umd") {sType = "Use Magic Device"; nModifier = GetSkillRank(SKILL_USE_MAGIC_DEVICE, oPC);}

        int nRoll = d20();
        sMessage = GetName(oPC) + " rolls " + (sType != "" ? "for " + sType : "") + ": " +
            IntToString(nRoll) + (nModifier >= 0 ? " + " : " - ") + IntToString(abs(nModifier)) + " = " + IntToString(nRoll + nModifier);

        SetPCChatMessage("");
        FloatingTextStringOnCreature(sMessage, oPC);
  }

  StringReplace(sLCMessage, ".", "");

  if (sLCMessage == "lol" || sLCMessage == "rofl" || sLCMessage == "lmao"|| sLCMessage == "roflmao" || sLCMessage == "haha"|| sLCMessage == "hehe"|| sLCMessage == "hah"|| sLCMessage == "heh"|| sLCMessage == "ha"|| sLCMessage == "lawl")
  {
    PlayVoiceChat(VOICE_CHAT_LAUGH, oPC);
    AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_TALK_LAUGHING));
  }

  // Temporary. Investigating the stuck NPC issue
  if (GetStringLeft(sMessage, 10) == "TALK TO ME")
  {
      WriteTimestampedLogEntry(GetName(oPC) + " screamed TALK TO ME.");
      location lLoc = GetLocation(oPC);
      object oTest = GetFirstObjectInShape(SHAPE_SPHERE, 10.0, lLoc, TRUE);
      int nCount = 0;
      while (GetIsObjectValid(oTest))
      {
          if (!GetIsDead(oTest) && !GetIsPC(oTest))
          {
              AssignCommand(oTest, DebugBusyNPC());
              nCount++;
          }
          oTest = GetNextObjectInShape(SHAPE_SPHERE, 10.0, lLoc, TRUE);
      }
      string sFeedback;
      if (nCount == 0)
      {
          SendMessageToPC(oPC, "There is no immediate reaction to your outburst.");
      }
      else
      {
        sFeedback = "Your outburst attracts the attention of " + IntToString(nCount) + " nearby " + (nCount > 1 ? "people" : "person") + ".";
        SendMessageToPC(oPC, sFeedback);
      }
  }
}
