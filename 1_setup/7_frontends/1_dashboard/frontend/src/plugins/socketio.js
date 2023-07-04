import io from "socket.io-client";

let socket = undefined;
const localIP = "localhost";
const networkIP = "backend.REPLACE_K8S_HOST";
const port = 3030;
const networkConnection = true; //process.env.VUE_APP_SOCKET_NETWORK_CONNECTION;

function initialiseSocket() {
  const url = networkConnection
    ? `https://${networkIP}:443`
    : `http://${localIP}:${port}`;

  socket = io(url, {
    withCredentials: true,
  });
}

export function addEventListener(event) {
  if (!socket) {
    initialiseSocket();
  }

  socket.on(event.type, event.callback);
}

export function sendEvent(event) {
  socket.emit(event.type, event.data);
}
