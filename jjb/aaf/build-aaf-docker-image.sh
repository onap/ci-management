CURRENTDIR="$(pwd)"
echo $CURRENTDIR
ls -ltr
cd auth/docker/
ls -ltr
chmod 755 *
sh dbuild.sh
sh dpush.sh