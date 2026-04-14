{{/*
  templates/_helpers.tpl
  Funciones reutilizables para demo-app
*/}}

{{/*
  Nombre del chart.
  Truncamos a 63 chars porque algunas etiquetas de Kubernetes tienen ese límite.
*/}}
{{- define "demo-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end}}

{{/*
  Fullname: combina release + chart.
  Si el nombre del release ya contiene el nombre del chart, evita duplicarlo.
  Ej: release "demo-app" + chart "demo-app" → "demo-app" (no "demo-app-demo-app")
*/}}
{{- define "demo-app.fullname" -}}
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
  Versión del chart para la label helm.sh/chart.
  Reemplaza "+" por "_" para compatibilidad con nombres de label.
*/}}
{{- define "demo-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Labels comunes — se incluyen en metadata.labels de todos los recursos.
  Siguen las recomendaciones de https://helm.sh/docs/chart_best_practices/labels/
*/}}
{{- define "demo-app.labels" -}}
helm.sh/chart: {{ include "demo-app.chart" . }}
{{ include "demo-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
  Selector labels — usadas en spec.selector.matchLabels y podTemplate.
  Solo estas dos: name e instance. No agregar más aquí o el selector
  puede romper en upgrades futuros.
*/}}
{{- define "demo-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "demo-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Nombre del ServiceAccount.
  - Si serviceAccount.create=true, usa el nombre configurado (o fullname como fallback).
  - Si serviceAccount.create=false, usa el nombre provisto o "default".
*/}}
{{- define "demo-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "demo-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}