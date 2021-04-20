
Configuration SetTimeZone
{
    Import-DSCResource -Name xTimeZone
    Node ('localhost')
    {
        xTimeZone TimeZoneExample
        {
            TimeZone         = 'GMT Standard Time'
        }
    }
}