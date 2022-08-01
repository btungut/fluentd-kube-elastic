{{- define "fluentd-kube-elastic.podSelectorLabels" -}}
{{ include "fluentd-kube-elastic.selectorLabels" . }}
{{- end }}

{{- define "fluentd-kube-elastic.podAnnotations" -}}
checksum/confd: {{ include (print $.Template.BasePath "/confd-cm.yaml") . | sha256sum }}
checksum/es: {{ include (print $.Template.BasePath "/elasticsearch-secret.yaml") . | sha256sum }}
checksum/files: {{ include (print $.Template.BasePath "/files-cm.yaml") . | sha256sum }}
checksum/fluentd: {{ include (print $.Template.BasePath "/fluentd-cm.yaml") . | sha256sum }}
{{- end }}

{{- define "fluentd-kube-elastic.podSpec" -}}
{{- with .Values.image.pullSecrets }}
imagePullSecrets:
  {{- toYaml . | nindent 8 }}
{{- end }}
serviceAccountName: {{ include "fluentd-kube-elastic.serviceAccountName" . }}
securityContext:
  {{- toYaml .Values.podSecurityContext | nindent 8 }}
{{- with .Values.terminationGracePeriodSeconds }}
terminationGracePeriodSeconds: {{ . }}
{{- end }}
containers:
  - name: fluentd
    securityContext:
      {{- toYaml .Values.securityContext | nindent 12 }}
    image: "{{ .Values.image.repository }}:{{ .Values.image.tag  }}"
    imagePullPolicy: {{ .Values.image.pullPolicy | default "IfNotPresent" }}
    {{- with .Values.env }}
    env:
      {{- range $k,$v := . }}
      - name: {{$k}}
        value: {{ tpl $v $ | quote }}
      {{- end}}
    {{- end }}
    envFrom:
    {{- with .Values.envFrom }}
      {{- toYaml .Values.envFrom | nindent 6 }}
    {{- end }}
      - secretRef: 
          name: {{ (.Values.conf.elasticsearch.passwordSecret) | default (include "fluentd-kube-elastic.elasticsearch-secret" .) }}
          optional: false
    ports:
      - name: metrics
        containerPort: 24231
        protocol: TCP
      {{- range $port := .Values.service.ports }}
      - name: {{ $port.name }}
        containerPort: {{ $port.containerPort }}
        protocol: {{ $port.protocol }}
      {{- end }}
    {{- with .Values.lifecycle }}
    lifecycle:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    startupProbe:
      httpGet:
        path: /metrics
        port: metrics
      initialDelaySeconds: 5
      periodSeconds: 5
      timeoutSeconds: 3
      failureThreshold: 10
    livenessProbe:
      httpGet:
        path: /metrics
        port: metrics
      periodSeconds: 30
      timeoutSeconds: 5
      failureThreshold: 3
    readinessProbe:
      httpGet:
        path: /metrics
        port: metrics
      periodSeconds: 30
      timeoutSeconds: 5
      failureThreshold: 3
    volumeMounts:
      - name: fluentd-cm
        mountPath: "/fluentd/etc"
      - name: conf-cm
        mountPath: "/fluentd/etc/config.d"
      - name: files-cm
        mountPath: "/fluentd/etc/files"
      - name: varlog
        mountPath: /var/log
      - name: varlibdockercontainers
        mountPath: /var/lib/docker/containers
      {{- if .Values.conf.elasticsearch.tlsSecret }}
      - name: certs
        mountPath: "/fluentd/etc/certs"
      {{- end }}
    resources:
      {{- toYaml .Values.resources | nindent 12 }}
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 8 }}
{{- end }}
{{- with .Values.affinity }}
affinity:
  {{- toYaml . | nindent 8 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
  {{- toYaml . | nindent 8 }}
{{- end }}
volumes:
  - name: fluentd-cm
    configMap:
      name: {{ include "fluentd-kube-elastic.fluentd-cm" . }}
  - name: conf-cm
    configMap:
      name: {{ include "fluentd-kube-elastic.conf-cm" . }}
  - name: files-cm
    configMap:
      name: {{ include "fluentd-kube-elastic.files-cm" . }}
  {{- if .Values.conf.elasticsearch.tlsSecret }}
  - name: certs
    secret:
      secretName: {{ .Values.conf.elasticsearch.tlsSecret }}
      optional: false
  {{- end }}
  - name: varlog
    hostPath:
      path: /var/log
  - name: varlibdockercontainers
    hostPath:
      path: /var/lib/docker/containers
{{- end }}
