#if W1XX004A
table 60013 "YNS Doc. Exchange Log"
{
    Caption = 'Document Exchange Log';
    DataClassification = CustomerContent;
    LookupPageId = "YNS Doc. Exchange Log";
    DrillDownPageId = "YNS Doc. Exchange Log";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Profile Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Profile Code';
            TableRelation = "YNS Doc. Exchange Profile";
        }
        field(3; "Activity ID"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Activity ID';
        }
        field(4; "Activity Date/Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Activity Date/Time';
        }
        field(5; "User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'User ID';
        }
        field(6; "Parameters"; Text[512])
        {
            DataClassification = CustomerContent;
            Caption = 'Parameters';
        }
        field(7; "Log Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Log Type';
            OptionCaption = 'Information,Warning,Error';
            OptionMembers = Information,Warning,Error;
        }
        field(10; "Log Message"; Text[512])
        {
            DataClassification = CustomerContent;
            Caption = 'Log Message';
        }
        field(12; "Activity Name"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Activity Name';
        }
        field(20; "Exchange Format"; Enum "YNS Doc. Exchange Format")
        {
            DataClassification = CustomerContent;
            Caption = 'Exchange Format';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(K1; "Profile Code", "Activity Date/Time") { }
        key(K2; "Activity ID") { }
    }

    var
        LastMessages: List of [Text];

    procedure HasLog(): Boolean
    var
        Log2: Record "YNS Doc. Exchange Log";
    begin
        Log2.SetRange("Activity ID", Rec."Activity ID");
        exit(not Log2.IsEmpty());
    end;

    procedure HasErrors(): Boolean
    var
        Log2: Record "YNS Doc. Exchange Log";
    begin
        Log2.SetRange("Activity ID", Rec."Activity ID");
        Log2.SetRange("Log Type", Log2."Log Type"::Error);
        exit(not Log2.IsEmpty());
    end;

    procedure AppendInformation(ActivityName: Text; Message: Text)
    begin
        Rec."Log Type" := Rec."Log Type"::Information;
        AppendLog(ActivityName, Message);
    end;

    procedure AppendWarning(ActivityName: Text; Message: Text)
    begin
        Rec."Log Type" := Rec."Log Type"::Warning;
        AppendLog(ActivityName, Message);
    end;

    procedure AppendError(ActivityName: Text; Message: Text)
    begin
        Rec."Log Type" := Rec."Log Type"::Error;
        AppendLog(ActivityName, Message);
    end;

    local procedure AppendLog(ActivityName: Text; Message: Text)
    begin
        if LastMessages.Contains(Message.ToLower()) then
            exit;

        LastMessages.Add(Message.ToLower());

        Rec."Entry No." := 0;
        rec."Activity Name" := CopyStr(ActivityName, 1, MaxStrLen(rec."Activity Name"));
        rec."Activity Date/Time" := CurrentDateTime;
        Rec."Log Message" := CopyStr(Message, 1, MaxStrLen(rec."Log Message"));
        Rec.Insert();
    end;
}
#endif