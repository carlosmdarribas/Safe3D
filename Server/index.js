#!/usr/bin/env node
var WebSocketServer = require('websocket').server;
const qs = require('qs')
const axios = require('axios')

var http = require('http');
 
var clients = [ ];

var server = http.createServer(function(request, response) {
    console.log((new Date()) + ' Received request for ' + request.url);
    response.writeHead(404);
    response.end();
});
server.listen(8080, function() {
    console.log((new Date()) + ' Server is listening on port 8080');
});
 
wsServer = new WebSocketServer({
    httpServer: server,
    // You should not use autoAcceptConnections for production
    // applications, as it defeats all standard cross-origin protection
    // facilities built into the protocol and the browser.  You should
    // *always* verify the connection's origin and decide whether or not
    // to accept it.
    autoAcceptConnections: false
});
 
function originIsAllowed(origin) {
  // put logic here to detect whether the specified origin is allowed.
  return true;
}

function sendToClients(message, withOutIndex) {
    for (var i=0; i < clients.length; i++) {
        //if (i == withOutIndex) continue;
      clients[i].sendUTF(message);
    }
}
 
wsServer.on('request', function(request) {
    if (!originIsAllowed(request.origin)) {
      // Make sure we only accept requests from an allowed origin
      request.reject();
      console.log((new Date()) + ' Connection from origin ' + request.origin + ' rejected.');
      return;
    }

    var connection = request.accept('', request.origin);
    console.log((new Date()) + ' Connection accepted.');
    var index = clients.push(connection) - 1;

    connection.on('message', function(message) {
        if (message.type === 'utf8') {
            // El mensaje debe ser del tipo {"method": Método} donde:
            // - Método = "change_property", mensaje += {"type": 1, "value": "#FF184A", "username": "carlos"}
            // - Método = "change_model", mensaje += {"id": 1}
            parsedRes = JSON.parse(message.utf8Data);
            console.log('Received JSON: ' + JSON.stringify(parsedRes));

            switch (parsedRes["method"]) {
                case "change_property": // Se ha cambiado una propiedad del modelo.
                    // Se notifica al resto y se mete a la bc.
                    new_property = Number(parsedRes["type"]);
                    new_value = String(parsedRes["value"]);
                    username = String(parsedRes["username"]);

                    console.log(new_property, new_value, username);
            
                    sendToClients(message.utf8Data, index); //TODO: Revisar enviar a todos menos al emisor.

                    axios({
                      method: 'post',
                      url: 'http://localhost:8000/add_change',
                      data: qs.stringify({
                        propery_changed:new_property,
                        value_changed:new_value,
                        username:username
                      }),
                      headers: {
                        'content-type': 'application/x-www-form-urlencoded;charset=utf-8'
                      }
                    }).then(res => {
                        console.log(res.data)
                        sendToClients(JSON.stringify({ method: "addedToBC", txid: String(res.data)}));
                      })
                      .catch(error => {
                        console.error(error)
                      })
                    break;

                case "change_model": // Se ha cambiado el modelo en si.
                    new_model = parsedRes["id"]
                    sendToClients(message.utf8Data); //TODO: Revisar enviar a todos menos al emisor.
                    break;

                default:
                    console.log("Mensaje incorrecto recibido.");
            }
        }
    });

    connection.on('close', function(reasonCode, description) {
        console.log((new Date()) + ' Peer ' + connection.remoteAddress + ' disconnected.');
    });
});









