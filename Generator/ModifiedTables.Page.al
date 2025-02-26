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
                
            }
        }
    }
}