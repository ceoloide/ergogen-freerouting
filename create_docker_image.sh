ERGOGEN_VERSION=4.1.0
FREEROUTING_VERSION=2.1.0
if [ -f Dockerfile ]; then
  docker build . -t ceoloide/ergogen-freerouting:${ERGOGEN_VERSION}_${FREEROUTING_VERSION}
  docker push ceoloide/ergogen-freerouting:${ERGOGEN_VERSION}_${FREEROUTING_VERSION}
  docker tag ceoloide/ergogen-freerouting:${ERGOGEN_VERSION}_${FREEROUTING_VERSION} ceoloide/ergogen-freerouting:latest
  docker push ceoloide/ergogen-freerouting:latest
else
  echo "Dockerfile not found in the folder."
fi
