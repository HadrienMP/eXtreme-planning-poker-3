import { Elm } from "../src/Main.elm";
import * as tokiNanpa from './toki-nanpa-client';
import * as peerProtocol from './peer-protocol';

const app = Elm.Main.init();

tokiNanpa.connect({
    onConnect: app.ports.playerIdIn.send,
    onDisconnect: () => app.ports.disconnected.send({})
});

app.ports.playerOut.subscribe(playerOutMsg => {
    const room = peerProtocol.join(playerOutMsg.room, tokiNanpa, {
        onPlayer: app.ports.playersIn.send,
        onVote: app.ports.votesIn.send,
        onState: ({ state }) => app.ports.statesIn.send(state),
        onPlayerLeft: app.ports.playerLeft.send,
    });

    room.sendPlayer(playerOutMsg.data);
    app.ports.votesOut.subscribe(msg => room.sendVote(msg.data));
    app.ports.statesOut.subscribe(msg => room.sendState(msg.data));
});

app.ports.log.subscribe(console.log);
app.ports.warn.subscribe(console.warn);
app.ports.error.subscribe(console.error);