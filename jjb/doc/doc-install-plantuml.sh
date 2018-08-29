#!/bin/bash
set -x
if [ ! -d /usr/share/plantuml ]
	then
	sudo mkdir -p /usr/share/plantuml
	cd /usr/share/plantuml
	sudo wget https://nexus.onap.org/service/local/repositories/central/content/net/sourceforge/plantuml/plantuml/8059/plantuml-8059.jar
	sudo mv plantuml-8059.jar plantuml.jar
	fi

if [ ! -f /usr/bin/plantuml ]
	then
	sudo touch /usr/bin/plantuml
	sudo chmod +w /usr/bin/plantuml
	echo "#!/bin/bash" > /tmp/x.$$
	echo "java -jar /usr/share/plantuml/plantuml.jar \$@"  >> /tmp/x.$$
	sudo cp /tmp/x.$$ /usr/bin/plantuml
	sudo chmod +x /usr/bin/plantuml
	fi
