#include "inc_nui_config"
#include "inc_restxp"
#include "inc_xp"

void main()
{
    object oPC = NuiGetEventPlayer();
    string sEvent = NuiGetEventType();
    int nToken = NuiGetEventWindow();
    string sElement = NuiGetEventElement();
    
    string sWindow = "pc_xpbar";
    
    
    
    // Do this first!
    HandleEditModeEvents();
    
    int bUpdate = GetScriptParam("updatebar") != "";
    int bGeometryChange = (sEvent == "watch" && sElement == "_geometry");
    
    if (GetScriptParam("init") != "" || bUpdate)
    {
        oPC = StringToObject(GetScriptParam("pc"));
        nToken = StringToInt(GetScriptParam("token"));
        bGeometryChange = 1;
    }
    
    if (sEvent == "watch")
    {
        if (sElement == "_config_orientation" || sElement == "_config_numgraduations")
        {
            bGeometryChange = 1;
        }
    }
    
    
    json jGeom = NuiGetBind(oPC, nToken, "_geometry");
    json jWidth = JsonObjectGet(jGeom, "w");
    json jHeight = JsonObjectGet(jGeom, "h");
    float fWidth = JsonGetFloat(jWidth);
    float fHeight = JsonGetFloat(jHeight);
    
    fWidth -= 10.0;
    fHeight -= 5.0;
    
    jWidth = JsonFloat(fWidth);
    jHeight = JsonFloat(fHeight);
    
    int bIsVertical = JsonGetInt(NuiGetBind(oPC, nToken, "_config_orientation"));
    //WriteTimestampedLogEntry("event geom: " + JsonDump(jGeom));
    
    if (bGeometryChange)
    {
        // We have to redo all the drawlists! Yay!
        json jBackgroundDrawListCoords = JsonArray();
        jBackgroundDrawListCoords = JsonArrayInsert(jBackgroundDrawListCoords, JsonFloat(0.0));
        jBackgroundDrawListCoords = JsonArrayInsert(jBackgroundDrawListCoords, JsonFloat(0.0));
        
        jBackgroundDrawListCoords = JsonArrayInsert(jBackgroundDrawListCoords, jWidth);
        jBackgroundDrawListCoords = JsonArrayInsert(jBackgroundDrawListCoords, JsonFloat(0.0));
        
        jBackgroundDrawListCoords = JsonArrayInsert(jBackgroundDrawListCoords, jWidth);
        jBackgroundDrawListCoords = JsonArrayInsert(jBackgroundDrawListCoords, jHeight);
        
        jBackgroundDrawListCoords = JsonArrayInsert(jBackgroundDrawListCoords, JsonFloat(0.0));
        jBackgroundDrawListCoords = JsonArrayInsert(jBackgroundDrawListCoords, jHeight);
        
        //WriteTimestampedLogEntry("jGeom: " + JsonDump(jGeom));
        //WriteTimestampedLogEntry("jBackgroundDrawListCoords: " + JsonDump(jBackgroundDrawListCoords));
        NuiSetBind(oPC, nToken, "background_coords", jBackgroundDrawListCoords);
        NuiSetBind(oPC, nToken, "edge_coords", jBackgroundDrawListCoords);
        
        int nNumGraduations = StringToInt(JsonGetString(GetNuiConfigValue(oPC, sWindow, "numgraduations")));
        
        json jGraduationDrawListCoords = JsonArray();
        
        if (nNumGraduations > 0)
        {
            // This loads the server hard and will eventually TMI
            if (nNumGraduations > 20) { nNumGraduations = 20; }
            float fGraduationDepth = fHeight*0.3;
            float fGraduationWidth = 2.0;
            int i;
            jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(0.0));
            jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(0.0));
            
            if (!bIsVertical)
            {
                for (i=-1; i<nNumGraduations+1; i++)
                {
                    float fProportion = IntToFloat(i+1)/IntToFloat(nNumGraduations+1);
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fProportion*fWidth - (fGraduationWidth/2.0)));
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(0.0));
                    
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fProportion*fWidth - (fGraduationWidth/2.0)));
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fGraduationDepth));
                    
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fProportion*fWidth + (fGraduationWidth/2.0)));
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fGraduationDepth));
                    
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fProportion*fWidth + (fGraduationWidth/2.0)));
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(0.0));
                }
                
                jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, jWidth);
                jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(0.0));
                
                jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, jWidth);
                jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, jHeight);
                
                for (i=nNumGraduations; i>=-1; i--)
                {
                    float fProportion = IntToFloat(i+1)/IntToFloat(nNumGraduations+1);
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fProportion*fWidth + (fGraduationWidth/2.0)));
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fHeight));
                    
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fProportion*fWidth + (fGraduationWidth/2.0)));
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fHeight-fGraduationDepth));
                    
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fProportion*fWidth - (fGraduationWidth/2.0)));
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fHeight-fGraduationDepth));
                    
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fProportion*fWidth - (fGraduationWidth/2.0)));
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, jHeight);
                }
            }
            else
            {
                fGraduationDepth = fWidth*0.3;
                for (i=-1; i<nNumGraduations+1; i++)
                {
                    float fProportion = IntToFloat(i+1)/IntToFloat(nNumGraduations+1);
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(0.0));
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fProportion*fHeight - (fGraduationWidth/2.0)));
                    
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fGraduationDepth));
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fProportion*fHeight - (fGraduationWidth/2.0)));
                    
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fGraduationDepth));
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fProportion*fHeight + (fGraduationWidth/2.0)));
                    
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(0.0));
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fProportion*fHeight + (fGraduationWidth/2.0)));
                }
                
                jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(0.0));
                jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, jHeight);
                
                jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, jWidth);
                jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, jHeight);
                
                for (i=nNumGraduations; i>=-1; i--)
                {
                    float fProportion = IntToFloat(i+1)/IntToFloat(nNumGraduations+1);
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fWidth));
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fProportion*fHeight + (fGraduationWidth/2.0)));
                    
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fWidth-fGraduationDepth));
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fProportion*fHeight + (fGraduationWidth/2.0)));
                    
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fWidth-fGraduationDepth));
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fProportion*fHeight - (fGraduationWidth/2.0)));
                    
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, jWidth);
                    jGraduationDrawListCoords = JsonArrayInsert(jGraduationDrawListCoords, JsonFloat(fProportion*fHeight - (fGraduationWidth/2.0)));
                }
            }
        }
        
        NuiSetBind(oPC, nToken, "graduation_coords", jGraduationDrawListCoords);
        
        float fTextX = fWidth/2.0 - 7.0;
        float fTextY = fHeight/2.0 - 10.0;
        if (fTextX < 0.0) { fTextX = 0.0; }
        if (fTextY < 0.0) { fTextY = 0.0; }
        NuiSetBind(oPC, nToken, "text_pos", NuiRect(fTextX, fTextY, 200.0, 40.0));
        bUpdate = 1;
    }
    if (bUpdate)
    {
        int nPCLevel = GetLevelFromXP(GetXP(oPC));
        if (nPCLevel >= 12)
        {
            NuiDestroy(oPC, nToken);
            return;
        }
        int nXPAtStartOfCurrentLevel = StringToInt(Get2DAString("exptable", "XP", nPCLevel-1));
        int nXPAtStartOfNextLevel = StringToInt(Get2DAString("exptable", "XP", nPCLevel));
        int nAmountOfXPFromStartToNext = nXPAtStartOfNextLevel - nXPAtStartOfCurrentLevel;
        int nPCProgressInLevel = GetXP(oPC) - nXPAtStartOfCurrentLevel;
        int nRestXP = FloatToInt(GetRestedXP(oPC) * (1.0 + RESTEDXP_KILL_INCREASE));
        float fFilledProportion = IntToFloat(nPCProgressInLevel)/IntToFloat(nAmountOfXPFromStartToNext);
        float fRestProportion = IntToFloat(nRestXP)/IntToFloat(nAmountOfXPFromStartToNext);
        // Rest XP needs capping at the next level up point... for the purpose of a display bar anyway
        if (fFilledProportion + fRestProportion >= 1.0)
        {
            fRestProportion = 1.0 - fFilledProportion;
        }
        int nPercent = Round(fFilledProportion*100);
        string sPercent = IntToString(nPercent) + "%";
        NuiSetBind(oPC, nToken, "text_content", JsonString(sPercent));
        //WriteTimestampedLogEntry("fFilledProportion = " + FloatToString(fFilledProportion));
        //WriteTimestampedLogEntry("fRestProportion = " + FloatToString(fRestProportion));
        float fCombinedProportion = fRestProportion + fFilledProportion;
        json jFilledDrawListCoords = JsonArray();
        if (!bIsVertical)
        {
            jFilledDrawListCoords = JsonArrayInsert(jFilledDrawListCoords, JsonFloat(0.0));
            jFilledDrawListCoords = JsonArrayInsert(jFilledDrawListCoords, JsonFloat(0.0));
            
            jFilledDrawListCoords = JsonArrayInsert(jFilledDrawListCoords, JsonFloat(fWidth*fFilledProportion));
            jFilledDrawListCoords = JsonArrayInsert(jFilledDrawListCoords, JsonFloat(0.0));
            
            jFilledDrawListCoords = JsonArrayInsert(jFilledDrawListCoords, JsonFloat(fWidth*fFilledProportion));
            jFilledDrawListCoords = JsonArrayInsert(jFilledDrawListCoords, jHeight);
            
            jFilledDrawListCoords = JsonArrayInsert(jFilledDrawListCoords, JsonFloat(0.0));
            jFilledDrawListCoords = JsonArrayInsert(jFilledDrawListCoords, jHeight);
            
            json jRestedDrawListCoords = JsonArray();
            jRestedDrawListCoords = JsonArrayInsert(jRestedDrawListCoords, JsonFloat(fWidth*fFilledProportion));
            jRestedDrawListCoords = JsonArrayInsert(jRestedDrawListCoords, JsonFloat(0.0));
            
            jRestedDrawListCoords = JsonArrayInsert(jRestedDrawListCoords, JsonFloat(fWidth*fCombinedProportion));
            jRestedDrawListCoords = JsonArrayInsert(jRestedDrawListCoords, JsonFloat(0.0));
            
            jRestedDrawListCoords = JsonArrayInsert(jRestedDrawListCoords, JsonFloat(fWidth*fCombinedProportion));
            jRestedDrawListCoords = JsonArrayInsert(jRestedDrawListCoords, jHeight);
            
            jRestedDrawListCoords = JsonArrayInsert(jRestedDrawListCoords, JsonFloat(fWidth*fFilledProportion));
            jRestedDrawListCoords = JsonArrayInsert(jRestedDrawListCoords, jHeight);
            
            //WriteTimestampedLogEntry("jFilledDrawListCoords: " + JsonDump(jFilledDrawListCoords));
            //WriteTimestampedLogEntry("jRestedDrawListCoords: " + JsonDump(jRestedDrawListCoords));
            
            NuiSetBind(oPC, nToken, "rested_coords", jRestedDrawListCoords);
            NuiSetBind(oPC, nToken, "filled_coords", jFilledDrawListCoords);
        }
        else
        {
            jFilledDrawListCoords = JsonArrayInsert(jFilledDrawListCoords, JsonFloat(0.0));
            jFilledDrawListCoords = JsonArrayInsert(jFilledDrawListCoords, jHeight);
            
            jFilledDrawListCoords = JsonArrayInsert(jFilledDrawListCoords, JsonFloat(0.0));
            jFilledDrawListCoords = JsonArrayInsert(jFilledDrawListCoords, JsonFloat(fHeight*fFilledProportion));
            
            jFilledDrawListCoords = JsonArrayInsert(jFilledDrawListCoords, jWidth);
            jFilledDrawListCoords = JsonArrayInsert(jFilledDrawListCoords, JsonFloat(fHeight*fFilledProportion));
            
            jFilledDrawListCoords = JsonArrayInsert(jFilledDrawListCoords, jWidth);
            jFilledDrawListCoords = JsonArrayInsert(jFilledDrawListCoords, jHeight);
            
            
            json jRestedDrawListCoords = JsonArray();
            jRestedDrawListCoords = JsonArrayInsert(jRestedDrawListCoords, JsonFloat(0.0));
            jRestedDrawListCoords = JsonArrayInsert(jRestedDrawListCoords, JsonFloat(fHeight*fFilledProportion));
            
            jRestedDrawListCoords = JsonArrayInsert(jRestedDrawListCoords, JsonFloat(0.0));
            jRestedDrawListCoords = JsonArrayInsert(jRestedDrawListCoords, JsonFloat(fHeight*fCombinedProportion));
            
            jRestedDrawListCoords = JsonArrayInsert(jRestedDrawListCoords, jWidth);
            jRestedDrawListCoords = JsonArrayInsert(jRestedDrawListCoords, JsonFloat(fHeight*fCombinedProportion));
            
            jRestedDrawListCoords = JsonArrayInsert(jRestedDrawListCoords, jWidth);
            jRestedDrawListCoords = JsonArrayInsert(jRestedDrawListCoords, JsonFloat(fHeight*fFilledProportion));
            
            
            NuiSetBind(oPC, nToken, "rested_coords", jRestedDrawListCoords);
            NuiSetBind(oPC, nToken, "filled_coords", jFilledDrawListCoords);
        }
    }
}