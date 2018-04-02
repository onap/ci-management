CURRENTDIR="$(pwd)"
echo $CURRENTDIR
ls -ltr
mvn clean install
ls -ltr
cd auth/docker/
ls -ltr
chmod 755 *
./dbuild