{{- define "pgdsm.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "pgdsm.componentLabels" -}}
{{ include "pgdsm.labels" .root }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{- define "pgdsm.componentName" -}}
{{- printf "%s-%s" .Release.Name .component | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "pgdsm.monitoringNamespace" -}}
{{- .Values.namespaces.monitoring -}}
{{- end }}

{{- define "pgdsm.loadtestNamespace" -}}
{{- .Values.namespaces.loadtest -}}
{{- end }}

{{- define "pgdsm.loadtestEnabled" -}}
{{- if or .Values.loadtest.runner.enabled .Values.jobs.init.enabled .Values.jobs.smoke.enabled .Values.jobs.baselineRw.enabled .Values.jobs.baselineRo.enabled .Values.jobs.ramp.enabled .Values.jobs.dataSweep10m.enabled .Values.jobs.dataSweep20m.enabled .Values.jobs.stress.enabled .Values.jobs.haObservation.enabled .Values.jobs.soak.enabled -}}true{{- else -}}false{{- end -}}
{{- end }}

{{- define "pgdsm.pushgatewayUrl" -}}
http://{{ include "pgdsm.componentName" (dict "Release" .Release "component" "pushgateway") }}.{{ include "pgdsm.monitoringNamespace" . }}.svc.cluster.local:{{ .Values.pushgateway.service.port }}
{{- end }}

{{- define "pgdsm.renderPgbenchJob" -}}
{{- $root := .root -}}
{{- $job := .job -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "pgdsm.componentName" (dict "Release" $root.Release "component" $job.component) }}
  namespace: {{ include "pgdsm.loadtestNamespace" $root }}
  labels:
    {{- include "pgdsm.componentLabels" (dict "root" $root "component" "loadtest-job") | nindent 4 }}
    pgdsm.scenario: {{ $job.scenario | quote }}
spec:
  backoffLimit: 0
  ttlSecondsAfterFinished: {{ $job.ttl }}
  template:
    metadata:
      labels:
        {{- include "pgdsm.componentLabels" (dict "root" $root "component" "loadtest-job") | nindent 8 }}
        pgdsm.scenario: {{ $job.scenario | quote }}
    spec:
      restartPolicy: Never
      containers:
        - name: {{ $job.containerName }}
          image: {{ $root.Values.images.pgbench }}
          imagePullPolicy: IfNotPresent
          command:
            - /bin/sh
            - {{ $job.script | quote }}
          envFrom:
            - secretRef:
                name: {{ include "pgdsm.componentName" (dict "Release" $root.Release "component" "pgbench-connection") }}
          env:
            - name: PGBENCH_PROFILE
              value: {{ $root.Values.testProfile | quote }}
            - name: PGBENCH_SCENARIO
              value: {{ $job.scenario | quote }}
            - name: PGBENCH_MODE
              value: {{ $job.mode | quote }}
            - name: PGBENCH_METRICS_DIR
              value: /shared
            {{- range $env := $job.env }}
            - name: {{ $env.name }}
              value: {{ $env.value | quote }}
            {{- end }}
          resources:
            {{- toYaml $root.Values.loadtest.runner.resources | nindent 12 }}
          volumeMounts:
            - name: scripts
              mountPath: /scripts
            - name: shared
              mountPath: /shared
        {{- if $root.Values.pushgateway.enabled }}
        - name: metrics-pusher
          image: {{ $root.Values.images.metricsPusher }}
          imagePullPolicy: IfNotPresent
          command:
            - /bin/sh
            - /scripts/pushgateway-sidecar.sh
          envFrom:
            - secretRef:
                name: {{ include "pgdsm.componentName" (dict "Release" $root.Release "component" "pgbench-connection") }}
          env:
            - name: PGBENCH_PROFILE
              value: {{ $root.Values.testProfile | quote }}
            - name: PGBENCH_SCENARIO
              value: {{ $job.scenario | quote }}
            - name: PGBENCH_METRICS_DIR
              value: /shared
            - name: PGBENCH_PUSHGATEWAY_URL
              value: {{ include "pgdsm.pushgatewayUrl" $root | quote }}
          resources:
            {{- toYaml $root.Values.pushgateway.pusher.resources | nindent 12 }}
          volumeMounts:
            - name: scripts
              mountPath: /scripts
            - name: shared
              mountPath: /shared
        {{- end }}
      volumes:
        - name: scripts
          configMap:
            name: {{ include "pgdsm.componentName" (dict "Release" $root.Release "component" "pgbench-scripts") }}
            defaultMode: 493
        - name: shared
          emptyDir: {}
{{- end }}
