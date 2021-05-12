
#include "inc_hai_heal"

void main()
{
    SetCommandable(TRUE);
    int bPolymorphed = GetHasEffect(EFFECT_TYPE_POLYMORPH);
    InitializeItemSpells(HenchDetermineClassToUse(), bPolymorphed, HENCH_INIT_ALL_SPELLS);

    // check if run from master shout
    if (GetLocalInt(OBJECT_SELF, henchHealCountStr) == -1)
    {
        DeleteLocalInt(OBJECT_SELF, henchHealCountStr);
        if(HenchTalentCureCondition(GetMaster()))
        {
            DelayCommand(2.0, VoiceCanDo());
            return;
        }
        if(HenchTalentHeal(GetMaster(), bPolymorphed ? HENCH_HAS_POLYMORPH_EFFECT : 0, HENCH_HEAL_FORCE | HENCH_HEAL_NO_POTIONS))
        {
            DelayCommand(2.0, VoiceCanDo());
            return;
        }
        DelayCommand(2.5, VoiceCannotDo());
        return;
    }

    object oHealTarget = GetLocalObject(OBJECT_SELF, "Henchman_Spell_Target");
    int curHealCount = GetLocalInt(OBJECT_SELF, henchHealCountStr);

    if (!GetIsObjectValid(oHealTarget))
    {
        InitializeAllyTargets(FALSE);
        if (curHealCount == 0)
        {
            ReportUnseenAllies();
        }
    }
    else if (!GetObjectSeen(oHealTarget))
    {
        SpeakString(sHenchCantSeeTarget + GetName(oHealTarget));
        DeleteLocalInt(OBJECT_SELF, henchHealCountStr);
        SetLocalObject(OBJECT_SELF, "Henchman_Spell_Target", OBJECT_INVALID);
        return;
    }
    if(HenchTalentCureCondition(oHealTarget))
    {
        SetLocalInt(OBJECT_SELF, henchHealCountStr, curHealCount + 1);
        return;
    }

    if (GetIsObjectValid(oHealTarget))
    {
        if(HenchTalentHeal(oHealTarget, bPolymorphed ? HENCH_HAS_POLYMORPH_EFFECT : 0, HENCH_HEAL_FORCE | HENCH_HEAL_NO_POTIONS))
        {
            SetLocalInt(OBJECT_SELF, henchHealCountStr, curHealCount + 1);
            return;
        }
    }
    else
    {
        if (HenchTalentHealAll(bPolymorphed ? HENCH_HAS_POLYMORPH_EFFECT : 0, HENCH_HEAL_FORCE | HENCH_HEAL_NO_POTIONS))
        {
            SetLocalInt(OBJECT_SELF, henchHealCountStr, curHealCount + 1);
            return;
        }
    }
    if (curHealCount == 0)
    {
            // didn't find any heal spells
        PlayVoiceChat(VOICE_CHAT_CUSS);
    }
    else
    {
        PlayVoiceChat(VOICE_CHAT_TASKCOMPLETE);
    }
    DeleteLocalInt(OBJECT_SELF, henchHealCountStr);
    SetLocalObject(OBJECT_SELF, "Henchman_Spell_Target", OBJECT_INVALID);
}
