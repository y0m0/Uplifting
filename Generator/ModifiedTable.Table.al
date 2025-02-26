table 99999 "Modified Table"
{
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1;"Table No."; Integer)
        {
            TableRelation = "Table Metadata".ID;
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