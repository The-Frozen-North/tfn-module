#include "inc_penalty"
#include "inc_henchman"

void RemoveAllEffects(object oObj)
{
    effect eTest = GetFirstEffect(oObj);
    while (GetIsEffectValid(eTest))
    {
        DelayCommand(0.0, RemoveEffect(oObj, eTest));
        eTest = GetNextEffect(oObj);
    }
}

void main()
{
    object oPlayer = OBJECT_SELF;

    // abandon all dead henchman. this is the cleanest way to do it as this is shared between all "respawn" scripts
    ClearDeadHenchman(oPlayer);

    object oHenchman = GetFirstFactionMember(oPlayer, FALSE);

// force rest all henchmans for this player
    while (GetIsObjectValid(oHenchman))
    {
        if (!GetIsDead(oHenchman) && GetMaster(oHenchman) == oPlayer)
        {
            DeleteLocalInt(oHenchman, "times_died");
            DeleteLocalInt(oHenchman, "PETRIFIED");
            RemoveAllEffects(oHenchman); // is this necessary with ForceRest?
            ForceRest(oHenchman);  
        }

        oHenchman = GetNextFactionMember(oPlayer, FALSE);
    }

    int nXP = GetXP(oPlayer);
    // No penalty below level 3
    if (nXP >= 3000)
    {
        SetXP(oPlayer, GetXPOnRespawn(oPlayer));
        TakeGoldFromCreature(GetGoldLossOnRespawn(oPlayer), oPlayer, TRUE);
        UpdateXPBarUI(oPlayer);
    }
}
