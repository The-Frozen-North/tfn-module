// consider: plc_rck -> plc_drow
// plc_runes -> something else

void main()
{
    int nState = GetLocalInt(OBJECT_SELF, "tilestate");
    if (nState)
    {
        ReplaceObjectTexture(OBJECT_SELF, "plc_rck", "plc_rck");
        ReplaceObjectTexture(OBJECT_SELF, "plc_runes", "plc_rck");
    }
    else
    {
        ReplaceObjectTexture(OBJECT_SELF, "plc_rck", "plc_drow");
        ReplaceObjectTexture(OBJECT_SELF, "plc_runes", "plc_drow");
    }
}