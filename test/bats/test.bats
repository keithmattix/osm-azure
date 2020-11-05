#!/usr/bin/env bats
load helpers

BATS_TESTS_DIR=test/bats/tests
WAIT_TIME=120
SLEEP_TIME=1

@test "osm pod is ready" {
    run wait_for_process $WAIT_TIME $SLEEP_TIME "kubectl wait --for=condition=Ready --timeout=60s pod -l app=osm-controller -n arc-osm-system"
    assert_success
}

@test "configmap has been deployed" {
    run wait_for_process $WAIT_TIME $SLEEP_TIME "kubectl get configmap/osm-config -n arc-osm-system"
    assert_success
}

@test "mutating webhook has been deployed" {
    run wait_for_process $WAIT_TIME $SLEEP_TIME "kubectl get mutatingwebhookconfigurations.admissionregistration.k8s.io arc-osm-webhook-osm"
    assert_success
}

@test "fluentbit has been deployed" {
    run wait_for_process $WAIT_TIME $SLEEP_TIME "kubectl get pods -n arc-osm-system -l app=osm-controller -o jsonpath="{..image}" |tr -s '[[:space:]]' '\n' |sort |uniq -c | grep fluent-bit"
    assert_success
}

@test "openservicemesh.io/ignore is true in kube-system" { 
    test_label=$(kubectl get namespace kube-system -o jsonpath="{.metadata.labels.openservicemesh\.io\/ignore}")
    [[ $test_label == "true" ]]
}

@test "openservicemesh.io/ignore is true in azure-arc" { 
    test_label=$(kubectl get namespace azure-arc -o jsonpath="{.metadata.labels.openservicemesh\.io\/ignore}")
    [[ $test_label == "true" ]]
}

@test "openservicemesh.io/ignore is true in arc-osm-system" { 
    test_label=$(kubectl get namespace arc-osm-system -o jsonpath="{.metadata.labels.openservicemesh\.io\/ignore}")
    [[ $test_label == "true" ]]
}