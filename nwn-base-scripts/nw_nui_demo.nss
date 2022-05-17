#include "nw_inc_nui"
#include "nw_inc_nui_insp"

void MakeSpreadsheet(object pc)
{
    int datarowcount = 10;
    int datacolcount = 5;

    int col, row;

    json template = JsonArray();

    json btndel = NuiVisible(NuiId(NuiButton(JsonString("-")), "btn-"), NuiBind("visible" + IntToString(datacolcount-1)));
    template = JsonArrayInsert(template, NuiListTemplateCell(btndel, 20.0, FALSE));

    template = JsonArrayInsert(template, NuiListTemplateCell(NuiSpacer(), 10.0, FALSE));

    json btnadd = NuiVisible(NuiId(NuiButton(JsonString("+")), "btn+"), NuiBind("visible0"));
    template = JsonArrayInsert(template, NuiListTemplateCell(btnadd, 20.0, FALSE));

    // You could fake adding more columns by templating them, but hiding them with visible=false until needed.
    // NB: The UI system only allows 16 columns in total.
    for (col = 0; col < datacolcount; col++)
    {
      json placeholder = JsonString("empty");
      json value = NuiBind("data" + IntToString(col));
      json elem = NuiTextEdit(placeholder, value, 10, FALSE);
      elem = NuiId(elem, "cell" + IntToString(col));
      elem = NuiMargin(elem, 0.0);
      elem = NuiPadding(elem, 0.0);
      elem = NuiVisible(elem, NuiBind("visible" + IntToString(col)));
      json cell = NuiListTemplateCell(elem, 80.0, FALSE);
      template = JsonArrayInsert(template, cell);
    }

    json jcol = JsonArray();
    jcol = JsonArrayInsert(jcol, NuiList(template, NuiBind("data0"), NUI_STYLE_ROW_HEIGHT, FALSE, NUI_SCROLLBARS_BOTH));

    json jrow = JsonArray();
    jrow = JsonArrayInsert(jrow, NuiHeight(NuiLabel(NuiBind("label"), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE)), 20.0));
    jcol = JsonArrayInsert(jcol, NuiRow(jrow));

    json root = NuiCol(jcol);
    json nui = NuiWindow(
        root,
        JsonString("Neverwinter Sheets: Excel Edition"),
        NuiBind("geometry"),
        NuiBind("resizable"),
        NuiBind("collapsed"),
        NuiBind("closable"),
        NuiBind("transparent"),
        NuiBind("border"));

    int token = NuiCreate(pc, nui, "spreadsheet");

    NuiSetBind(pc, token, "collapsed", JsonBool(FALSE));
    NuiSetBind(pc, token, "resizable", JsonBool(TRUE));
    NuiSetBind(pc, token, "closable", JsonBool(TRUE));
    NuiSetBind(pc, token, "transparent", JsonBool(FALSE));
    NuiSetBind(pc, token, "border", JsonBool(TRUE));
    NuiSetBind(pc, token, "geometry", NuiRect(830.0, 10.0, 900.0, 600.0));

    NuiSetBind(pc, token, "colcount", JsonInt(datacolcount));

    for (col = 0; col < datacolcount; col++)
    {
      json data = JsonArray();
      json visible = JsonArray();

      for (row = 0; row < datarowcount; row++)
      {
        json seed = JsonString(IntToString(row * datacolcount + col));
        data = JsonArrayInsert(data, seed);
        visible = JsonArrayInsert(visible, JsonBool(1));
      }
      NuiSetBind(pc, token, "data" + IntToString(col), data);
      NuiSetBind(pc, token, "visible" + IntToString(col), visible);
      NuiSetBindWatch(pc, token, "data" + IntToString(col), TRUE);
    }
}

