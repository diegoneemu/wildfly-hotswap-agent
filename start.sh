#!/bin/bash

$WILDFLY_HOME/bin/add-user.sh -u $MNGMT_USER -p $MNGMT_PASSWORD -s -e

$WILDFLY_HOME/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0

$WILDFLY_HOME/bin/jboss-cli.sh --connect --commands=/subsystem=deployment-scanner/scanner=default:write-attribute\(name=\"scan-enabled\",value=true\)
$WILDFLY_HOME/bin/jboss-cli.sh --connect --commands=/subsystem=deployment-scanner/scanner=default:write-attribute\(name=\"scan-interval\",value=2000\)
$WILDFLY_HOME/bin/jboss-cli.sh --connect --commands=/subsystem=deployment-scanner/scanner=default:write-attribute\(name=\"auto-deploy-exploded\",value=false\)