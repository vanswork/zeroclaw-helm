{{- define "zeroclaw.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "zeroclaw.fullname" -}}
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

{{- define "zeroclaw.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "zeroclaw.labels" -}}
helm.sh/chart: {{ include "zeroclaw.chart" . }}
app.kubernetes.io/name: {{ include "zeroclaw.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "zeroclaw.selectorLabels" -}}
app.kubernetes.io/name: {{ include "zeroclaw.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "zeroclaw.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "zeroclaw.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "zeroclaw.secretName" -}}
{{- if .Values.secrets.name -}}
{{- .Values.secrets.name -}}
{{- else -}}
{{- printf "%s-secrets" (include "zeroclaw.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "zeroclaw.privateKeySecretName" -}}
{{- if .Values.githubApp.privateKeySecretName -}}
{{- .Values.githubApp.privateKeySecretName -}}
{{- else if and .Values.secrets.create .Values.secrets.data.githubAppPrivateKeyPem -}}
{{- include "zeroclaw.secretName" . -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}

{{- define "zeroclaw.pvcName" -}}
{{- if .Values.persistence.existingClaim -}}
{{- .Values.persistence.existingClaim -}}
{{- else -}}
{{- printf "%s-data" (include "zeroclaw.fullname" .) -}}
{{- end -}}
{{- end -}}
