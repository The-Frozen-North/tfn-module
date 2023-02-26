// This tests whether a PC is at one of several quest states.
// For linear quest chains, consider using dlg_q_chk_at instead!
// This is intended for checking more than one stage at a time.

// Params: "quest" -> quest name eg "q_golems"
// "stages" -> a comma separated list of quest states

// This is valid if the PC is at ANY of the listed quest states.

// eg "quest"->"q_golems", "stages"->"20, 21, 26, 27, 29, 51"
// is valid only if the PC is at 20_q_golem, 21_q_golem, 26_q_golem, etc.

#include "inc_quest"
#include "util_i_csvlists"
#include "inc_debug"

int StartingConditional()
{
    string sQuest = GetScriptParam("quest");
    string sStages = GetScriptParam("stages");
    // Dev server debug: check the list format, because making mistakes is quite easy
    if (GetIsDevServer())
    {
        int bStartedNumber = 0;
        int bDoneNumber = 0;
        int nPos;
        int bError = 0;
        int nLength = GetStringLength(sStages);
        for (nPos=0; nPos<nLength; nPos++)
        {
            string sChar = GetSubString(sStages, nPos, 1);
            if (sChar == " ")
            {
                if (!bDoneNumber && bStartedNumber)
                {
                    bDoneNumber = 1;
                }
            }
            else if (sChar == "0" || (sChar != "0" && IntToString(StringToInt(sChar)) == sChar))
            {
                bStartedNumber = 1;
                if (bDoneNumber)
                {
                    SendDebugMessage("BAD STAGES LIST: dlg_q_chk_multi pos " + IntToString(nPos) + ": number after space");
                    bError = 1;
                }
            }
            else if (sChar == ",")
            {
                if (!bStartedNumber)
                {
                    SendDebugMessage("BAD STAGES LIST: dlg_q_chk_multi pos " + IntToString(nPos) + ": comma without number");
                    bError = 1;
                }
                bStartedNumber = 0;
                bDoneNumber = 0;
            }
            else
            {
                SendDebugMessage("BAD STAGES LIST: dlg_q_chk_multi pos " + IntToString(nPos) + ": bad character " + sChar);bError = 1;
            }
        }
        if (bError)
        {
            SpeakString("Bad dlg_q_chk_multi, check messages!");
        }
    }
    int i;
    int nCount = CountList(sStages);
    object oPC = GetPCSpeaker();
    for (i=0; i<nCount; i++)
    {
        int nStage = StringToInt(GetListItem(sStages, i));
        if (GetQuestEntry(oPC, sQuest) == nStage)
        {
            return 1;
        }
    }
    return 0;
}
