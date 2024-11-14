ERGOGEN_VERSION=4.1.0
FREEROUTING_VERSION=2.0.1
if [ -d node_modules ]; then
  docker build . -t ceoloide/ergogen-freerouting:${ERGOGEN_VERSION}_${FREEROUTING_VERSION}
  docker push ceoloide/ergogen-freerouting:${ERGOGEN_VERSION}_${FREEROUTING_VERSION}
  docker tag ceoloide/ergogen-freerouting:${ERGOGEN_VERSION}_${FREEROUTING_VERSION} ceoloide/ergogen-freerouting:latest
  docker push ceoloide/ergogen-freerouting:latest
fi