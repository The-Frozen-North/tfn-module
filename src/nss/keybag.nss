#include "nw_inc_nui"
#include "nw_inc_nui_insp"
#include "inc_sql"
#include "inc_key"

void MakeKeyWindow(object oPC)
{   
    oPC = GetMasterFromPossessedFamiliar(oPC);
    SQLocalsPlayer_CreateTable(oPC);
    
    sqlquery sql = SqlPrepareQueryObject(oPC,
        "SELECT varname FROM " + SQLOCALSPLAYER_TABLE_NAME + " " +
        "WHERE type & @type AND varname LIKE @like ESCAPE @escape;");

    SqlBindInt(sql, "@type", SQLOCALSPLAYER_TYPE_INT);
    SqlBindString(sql, "@like", "haskeytag\\_%");
    SqlBindString(sql, "@escape", "\\");
    
    int nNumKeys = 0;
    json jLayout = JsonArray();
    
    while (SqlStep(sql))
    {
        json jRow = JsonArray();
        // Stuff in the database is saved as haskeytag_<the key tag>
        string sKeyTag = SqlGetString(sql, 0);
        sKeyTag = GetSubString(sKeyTag, 10, 999);
        if (GetStringLength(sKeyTag) == 0) { break; }
        string sKeyName = GetKeyName(sKeyTag);
        string sKeyDesc = GetKeyDescription(sKeyTag);
        json jName = NuiLabel(JsonString(sKeyName), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE));
        jName = NuiWidth(jName, 160.0);
        jRow = JsonArrayInsert(jRow, jName);
        json jDesc = NuiText(JsonString(sKeyDesc), TRUE, NUI_SCROLLBARS_Y);
        jRow = JsonArrayInsert(jRow, jDesc);
        
        json jWrappedRow = NuiRow(jRow);
        jWrappedRow = NuiHeight(jWrappedRow, 100.0);
        
        jLayout = JsonArrayInsert(jLayout, jWrappedRow);
        
        nNumKeys++;
    }
        
    json root = NuiCol(jLayout);
    //json root = NuiCol(NuiGroup(jLayout));
    //json root = jCol;
    WriteTimestampedLogEntry(JsonDump(root));
    json nui = NuiWindow(
        root,
        JsonString("Collected Keys"),
        NuiBind("geometry"),
        JsonBool(TRUE), // resize
        JsonBool(FALSE), // collapse
        JsonBool(TRUE), // closable
        JsonBool(FALSE), // transparent
        JsonBool(TRUE)); // border
        
            
    
    int token = NuiCreate(oPC, nui, "keybag");
    NuiSetBind(oPC, token, "geometry", NuiRect(500.0, 210.0, 600.0, 500.0));
    
    if (nNumKeys == 0)
    {
        FloatingTextStringOnCreature("The key bag is empty.", oPC, FALSE);
        NuiDestroy(oPC, token);
        return;
    }
    
}

void main()
{
    if (GetIsPC(OBJECT_SELF))
    {
        MakeKeyWindow(OBJECT_SELF);
    }
    //MakeWindowInspector(OBJECT_SELF);
}