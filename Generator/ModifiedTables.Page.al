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
                }
                field(DataPerCompany; Rec.DataPerCompany)
                {
                    ApplicationArea = All;
                }
                field(TableType; Rec."TableType")
                {
                    ApplicationArea = All;
                }
                field(ObsoleteState; Rec.ObsoleteState)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}