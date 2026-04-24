import 'dart:typed_data';
import 'package:nearby_connections/nearby_connections.dart';

class MeshService {
  final Strategy strategy = Strategy.P2P_CLUSTER;
  // This list keeps track of everyone currently connected to us
  List<String> connectedDevices = [];

  void startMesh(String myName, Function(String) onMessageReceived) async {
    try {
      await Nearby().startAdvertising(
        myName,
        strategy,
        onConnectionInitiated: (id, info) async {
          await Nearby().acceptConnection(id, onPayLoadRecieved: (endpointId, payload) {
            if (payload.type == PayloadType.BYTES) {
              String message = String.fromCharCodes(payload.bytes!);
              onMessageReceived(message);
            }
          });
        },
        onConnectionResult: (id, status) {
          if (status == Status.CONNECTED) connectedDevices.add(id);
        },
        onDisconnected: (id) => connectedDevices.remove(id),
      );

      await Nearby().startDiscovery(
        myName,
        strategy,
        onEndpointFound: (id, name, serviceId) async {
          await Nearby().requestConnection(myName, id, onConnectionInitiated: (id, info) async {
            await Nearby().acceptConnection(id, onPayLoadRecieved: (id, payload) {
               if (payload.type == PayloadType.BYTES) {
                  onMessageReceived(String.fromCharCodes(payload.bytes!));
               }
            });
          }, onConnectionResult: (id, status) {
            if (status == Status.CONNECTED) connectedDevices.add(id);
          }, onDisconnected: (id) => connectedDevices.remove(id));
        },
        onEndpointLost: (id) => connectedDevices.remove(id),
      );
    } catch (e) {
      print("Mesh Error: $e");
    }
  }

  // The "Blaster" function
  void broadcastMessage(String text) {
    for (String deviceId in connectedDevices) {
      Nearby().sendBytesPayload(deviceId, Uint8List.fromList(text.codeUnits));
    }
  }
}