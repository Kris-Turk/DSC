
Configuration SetTimeZoneGMT
{
    Import-DSCResource -ModuleName ComputerManagementDsc
    Node ('localhost')    
    {
        TimeZone TimeZoneExample
        {
            IsSingleInstance = 'Yes'
            TimeZone         = 'GMT Standard Time'
        }
    }
}