function New-UnifiSiteFirewallRule {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$RuleSet,
        [int]$RuleIndex,
        [string]$RuleName,
        [boolean]$Enabled,
        [ValidateSet('drop','reject','accept', IgnoreCase=$false)]
        [string]$Action,
        [boolean]$ProtocalMatchExcepted,
        [boolean]$Logging,
        [boolean]$StateNew,
        [boolean]$StateEstablished,
        [boolean]$StateInvalid,
        [boolean]$StateRelated,
        [string]$IpSec,
        [array]$SourceFirewallGroupIds,
        [string]$SourceMacAddress,
        [array]$DestinationFirewallGroupIds,
        [string]$DestinationAddress,
        [string]$SourceAddress,
        [string]$Protocol,
        [string]$IcmpTypeName,
        [string]$SourceNetworkConfigurationId,
        [string]$SourceNetworkConfigurationType,
        [string]$DestinationNetworkConfigurationId,
        [string]$DestinationNetworkConfigurationType
    )
    Register-ArgumentCompleter -CommandName 'New-UnifiSiteFirewallRule' -ParameterName 'ProtocalMatchExcepted' -ScriptBlock {
        [System.Management.Automation.CompletionResult]::new(
            '$False',
            '$False',
            'ParameterValue',
            '[bool] False'
        )
        [System.Management.Automation.CompletionResult]::new(
            '$True',
            '$True',
            'ParameterValue',
            '[bool] True'
        )
    }
}

New-UnifiSiteFirewallRule -ProtocalMatchExcepted