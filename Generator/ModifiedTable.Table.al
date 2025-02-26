table 99999 "Modified Table"
{
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1;"Table No."; Integer)
        {
            TableRelation = "Table Metadata".ID;

            trigger OnValidate()
            var
                TableMetadata: Record "Table Metadata";
            begin
                if Rec."Table No." = xRec."Table No." then
                    exit;

                TableMetadata.Get(Rec."Table No.");
                Rec."Table Name" := TableMetadata.Name;
                Rec.DataPerCompany := TableMetadata.DataPerCompany;
                Rec."TableType" := TableMetadata.TableType;
                Rec.ObsoleteState := TableMetadata.ObsoleteState;
                Rec.Modify();
            end;
        }
        field(2; "Table Name"; Text[30])
        {
        }
        field(3; DataPerCompany; Boolean)
        {
        }
        field(4; TableType; Option)
        {
            OptionMembers = Normal,CRM,ExternalSQL,Exchange,MicrosoftGraph;
        }
        field(5; ObsoleteState; Option)
        {
            OptionMembers = No,Pending,Removed;
        }
    }

    keys
    {
        key(PK; "Table No.")
        {
            Clustered = true;
        }
    }
}