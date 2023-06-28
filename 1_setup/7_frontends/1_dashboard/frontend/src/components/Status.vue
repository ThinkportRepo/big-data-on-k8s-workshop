<template>
  <v-container>
    <v-row>
      <v-col cols="mb-12">
        <div class="text-h3">Kubernetes Cluster Status</div>
      </v-col>
    </v-row>
    <v-row>
      <v-col>
        <v-progress-linear
          v-if="serverOutputStatus"
          indeterminate
          color="deep-orange"
          height="25"
          >connecting to Kubernetes Cluster ...</v-progress-linear
        >
        <v-expansion-panels multiple>
          <v-expansion-panel>
            <v-expansion-panel-header disable-icon-rotate>
              <span class="text-h6">Frontends</span>
              <template v-slot:actions>
                <v-icon :color="appStatusColor(serverOutput.frontend.status)">
                  {{ appStatusIcon(serverOutput.frontend.status) }}
                </v-icon>
              </template>
            </v-expansion-panel-header>
            <v-expansion-panel-content>
              <v-simple-table>
                <template v-slot:default>
                  <thead>
                    <tr>
                      <th class="text-left">Resource</th>
                      <th class="text-left">Pod</th>
                      <th class="text-left">Namespace</th>
                      <th class="text-left">Restarts</th>
                      <th class="text-left">Status</th>
                      <th class="text-left"></th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>Dashboard</td>
                      <td>{{ serverOutput.frontend.dashboard.pod }}</td>
                      <td>frontend</td>
                      <td>{{ serverOutput.frontend.dashboard.restarts }}</td>
                      <td>{{ serverOutput.frontend.dashboard.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(
                              serverOutput.frontend.dashboard.status
                            )
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.frontend.dashboard.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Terminal</td>
                      <td>{{ serverOutput.frontend.terminal.pod }}</td>
                      <td>frontend</td>
                      <td>{{ serverOutput.frontend.terminal.restarts }}</td>
                      <td>{{ serverOutput.frontend.terminal.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(
                              serverOutput.frontend.terminal.status
                            )
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.frontend.terminal.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>VSCode</td>
                      <td>{{ serverOutput.frontend.vscode.pod }}</td>
                      <td>frontend</td>
                      <td>{{ serverOutput.frontend.vscode.restarts }}</td>
                      <td>{{ serverOutput.frontend.vscode.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(serverOutput.frontend.vscode.status)
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.frontend.vscode.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Jupyter</td>
                      <td>{{ serverOutput.frontend.jupyter.pod }}</td>
                      <td>frontend</td>
                      <td>{{ serverOutput.frontend.jupyter.restarts }}</td>
                      <td>{{ serverOutput.frontend.jupyter.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(serverOutput.frontend.jupyter.status)
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.frontend.jupyter.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <!--
                    <tr>
                      <td>Zeppelin</td>
                      <td>{{ serverOutput.frontend.zeppelin.pod }}</td>
                      <td>frontend</td>
                      <td>{{ serverOutput.frontend.zeppelin.restarts }}</td>
                      <td>{{ serverOutput.frontend.zeppelin.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(
                              serverOutput.frontend.zeppelin.status
                            )
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.frontend.zeppelin.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    -->
                    <tr>
                      <td>SQLPad</td>
                      <td>{{ serverOutput.frontend.sqlpad.pod }}</td>
                      <td>frontend</td>
                      <td>{{ serverOutput.frontend.sqlpad.restarts }}</td>
                      <td>{{ serverOutput.frontend.sqlpad.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(serverOutput.frontend.sqlpad.status)
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.frontend.sqlpad.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Metabase</td>
                      <td>{{ serverOutput.frontend.metabase.pod }}</td>
                      <td>frontend</td>
                      <td>{{ serverOutput.frontend.metabase.restarts }}</td>
                      <td>{{ serverOutput.frontend.metabase.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(
                              serverOutput.frontend.metabase.status
                            )
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.frontend.metabase.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Minio UI</td>
                      <td>{{ serverOutput.minio.minio1.pod }}</td>
                      <td>minio</td>
                      <td>{{ serverOutput.minio.minio1.restarts }}</td>
                      <td>{{ serverOutput.minio.minio1.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(serverOutput.minio.minio1.status)
                          ">
                          {{
                            appStatusIconTable(serverOutput.minio.minio1.status)
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Trino UI</td>
                      <td>{{ serverOutput.trino.coordinator.pod }}</td>
                      <td>trino</td>
                      <td>{{ serverOutput.trino.coordinator.restarts }}</td>
                      <td>{{ serverOutput.trino.coordinator.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(
                              serverOutput.trino.coordinator.status
                            )
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.trino.coordinator.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Spark UI</td>
                      <td>{{ serverOutput.spark.history.pod }}</td>
                      <td>spark</td>
                      <td>{{ serverOutput.spark.history.restarts }}</td>
                      <td>{{ serverOutput.spark.history.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(serverOutput.spark.history.status)
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.spark.history.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Kubernetes UI</td>
                      <td>{{ serverOutput.frontend.headlamp.pod }}</td>
                      <td>spark</td>
                      <td>{{ serverOutput.frontend.headlamp.restarts }}</td>
                      <td>{{ serverOutput.frontend.headlamp.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(
                              serverOutput.frontend.headlamp.status
                            )
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.frontend.headlamp.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                  </tbody>
                </template>
              </v-simple-table>
            </v-expansion-panel-content>
          </v-expansion-panel>
          <v-expansion-panel>
            <v-expansion-panel-header disable-icon-rotate>
              <span class="text-h6">S3 Minio</span>
              <template v-slot:actions>
                <v-icon :color="appStatusColor(serverOutput.minio.status)">
                  {{ appStatusIcon(serverOutput.minio.status) }}
                </v-icon>
              </template>
            </v-expansion-panel-header>
            <v-expansion-panel-content>
              <v-simple-table>
                <template v-slot:default>
                  <thead>
                    <tr>
                      <th class="text-left">Resource</th>
                      <th class="text-left">Pod</th>
                      <th class="text-left">Namespace</th>
                      <th class="text-left">Restarts</th>
                      <th class="text-left">Status</th>
                      <th class="text-left"></th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>Minio 1</td>
                      <td>{{ serverOutput.minio.minio1.pod }}</td>
                      <td>minio</td>
                      <td>{{ serverOutput.minio.minio1.restarts }}</td>
                      <td>{{ serverOutput.minio.minio1.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(serverOutput.minio.minio1.status)
                          ">
                          {{
                            appStatusIconTable(serverOutput.minio.minio1.status)
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Minio 2</td>
                      <td>{{ serverOutput.minio.minio2.pod }}</td>
                      <td>minio</td>
                      <td>{{ serverOutput.minio.minio2.restarts }}</td>
                      <td>{{ serverOutput.minio.minio2.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(serverOutput.minio.minio2.status)
                          ">
                          {{
                            appStatusIconTable(serverOutput.minio.minio2.status)
                          }}
                        </v-icon>
                      </td>
                    </tr>
                  </tbody>
                </template>
              </v-simple-table>
            </v-expansion-panel-content>
          </v-expansion-panel>

          <v-expansion-panel>
            <v-expansion-panel-header disable-icon-rotate>
              <span class="text-h6">Kafka</span>
              <template v-slot:actions>
                <v-icon :color="appStatusColor(serverOutput.kafka.status)">
                  {{ appStatusIcon(serverOutput.kafka.status) }}
                </v-icon>
              </template>
            </v-expansion-panel-header>
            <v-expansion-panel-content>
              <v-simple-table>
                <template v-slot:default>
                  <thead>
                    <tr>
                      <th class="text-left">Resource</th>
                      <th class="text-left">Pod</th>
                      <th class="text-left">Namespace</th>
                      <th class="text-left">Restarts</th>
                      <th class="text-left">Status</th>
                      <th class="text-left"></th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>Broker 1</td>
                      <td>{{ serverOutput.kafka.broker0.pod }}</td>
                      <td>kafka</td>
                      <td>{{ serverOutput.kafka.broker0.restarts }}</td>
                      <td>{{ serverOutput.kafka.broker0.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(serverOutput.kafka.broker0.status)
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.kafka.broker0.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Broker 2</td>
                      <td>{{ serverOutput.kafka.broker1.pod }}</td>
                      <td>kafka</td>
                      <td>{{ serverOutput.kafka.broker1.restarts }}</td>
                      <td>{{ serverOutput.kafka.broker1.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(serverOutput.kafka.broker1.status)
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.kafka.broker1.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Broker 3</td>
                      <td>{{ serverOutput.kafka.broker2.pod }}</td>
                      <td>kafka</td>
                      <td>{{ serverOutput.kafka.broker2.restarts }}</td>
                      <td>{{ serverOutput.kafka.broker2.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(serverOutput.kafka.broker2.status)
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.kafka.broker2.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Zookeeper</td>
                      <td>{{ serverOutput.kafka.zookeeper.pod }}</td>
                      <td>kafka</td>
                      <td>{{ serverOutput.kafka.zookeeper.restarts }}</td>
                      <td>{{ serverOutput.kafka.zookeeper.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(serverOutput.kafka.zookeeper.status)
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.kafka.zookeeper.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Schema Registry</td>
                      <td>{{ serverOutput.kafka.schemaRegistry.pod }}</td>
                      <td>kafka</td>
                      <td>{{ serverOutput.kafka.schemaRegistry.restarts }}</td>
                      <td>{{ serverOutput.kafka.schemaRegistry.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(
                              serverOutput.kafka.schemaRegistry.status
                            )
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.kafka.schemaRegistry.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>KSQL Server</td>
                      <td>{{ serverOutput.kafka.ksqlServer.pod }}</td>
                      <td>kafka</td>
                      <td>{{ serverOutput.kafka.ksqlServer.restarts }}</td>
                      <td>{{ serverOutput.kafka.ksqlServer.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(serverOutput.kafka.ksqlServer.status)
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.kafka.ksqlServer.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Kafka Connect</td>
                      <td>{{ serverOutput.kafka.kafkaConnect.pod }}</td>
                      <td>kafka</td>
                      <td>{{ serverOutput.kafka.kafkaConnect.restarts }}</td>
                      <td>{{ serverOutput.kafka.kafkaConnect.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(
                              serverOutput.kafka.kafkaConnect.status
                            )
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.kafka.kafkaConnect.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                  </tbody>
                </template>
              </v-simple-table>
            </v-expansion-panel-content>
          </v-expansion-panel>

          <v-expansion-panel>
            <v-expansion-panel-header disable-icon-rotate>
              <span class="text-h6">Spark</span>
              <template v-slot:actions>
                <v-icon :color="appStatusColor(serverOutput.spark.status)">
                  {{ appStatusIcon(serverOutput.spark.status) }}
                </v-icon>
              </template>
            </v-expansion-panel-header>
            <v-expansion-panel-content>
              <v-simple-table>
                <template v-slot:default>
                  <thead>
                    <tr>
                      <th class="text-left">Resource</th>
                      <th class="text-left">Pod</th>
                      <th class="text-left">Namespace</th>
                      <th class="text-left">Restarts</th>
                      <th class="text-left">Status</th>
                      <th class="text-left"></th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>Spark Operator</td>
                      <td>{{ serverOutput.spark.operator.pod }}</td>
                      <td>spark</td>
                      <td>{{ serverOutput.spark.operator.restarts }}</td>
                      <td>{{ serverOutput.spark.operator.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(serverOutput.spark.operator.status)
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.spark.operator.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>History Server</td>
                      <td>{{ serverOutput.spark.history.pod }}</td>
                      <td>spark</td>
                      <td>{{ serverOutput.spark.history.restarts }}</td>
                      <td>{{ serverOutput.spark.history.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(serverOutput.spark.history.status)
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.spark.history.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                  </tbody>
                </template>
              </v-simple-table>
            </v-expansion-panel-content>
          </v-expansion-panel>

          <v-expansion-panel>
            <v-expansion-panel-header disable-icon-rotate>
              <span class="text-h6">Trino</span>
              <template v-slot:actions>
                <v-icon :color="appStatusColor(serverOutput.trino.status)">
                  {{ appStatusIcon(serverOutput.trino.status) }}
                </v-icon>
              </template>
            </v-expansion-panel-header>
            <v-expansion-panel-content>
              <v-simple-table>
                <template v-slot:default>
                  <thead>
                    <tr>
                      <th class="text-left">Resource</th>
                      <th class="text-left">Pod</th>
                      <th class="text-left">Namespace</th>
                      <th class="text-left">Restarts</th>
                      <th class="text-left">Status</th>
                      <th class="text-right"></th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>Trino Coordinator</td>
                      <td>{{ serverOutput.trino.coordinator.pod }}</td>
                      <td>trino</td>
                      <td>{{ serverOutput.trino.coordinator.restarts }}</td>
                      <td>{{ serverOutput.trino.coordinator.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(
                              serverOutput.trino.coordinator.status
                            )
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.trino.coordinator.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Trino Worker 1</td>
                      <td>{{ serverOutput.trino.worker1.pod }}</td>
                      <td>trino</td>
                      <td>{{ serverOutput.trino.worker1.restarts }}</td>
                      <td>{{ serverOutput.trino.worker1.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(serverOutput.trino.worker1.status)
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.trino.worker1.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Trino Worker 2</td>
                      <td>{{ serverOutput.trino.worker2.pod }}</td>
                      <td>trino</td>
                      <td>{{ serverOutput.trino.worker2.restarts }}</td>
                      <td>{{ serverOutput.trino.worker2.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(serverOutput.trino.worker2.status)
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.trino.worker2.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Hive Metastore</td>
                      <td>{{ serverOutput.trino.hive.pod }}</td>
                      <td>hive</td>
                      <td>{{ serverOutput.trino.hive.restarts }}</td>
                      <td>{{ serverOutput.trino.hive.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(serverOutput.trino.hive.status)
                          ">
                          {{
                            appStatusIconTable(serverOutput.trino.hive.status)
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Hive Postgres</td>
                      <td>{{ serverOutput.trino.postgres.pod }}</td>
                      <td>hive</td>
                      <td>{{ serverOutput.trino.postgres.restarts }}</td>
                      <td>{{ serverOutput.trino.postgres.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(serverOutput.trino.postgres.status)
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.trino.postgres.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                  </tbody>
                </template>
              </v-simple-table>
            </v-expansion-panel-content>
          </v-expansion-panel>
          <v-expansion-panel>
            <v-expansion-panel-header disable-icon-rotate>
              <span class="text-h6">Monitoring</span>
              <template v-slot:actions>
                <v-icon :color="appStatusColor(serverOutput.monitoring.status)">
                  {{ appStatusIcon(serverOutput.monitoring.status) }}
                </v-icon>
              </template>
            </v-expansion-panel-header>
            <v-expansion-panel-content>
              <v-simple-table>
                <template v-slot:default>
                  <thead>
                    <tr>
                      <th class="text-left">Resource</th>
                      <th class="text-left">Pod</th>
                      <th class="text-left">Namespace</th>
                      <th class="text-left">Restarts</th>
                      <th class="text-left">Status</th>
                      <th class="text-right"></th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>Prometheus Operator</td>
                      <td>{{ serverOutput.monitoring.operator.pod }}</td>
                      <td>monitoring</td>
                      <td>{{ serverOutput.monitoring.operator.restarts }}</td>
                      <td>{{ serverOutput.monitoring.operator.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(
                              serverOutput.monitoring.operator.status
                            )
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.monitoring.operator.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Prometheus</td>
                      <td>{{ serverOutput.monitoring.prometheus.pod }}</td>
                      <td>monitoring</td>
                      <td>{{ serverOutput.monitoring.prometheus.restarts }}</td>
                      <td>{{ serverOutput.monitoring.prometheus.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(
                              serverOutput.monitoring.prometheus.status
                            )
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.monitoring.prometheus.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Metrics Server</td>
                      <td>{{ serverOutput.monitoring.metrics.pod }}</td>
                      <td>monitoring</td>
                      <td>{{ serverOutput.monitoring.metrics.restarts }}</td>
                      <td>{{ serverOutput.monitoring.metrics.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(
                              serverOutput.monitoring.metrics.status
                            )
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.monitoring.metrics.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Alert Manager</td>
                      <td>{{ serverOutput.monitoring.alertmanager.pod }}</td>
                      <td>monitoring</td>
                      <td>
                        {{ serverOutput.monitoring.alertmanager.restarts }}
                      </td>
                      <td>{{ serverOutput.monitoring.alertmanager.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(
                              serverOutput.monitoring.alertmanager.status
                            )
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.monitoring.alertmanager.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Grafana</td>
                      <td>{{ serverOutput.monitoring.grafana.pod }}</td>
                      <td>monitoring</td>
                      <td>{{ serverOutput.monitoring.grafana.restarts }}</td>
                      <td>{{ serverOutput.monitoring.grafana.status }}</td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(
                              serverOutput.monitoring.grafana.status
                            )
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.monitoring.grafana.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Node Exporter 1</td>
                      <td>{{ serverOutput.monitoring.nodeexporter1.pod }}</td>
                      <td>monitoring</td>
                      <td>
                        {{ serverOutput.monitoring.nodeexporter1.restarts }}
                      </td>
                      <td>
                        {{ serverOutput.monitoring.nodeexporter1.status }}
                      </td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(
                              serverOutput.monitoring.nodeexporter1.status
                            )
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.monitoring.nodeexporter1.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Node Exporter 2</td>
                      <td>{{ serverOutput.monitoring.nodeexporter2.pod }}</td>
                      <td>monitoring</td>
                      <td>
                        {{ serverOutput.monitoring.nodeexporter2.restarts }}
                      </td>
                      <td>
                        {{ serverOutput.monitoring.nodeexporter2.status }}
                      </td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(
                              serverOutput.monitoring.nodeexporter2.status
                            )
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.monitoring.nodeexporter2.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                    <tr>
                      <td>Node Exporter 3</td>
                      <td>{{ serverOutput.monitoring.nodeexporter3.pod }}</td>
                      <td>monitoring</td>
                      <td>
                        {{ serverOutput.monitoring.nodeexporter3.restarts }}
                      </td>
                      <td>
                        {{ serverOutput.monitoring.nodeexporter3.status }}
                      </td>
                      <td class="text-right">
                        <v-icon
                          :color="
                            appStatusColor(
                              serverOutput.monitoring.nodeexporter3.status
                            )
                          ">
                          {{
                            appStatusIconTable(
                              serverOutput.monitoring.nodeexporter3.status
                            )
                          }}
                        </v-icon>
                      </td>
                    </tr>
                  </tbody>
                </template>
              </v-simple-table>
            </v-expansion-panel-content>
          </v-expansion-panel>
        </v-expansion-panels>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import * as socketio from "@/plugins/socketio";

export default {
  name: "Status",

  data: () => ({
    host: "VUE_APP_K8S_HOST",
    serverOutput: "",
    serverOutputStatus: true,
  }),
  mounted() {
    socketio.addEventListener({
      type: "cluster",
      callback: (message) => {
        this.serverOutput = message;
        this.serverOutputStatus = false;
      },
    });
  },
  methods: {
    appStatusColor(status) {
      if (status == "Running") {
        return "green";
      } else {
        return "red";
      }
    },

    appStatusIcon(status) {
      if (status == "Running") {
        return "mdi-check-circle";
      } else {
        return "mdi-alert-circle";
      }
    },
    appStatusIconTable(status) {
      if (status == "Running") {
        return "mdi-check";
      } else {
        return "mdi-exclamation";
      }
    },
  },
};
</script>
