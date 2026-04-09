param(
  [Parameter(Mandatory = $true)]
  [string]$Target,

  [Parameter(Mandatory = $true)]
  [string]$Database,

  [string]$PushgatewayUrl = "http://127.0.0.1:9091",
  [string]$JobName = "pg_auto_failover",
  [string]$Profile = "2c4g",
  [string]$Topology = "single-zone-ha",
  [string]$State = "transition",
  [double]$StateCode = 1,
  [double]$RtoSeconds = 0,
  [double]$RpoSeconds = 0,
  [double]$ReplayLagMs = 0,
  [long]$TransitionTimestampSeconds = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
)

function Escape-LabelValue {
  param([string]$Value)
  return $Value.Replace("\", "\\").Replace('"', '\"')
}

$labels = @(
  'target="{0}"' -f (Escape-LabelValue $Target)
  'database="{0}"' -f (Escape-LabelValue $Database)
  'profile="{0}"' -f (Escape-LabelValue $Profile)
  'topology="{0}"' -f (Escape-LabelValue $Topology)
  'state="{0}"' -f (Escape-LabelValue $State)
) -join ","

$body = @"
# TYPE pg_auto_failover_state_code gauge
pg_auto_failover_state_code{$labels} $StateCode
# TYPE pg_auto_failover_last_transition_timestamp_seconds gauge
pg_auto_failover_last_transition_timestamp_seconds{$labels} $TransitionTimestampSeconds
# TYPE pg_auto_failover_rto_seconds gauge
pg_auto_failover_rto_seconds{$labels} $RtoSeconds
# TYPE pg_auto_failover_rpo_seconds gauge
pg_auto_failover_rpo_seconds{$labels} $RpoSeconds
# TYPE pg_auto_failover_replay_lag_ms gauge
pg_auto_failover_replay_lag_ms{$labels} $ReplayLagMs
"@

$jobPath = [Uri]::EscapeDataString($JobName)
$targetPath = [Uri]::EscapeDataString($Target.Replace(":", "_"))
$uri = "{0}/metrics/job/{1}/instance/{2}" -f $PushgatewayUrl.TrimEnd("/"), $jobPath, $targetPath

Invoke-RestMethod -Method Put -Uri $uri -ContentType "text/plain; version=0.0.4" -Body $body | Out-Null

Write-Host "Pushed pg_auto_failover metrics to $uri"
