# Fix: CLM Job Failing on Java 21 Agents

## Summary

The `cps-ncmp-dmi-plugin-maven-clm-master` job (build #285) fails after the Maven build succeeds. The Nexus IQ policy evaluation scan crashes with a Java module system error because the Jenkins agent JVM doesn't have the required `--add-opens` flag.

## Symptoms

- Build #284 (last success): ran on **centos8-docker-8c-8g**, Java 17
- Build #285 (first failure): ran on **ubuntu2204-docker-8c-8g**, Java 21
- Maven build completes successfully (all tests pass)
- Failure occurs in the **post-build Nexus IQ scan step**

## Error

```
FATAL: Remote call on prd-ubuntu2204-docker-8c-8g-12084 failed
java.lang.reflect.InaccessibleObjectException: Unable to make field protected volatile
java.util.Properties java.util.Properties.defaults accessible: module java.base does not
"opens java.util" to unnamed module @3b950d23
```

The `nexus-jenkins-plugin` uses XStream which reflectively accesses `java.util.Properties` internals. Java 21 enforces module boundaries strictly, blocking this access.

## Root Cause

The `.cfg` files for ubuntu2204 agents use `SLAVE_JVM_OPTIONS` to set `--add-opens`, but the cloud provisioning script (`global-jjb/shell/jenkins-configure-clouds.sh` line 225) only reads **`JVM_OPTIONS`**.

So the flag is being silently ignored.

### Affected files

| File | Current (broken) | Fix |
|------|-----------------|-----|
| `jenkins-config/clouds/openstack/cattle/ubuntu2204-docker-8c-8g.cfg` | `SLAVE_JVM_OPTIONS='--add-opens java.base/java.util\=ALL-UNNAMED'` | `JVM_OPTIONS=--add-opens java.base/java.util=ALL-UNNAMED` |
| `jenkins-config/clouds/openstack/cattle/ubuntu2204-docker-4c-4g.cfg` | `SLAVE_JVM_OPTIONS='--add-opens java.base/java.util\=ALL-UNNAMED'` | `JVM_OPTIONS=--add-opens java.base/java.util=ALL-UNNAMED` |

The `ubuntu2204-docker-8c-16g.cfg` already uses the correct variable name (no quotes, no escaping).
The `ubuntu2204-docker-v1-8c-8g.cfg` uses it with double quotes which also works.

## The Fix

1. Rename `SLAVE_JVM_OPTIONS` → `JVM_OPTIONS` in the two affected `.cfg` files
2. Remove the single quotes and backslash-escaping on the `=` sign

That's it. No changes needed in the JJB job config (`jjb/cps/cps-ncmp-dmi-plugin.yaml`) — the `mvn-opts` setting there already correctly handles the Maven process side.

## Verification

After merging, wait for the cloud config to be picked up by Jenkins (or trigger a config reload), then re-run the CLM job. The Nexus IQ scan should complete without the `InaccessibleObjectException`.

## Context

- Job config: `jjb/cps/cps-ncmp-dmi-plugin.yaml` (lines 78-88)
- CLM template: `global-jjb/jjb/lf-maven-jobs.yaml` (line 130, `gerrit-maven-clm`)
- Cloud script: `global-jjb/shell/jenkins-configure-clouds.sh` (line 225 reads `JVM_OPTIONS`)
- The same issue will affect **any** project using `gerrit-maven-clm` on ubuntu2204-docker-8c-8g or 4c-4g agents with Java 21
