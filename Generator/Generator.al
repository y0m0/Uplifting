page 99999 "Uplift Generator"
{
    PageType = Document;
    SourceTable = AllObj;
    SourceTableView = where("Object Type" = filter(Table),
                             "App Package ID" = filter('{00000000-0000-0000-0000-000000000000}'),
                             "Object ID" = filter('50000..2000000000'));
    Editable = true;
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            field(Ext; ExtensionGUID)
            {
                Caption = 'Extension ID GUID';
                ApplicationArea = All;
            }
            field(Prefix; ExtensionPrefix)
            {
                Caption = 'Extension Prefix';
                ApplicationArea = All;
            }
            field(FieldsFilter; FieldNumberFilter)
            {
                Caption = 'Std. Obj. Field number filter';
                ApplicationArea = All;
            }
            repeater(Rep)
            {
                Editable = false;
                field("Object ID"; "Object ID")
                {
                    ApplicationArea = All;
                }
                field("Object Name"; "Object Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(SetModifiedTables)
            {
                Caption = 'Set Modified Tables';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "Modified Tables";
            }

            action(Generate)
            {
                Caption = 'Generate Uplifting Script';
                ApplicationArea = All;
                InFooterBar = true;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                begin
                    GenerateScript();
                end;
            }
        }
    }
    procedure GenerateScript()
    var
        Company: Record Company;
        Tables: Record AllObj;
        ModifiedTables: Record "Modified Table";
        SQL1: BigText;
        SQL2: BigText;
        SQL3: BigText;
        FileName: Text;
        InS: InStream;
        OutS: OutStream;
        B: Record TempBlob;
    begin
        ModifiedTablesOnly := ModifiedTablesExists();

        LF[1] := 10;
        if ExtensionGUID = '' then
            Error('Please specify a Extension GUID before continuing');

        // Step 1
        if ModifiedTablesOnly then begin

            ModifiedTables.SetRange(DataPerCompany, true);
            ModifiedTables.SetRange(TableType, ModifiedTables.TableType::Normal);
            ModifiedTables.SetRange(ObsoleteState, ModifiedTables.ObsoleteState::No);
            if Company.FindSet(false) then
                repeat
                    if ModifiedTables.FindSet(false) then
                        repeat
                            SQL1.AddText(SQLTable(ConvertName(Company.Name) + '$', ConvertName(Tables."Object Name"), 1));
                            SQL2.AddText(SQLTable(ConvertName(Company.Name) + '$', ConvertName(Tables."Object Name"), 2));
                            SQL3.AddText(SQLTable(ConvertName(Company.Name) + '$', ConvertName(Tables."Object Name"), 3));
                        until ModifiedTables.Next() = 0;
                until Company.Next() = 0;

            ModifiedTables.SetRange(DataPerCompany, false);
            if ModifiedTables.FindSet(false) then
                repeat
                    SQL1.AddText(SQLTable('', ConvertName(Tables."Object Name"), 1));
                    SQL2.AddText(SQLTable('', ConvertName(Tables."Object Name"), 2));
                    SQL3.AddText(SQLTable('', ConvertName(Tables."Object Name"), 3));
                until ModifiedTables.Next() = 0;

        end else begin

            if Company.FindSet(false) then
                repeat
                    CurrPage.SetSelectionFilter(Tables);
                    if Tables.FindSet(false) then
                        repeat
                            if DataPerCompany(Tables."Object ID") and IsNormalNotObsoletedTable(Tables."Object ID") then begin
                                SQL1.AddText(SQLTable(ConvertName(Company.Name) + '$', ConvertName(Tables."Object Name"), 1));
                                SQL2.AddText(SQLTable(ConvertName(Company.Name) + '$', ConvertName(Tables."Object Name"), 2));
                                SQL3.AddText(SQLTable(ConvertName(Company.Name) + '$', ConvertName(Tables."Object Name"), 3));
                            end;
                        until Tables.Next() = 0;
                until Company.Next() = 0;

            if Tables.FindSet(false) then
                repeat
                    if (not DataPerCompany(Tables."Object ID")) and IsNormalNotObsoletedTable(Tables."Object ID") then begin
                        SQL1.AddText(SQLTable('', ConvertName(Tables."Object Name"), 1));
                        SQL2.AddText(SQLTable('', ConvertName(Tables."Object Name"), 2));
                        SQL3.AddText(SQLTable('', ConvertName(Tables."Object Name"), 3));
                    end;
                until Tables.NEXT = 0;

        end;

        if SQL1.Length > 0 then begin
            // Step1
            SQL1.AddText(GenerateFieldsScript(1));
            B.Init;
            B.BLob.CreateOutStream(OutS);
            SQL1.Write(OutS);
            B.Blob.CreateInStream(InS);
            FileName := 'uplift-step1.sql';
            DownloadFromStream(InS, 'Save SQL Script', '', '', FileName);
            if Confirm('Step 1 download done?') then;

            // Step2
            SQL2.AddText(GenerateFieldsScript(2));
            B.Init;
            B.BLob.CreateOutStream(OutS);
            SQL2.Write(OutS);
            B.Blob.CreateInStream(InS);
            FileName := 'uplift-step2.sql';
            DownloadFromStream(InS, 'Save SQL Script', '', '', FileName);
            if Confirm('Step 2 download done?') then;

            // Step3
            SQL3.AddText(GenerateFieldsScript(3));
            B.Init;
            B.BLob.CreateOutStream(OutS);
            SQL3.Write(OutS);
            B.Blob.CreateInStream(InS);
            FileName := 'uplift-step3.sql';
            DownloadFromStream(InS, 'Save SQL Script', '', '', FileName);
            Message('Done');
        end;
    end;

    procedure GenerateFieldsScript(Step: Integer): Text;
    var
        F: Record Field;
        FieldList: List of [Text];
        CurrentTable: Integer;
        SQL: Text;
        Company: Record Company;
    begin
        F.SetFilter("No.", FieldNumberFilter);
        F.SetFilter(TableNo, '1..49999|99000750..99009999');
        F.SetRange(Class, F.Class::Normal);
        if F.FindSet() then
            repeat
                if F.TableNo <> CurrentTable then begin
                    if CurrentTable <> 0 then begin
                        if Company.FindSet() then
                            repeat
                                // Generate script for table
                                SQL += GenerateTableFields(CurrentTable, Company, FieldList, Step);
                            until Company.next = 0;
                    end;
                    Clear(FieldList);
                    CurrentTable := F.TableNo;
                end;
                FieldList.Add(F.FieldName);
            until F.Next() = 0;

        if CurrentTable <> 0 then
            if Company.FindSet() then
                repeat
                    // Generate script for table
                    SQL += GenerateTableFields(CurrentTable, Company, FieldList, Step);
                until Company.Next() = 0;
        exit(SQL);
    end;

    procedure GenerateTableFields(CurrentTableNo: Integer;
                                  var Company: Record Company;
                                  var FieldList: List of [Text];
                                  Step: Integer): Text
    var
        FieldName: Text;
        RecRef: RecordRef;
        KeyRef: KeyRef;
        FRef: FieldRef;
        FieldListStr: Text;
        NewTableName: Text;
        TableName: Text;
        TableExtensionName: Text;
        i: Integer;
        PrimaryKeyTransferList: Text;
        FieldTransferList: Text;
        FieldKeyNames: List of [Text];
    begin
        if not IsNormalNotObsoletedTable(CurrentTableNo) then
            exit;

        if ModifiedTablesOnly then
            if not IsTableInModifiedTables(CurrentTableNo) then
                exit;

        RecRef.Open(CurrentTableNo);
        NewTableName := ConvertName(Company.Name) + '$' + ConvertName(RecRef.Name) + '.new';
        TableName := ConvertName(Company.Name) + '$' + ConvertName(RecRef.Name);
        TableExtensionName := ConvertName(Company.Name) + '$' + ConvertName(RecRef.Name) + '$' + ExtensionGUID;
        KeyRef := RecRef.KeyIndex(1);
        for i := 1 to KeyRef.FieldCount do begin
            FRef := KeyRef.FieldIndex(i);
            FieldKeyNames.Add(FRef.Name);
            if FieldListStr <> '' then
                FieldListStr += ',';
            FieldListStr += '[' + ConvertName(FRef.Name) + ']';
            if PrimaryKeyTransferList <> '' then
                PrimaryKeyTransferList += LF + ' and ';
            PrimaryKeyTransferList += '([' + NewTableName + '].[' + ConvertName(FRef.Name) + ']=[' + TableExtensionName + '].[' + ConvertName(FRef.Name) + '])';
        end;
        for i := 1 to FieldList.Count do begin
            FieldList.Get(i, FieldName);
            if not (FieldKeyNames.Contains(FieldName)) then begin // avoid adding key fields again
                if FieldListStr <> '' then
                    FieldListStr += ',';

                FieldListStr += '[' + ConvertName(FieldName) + ']';
                if FieldTransferList <> '' then
                    FieldTransferList += LF + ',';
                FieldTransferList += '[' + TableExtensionName + '].[' + ConvertName(FieldName) + ']=[' + NewTableName + '].[' + ConvertName(FieldName) + ']';
            end;
        end;
        case Step of
            1:
                exit('select ' + FieldListStr + ' into [' + NewTableName + '] from [' + TableName + '];' + LF);
            2:
                exit(
                    'update [' + TableExtensionName + '] set ' + LF +
                    FieldTransferList + LF +
                    ' from [' + NewTableName + '] where ' + PrimaryKeyTransferList + ';' + LF
                );
            3:
                exit('drop table [' + NewTableName + '];' + LF);
        end;
    end;

    procedure SQLTable(Company: Text; TableName: Text; Step: Integer): Text;
    begin
        case Step of
            1:
                exit(
                    'exec sp_rename ''' + Company + TableName + ''',''' + Company + TableName + '$' + ExtensionGUID + '.bak'';' + LF +
                    'select * into [' + Company + TableName + '] from [' + Company + TableName + '$' + ExtensionGuid + '.bak] where 1 = 2;' + LF
                );
            2:
                exit(
                    'exec sp_rename ''[' + Company + TableName + '$' + ExtensionGUID + ']'',''' + Company + TableName + '$' + ExtensionGUID + '.bak2'';' + LF +
                    'exec sp_rename ''[' + Company + TableName + '$' + ExtensionGUID + '.bak]'',''' + Company + TableName + '$' + ExtensionGUID + ''';' + LF
                );
            3:
                exit('drop table [' + Company + TableName + '$' + ExtensionGUID + '.bak2];' + LF);
        end;
    end;

    procedure ConvertName(name: Text): Text;
    var
        i: Integer;
        BadCharacters: Text;
    begin
        BadCharacters := '."\/''%][';
        for i := 1 to strlen(Name) do begin
            if strpos(BadCharacters, copystr(name, i, 1)) > 0 then
                Name[i] := '_';
        end;
        exit(Name);
    end;

    procedure DataPerCompany(TableID: Integer): Boolean
    var
        TableMetadata: Record "Table Metadata";
    begin
        TableMetadata.get(TableID);
        exit(TableMetadata.DataPerCompany)
    end;

    procedure IsNormalNotObsoletedTable(TableID: Integer): Boolean
    var
        TableMetadata: Record "Table Metadata";
    begin
        TableMetadata.Get(TableID);

        if (TableMetadata.ObsoleteState = TableMetadata.ObsoleteState::Removed) then
            exit;

        exit(TableMetadata.TableType = TableMetadata.TableType::Normal);
    end;

    procedure IsTableInModifiedTables(TableID: Integer): Boolean
    var
        ModifiedTable: Record "Modified Table";
    begin
        exit(ModifiedTable.Get(TableID));
    end;

    procedure ModifiedTablesExists(): Boolean
    var
        ModifiedTable: Record "Modified Table";
    begin
        exit(not ModifiedTable.IsEmpty);
    end;

    var
        ExtensionGUID: Text;
        ExtensionPrefix: Text;
        FieldNumberFilter: Text;
        LF: Text;
        ModifiedTablesOnly: Boolean;
}