void MakePortraitFlipper(object pc)
{
  json col;
  json row;

  col = JsonArray();

  row = JsonArray();
    row = JsonArrayInsert(row, NuiSpacer());
    row = JsonArrayInsert(row, JsonObjectSet(NuiLabel(NuiBind("po_resref"), JsonNull(), JsonNull()), "text_color",
            NuiColor(255, 0, 0)));
    row = JsonArrayInsert(row, NuiSpacer());
  col = JsonArrayInsert(col, NuiHeight(NuiRow(row), 20.0));

  row = JsonArray();
    row = JsonArrayInsert(row, NuiSpacer());
    row = JsonArrayInsert(row, NuiLabel(NuiBind("po_id"), JsonNull(), JsonNull()));
    row = JsonArrayInsert(row, NuiSpacer());
  col = JsonArrayInsert(col, NuiHeight(NuiRow(row), 20.0));

  row = JsonArray();
    row = JsonArrayInsert(row, NuiSpacer());
    json img = NuiImage(NuiBind("po_resref"),
                        JsonInt(NUI_ASPECT_EXACT),
                        JsonInt(NUI_HALIGN_CENTER),
                        JsonInt(NUI_VALIGN_TOP));
    img = NuiGroup(img);
    img = NuiWidth(img, 256.0);
    img = NuiHeight(img, 400.0);
    row = JsonArrayInsert(row, img);
    row = JsonArrayInsert(row, NuiSpacer());
  col = JsonArrayInsert(col, NuiRow(row));

  row = JsonArray();
  {
    row = JsonArrayInsert(row, NuiSpacer());
    // TODO: Width(100%)
    row = JsonArrayInsert(row, NuiId(NuiCombo(NuiBind("po_categories"), NuiBind("po_category")), "category"));
    row = JsonArrayInsert(row, NuiSpacer());
  }
  col = JsonArrayInsert(col, NuiRow(row));

  row = JsonArray();
    json btnprev = NuiEnabled(NuiId(NuiButton(JsonString("<")), "btnprev"), NuiBind("btnpreve"));
    json btnok   = NuiEnabled(NuiId(NuiButton(JsonString("Set")), "btnok"), NuiBind("btnoke"));
    json btnnext = NuiEnabled(NuiId(NuiButton(JsonString(">")), "btnnext"), NuiBind("btnnexte"));
    row = JsonArrayInsert(row, NuiWidth(btnprev, 80.0));
    row = JsonArrayInsert(row, NuiSpacer());
    row = JsonArrayInsert(row, NuiWidth(btnok, 80.0));
    row = JsonArrayInsert(row, NuiSpacer());
    row = JsonArrayInsert(row, NuiWidth(btnnext, 80.0));
  col = JsonArrayInsert(col, NuiRow(row));

  json root = NuiCol(col);
	json nui = NuiWindow(
    root,
    NuiBind("po_resref"),
    NuiBind("geometry"),
    NuiBind("resizable"),
    NuiBind("collapsed"),
    NuiBind("closable"),
    NuiBind("transparent"),
    NuiBind("border"));

	int token = NuiCreate(pc, nui, "poviewer");

  int id = 164;
  string ref = "po_" + Get2DAString("portraits", "BaseResRef", id) + "h";
  NuiSetBind(pc, token, "po_id", JsonInt(id));
  NuiSetBind(pc, token, "po_resref", JsonString(ref));
  NuiSetBind(pc, token, "btnpreve", JsonBool(0));
  NuiSetBind(pc, token, "btnnexte", JsonBool(1));

  json combovalues = JsonArray();
  combovalues = JsonArrayInsert(combovalues, NuiComboEntry("Cats (164-167)", 0));
  combovalues = JsonArrayInsert(combovalues, NuiComboEntry("Dragons (191-200)", 1));
  NuiSetBind(pc, token, "po_categories", combovalues);
  NuiSetBind(pc, token, "po_category", JsonInt(0));

  NuiSetBind(pc, token, "collapsed", JsonBool(FALSE));
  NuiSetBind(pc, token, "resizable", JsonBool(FALSE));
  NuiSetBind(pc, token, "closable", JsonBool(TRUE));
  NuiSetBind(pc, token, "transparent", JsonBool(FALSE));
  NuiSetBind(pc, token, "border", JsonBool(TRUE));

  NuiSetBind(pc, token, "geometry", NuiRect(420.0, 10.0, 400.0, 600.0));

  NuiSetBindWatch(pc, token, "po_category", TRUE);
  NuiSetBindWatch(pc, token, "collapsed", TRUE);
  NuiSetBindWatch(pc, token, "geometry", TRUE);
}

void main()
{
  SetEventScript(GetModule(), EVENT_SCRIPT_MODULE_ON_NUI_EVENT, "nw_nui_demo_evt");
	object pc = GetFirstPC();
  MakeWindowInspector(pc);
  MakePortraitFlipper(pc);
  MakeSpreadsheet(pc);
}
