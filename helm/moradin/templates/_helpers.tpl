{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "app.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{/* Generate basic labels */}}
{{- define "common.labels" }}
app: {{ template "app.name" . }}
release: {{ .Release.Name }}
team: ror
slack: talk-ror
type: cronjob
namespace: {{ .Release.Namespace }}
{{- end }}


{{- range $name, $config := .Values.slackUrlSecret -}}
{{ if typeOf $config | eq "string" }}
{{ $name }}: |
{{- tpl $config $ | nindent 12 }}
{{ end }}
{{ end }}