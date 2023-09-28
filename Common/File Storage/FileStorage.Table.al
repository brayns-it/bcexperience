#if W1XX005A
table 60011 "YNS File Storage"
{
    DataClassification = CustomerContent;
    Caption = 'File Storage';

    fields
    {
        field(1; "Path"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Path';
        }
        field(5; Type; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
            OptionMembers = File,Folder;
            OptionCaption = 'File,Folder';
        }
        field(10; "Depth"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Depth';
        }
        field(20; "Content"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Content';
        }
        field(21; "Content Type"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Content Type';
        }
        field(22; "Size"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Size';
        }
        field(23; "Created Date/Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Create Date/Time';
        }
        field(24; "Modified Date/Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Modified Date/Time';
        }
        field(25; "Created by User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Created by User ID';
        }
    }

    keys
    {
        key(PK; Path)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        "Created Date/Time" := CurrentDateTime;
        "Created by User ID" := CopyStr(UserId, 1, MaxStrLen("Created by User ID"));
        "Modified Date/Time" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        "Modified Date/Time" := CurrentDateTime;
    end;

}
#endif