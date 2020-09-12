define ([], function(Terminal) {
    "use strict";
    function make_terminal(element, ws_url) {
        var ws = new WebSocket(ws_url);
        var term = new Terminal({cols: 80, rows: 24});
        ws.onopen = function(event) {
            term.on('data', function(data) {
                ws.send(JSON.stringify(['stdin', data]));
            });
            
            term.on('title', function(title) {
                document.title = title;
            });
            
            term.open(element);

            ws.onmessage = function(event) {
                var json_msg = JSON.parse(event.data);
                switch(json_msg[0]) {
                    case "stdout":
                        term.write(json_msg[1]);
                        break;
                    case "disconnect":
                        term.write("\r\n\r\n[CLOSED]\r\n");
                        break;
                }
            };
        };
        return {socket: ws, term: term};
    }

    return {make_terminal: make_terminal};
});
