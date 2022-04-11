import "dart:async";
import 'dart:convert';

import 'package:eventsource/publisher.dart';
import "package:shelf/shelf_io.dart" as io;
import "package:shelf_eventsource/shelf_eventsource.dart";
import 'package:shelf_router/shelf_router.dart';

main() {
  var app = Router();
  app.get("/events", (r) {
    final publisher = EventSourcePublisher();
    generateEvents(publisher);
    var handler = eventSourceHandler(publisher);
    handler(r);
  });

  io.serve(app, "localhost", 8080);
}

generateEvents(EventSourcePublisher publisher) {
  int id = 0;
  Timer.periodic(const Duration(milliseconds: 300), (timer) {
    final data = json.encode({
      'name': id,
      'message': 'event $id',
      'finished': id == 10,
    });
    publisher.add(Event(data: data));

    if (id == 10) {
      timer.cancel();

      publisher.close();
    }

    id++;
  });
}
