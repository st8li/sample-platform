{{- define "svc.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
app.kubernetes.io/managed-by: platform-golden-path
team: {{ .Values.team }}
{{- end }}
{{- define "svc.selector" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
{{- end }}
