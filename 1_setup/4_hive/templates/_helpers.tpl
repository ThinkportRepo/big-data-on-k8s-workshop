{{/*
Expand the name of the chart.
*/}}
{{- define "hive-metastore.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hive-metastore.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "hive-metastore.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "hive-metastore.labels" -}}
helm.sh/chart: {{ include "hive-metastore.chart" . }}
{{ include "hive-metastore.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "hive-metastore.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hive-metastore.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "hive-metastore.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hive-metastore.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Returns the available value for certain key in an existing secret (if it exists)
*/}}
{{- define "hive-metastore.getValueFromSecret" }}
{{- $obj := (lookup "v1" "Secret" .Namespace .Name).data -}}
{{- if $obj }}
{{- index $obj .Key | b64dec -}}
{{- end -}}
{{- end -}}

{{- define "hive-metastore.postgres.database" -}}
{{- if eq .Values.deployPostgresql.enabled true }}
{{- template "postgresql.database" (dict "Values" $.Values.postgresql "Chart" (dict "Name" "postgresql") "Release" $.Release) -}}
{{- else -}}
{{- if .Values.postgresql.postgresqlDatabase -}}
{{ .Values.postgresql.postgresqlDatabase }}
{{- else -}}
{{- "postgres" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "hive-metastore.postgres.username" -}}
{{- if eq .Values.deployPostgresql.enabled true }}
{{- template "postgresql.username" (dict "Values" $.Values.postgresql "Chart" (dict "Name" "postgresql") "Release" $.Release) -}}
{{- else -}}
{{- .Values.postgresql.postgresqlUsername -}}
{{- end -}}
{{- end -}}

{{- define "hive-metastore.postgres.endpoint" -}}
{{- if eq .Values.deployPostgresql.enabled true }}
{{- printf "%s.%s.svc.%s:%s" (include "common.names.fullname" (dict "Values" $.Values.postgresql "Chart" (dict "Name" "postgresql") "Release" $.Release)) .Release.Namespace .Values.clusterDomain (include "postgresql.servicePort" (dict "Values" $.Values.postgresql "Chart" (dict "Name" "postgresql") "Release" $.Release)) -}}
{{- else -}}
{{- .Values.postgresql.existingInstance -}}
{{- end -}}
{{- end -}}

{{/*
Create the S3 configuration for hive-metastore.
*/}}

{{- define "hive-metastore.s3config.secretNamespace" -}}
{{- if .Values.s3.existingSecretNamespace }}
{{- .Values.s3.existingSecretNamespace -}}
{{- else -}}
{{- .Release.Namespace -}}
{{- end -}}
{{- end -}}

{{- define "hive-metastore.s3config.accessKey" -}}
{{- if .Values.s3.existingSecret }}
{{- if .Values.s3.secretKeyNames.accessKey -}}
{{- include "hive-metastore.getValueFromSecret" (dict "Namespace" (include "hive-metastore.s3config.secretNamespace" . ) "Name" .Values.s3.existingSecret "Key" .Values.s3.secretKeyNames.accessKey)  -}}
{{- else -}}
{{- .Values.s3.accessKey -}}
{{- end -}}
{{- else -}}
{{- .Values.s3.accessKey -}}
{{- end -}}
{{- end -}}

{{- define "hive-metastore.s3config.secretKey" -}}
{{- if .Values.s3.existingSecret }}
{{- if .Values.s3.secretKeyNames.secretKey -}}
{{- include "hive-metastore.getValueFromSecret" (dict "Namespace" (include "hive-metastore.s3config.secretNamespace" . )  "Name" .Values.s3.existingSecret "Key" .Values.s3.secretKeyNames.secretKey)  -}}
{{- else -}}
{{- .Values.s3.secretKey -}}
{{- end -}}
{{- else -}}
{{- .Values.s3.secretKey -}}
{{- end -}}
{{- end -}}

{{- define "hive-metastore.s3config.endpoint" -}}
{{- if .Values.s3.existingSecret }}
{{- if .Values.s3.endpointNames.endpoint -}}
{{- include "hive-metastore.getValueFromSecret" (dict "Namespace" (include "hive-metastore.s3config.secretNamespace" . )  "Name" .Values.s3.existingSecret "Key" .Values.s3.endpointNames.endpoint)  -}}
{{- else -}}
{{- .Values.s3.endpoint -}}
{{- end -}}
{{- else -}}
{{- .Values.s3.endpoint -}}
{{- end -}}
{{- end -}}
