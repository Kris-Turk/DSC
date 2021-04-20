
Configuration SetTimeZone
{
    Import-DSCResource -Name TimeZone
    Node ('localhost')
    {
        TimeZone TimeZoneExample
        {
            TimeZone         = 'GMT Standard Time'
        }
    }
}