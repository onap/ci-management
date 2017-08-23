CURRENTDIR="$(pwd)"
echo $CURRENTDIR
ls -ltr
cd deliveries
ls -ltr
chmod 755 *.sh
./build_portalapps_dockers.sh
