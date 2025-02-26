page 99998 "Modified Tables"
{
    Caption = 'Modified Tables';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Modified Table";
    
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Table No."; Rec."Table No." )
                {
                    ApplicationArea = All;
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(DataPerCompany; Rec.DataPerCompany)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(TableType; Rec."TableType")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(ObsoleteState; Rec.ObsoleteState)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
}