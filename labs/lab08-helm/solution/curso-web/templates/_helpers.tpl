{{/*
Nombre base del chart
*/}}
{{- define "curso-web.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Etiquetas comunes
*/}}
{{- define "curso-web.labels" -}}
app.kubernetes.io/name: {{ include "curso-web.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: curso-k8s
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end -}}

{{/*
Etiquetas selector (estables entre versiones)
*/}}
{{- define "curso-web.selectorLabels" -}}
app.kubernetes.io/name: {{ include "curso-web.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Nombre completo de un componente, p.ej. {{ include "curso-web.fullname" . }}-web
*/}}
{{- define "curso-web.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "curso-web.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
