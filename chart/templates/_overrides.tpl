# This is a helper template that defines the most overridden values for the chart!
{{- define "__byDefaultValues" -}}
removedFields:
  - time
  - logtag
  - $.kubernetes.labels.pod-template-hash
  - $.kubernetes.labels.rollouts-pod-template-hash
  - $.docker
  - $.kubernetes.container_image_id
  - $.kubernetes.pod_id
  - $.kubernetes.pod_ip
  - $.kubernetes.namespace_id
  - $.kubernetes.namespace_labels

anotherFields:
  - nonutil

someInt: 123
{{- end -}}


# This is a helper template that produces a merged list of removedFields from the default values defioned above and the values from the user's values.yaml file.
{{- define "__get_mergedRemovedFields" -}}
{{- $_def := include "__byDefaultValues" . | fromYaml }}
{{- $arr01 := $_def.removedFields }}
{{- $arr02 := .Values.conf.removedFields }}
{{- $mergedArray := list }}
{{- range $arr01 }}
  {{- $mergedArray = append $mergedArray . }}
{{- end }}
{{- range $arr02 }}
  {{- $mergedArray = append $mergedArray . }}
{{- end }}
{{- $mergedArray | join ", " }}
{{- end -}}