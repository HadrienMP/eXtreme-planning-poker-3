import GUN from "gun/gun";
require("gun/lib/path");
import { nanoid } from "nanoid";
import { Elm } from "../src/Main.elm";

const padLeft = (size, text) => Array(size - text.length).join(" ") + text
const log = (name, msg) => console.log(`room: ${msg.room} | ${padLeft(7, name)}:`, msg.data)
const getRoom = () => window.location.pathname.match(/\/room\/(.*)/)[1];

const app = Elm.Main.init();

const gun = new GUN("https://hmp-gundb-server.onrender.com/gun");

const playerId = nanoid(6)
app.ports.playerIdPort.send(playerId);
app.ports.playerOut.subscribe(msg => {
    const room = msg.room;
    const gunPlayers = gun.path(`xpp3/${room}/players`);
    const gunVotes = gun.path(`xpp3/${room}/votes`);
    const gunState = gun.path(`xpp3/${room}/state`);

    gunPlayers.get(playerId).put(msg.data.nickname);
    
    gunPlayers.map().off();
    gunPlayers.map().on((nickname, id) => {
        if (nickname !== null) app.ports.playersIn.send({ id, nickname });
    });

    gunVotes.map().off();
    gunVotes.map().on((card, player) => {
        if (card !== null) app.ports.votesIn.send({ player, card });
    });

    gunState.off();
    gunState.on(state => app.ports.statesIn.send(state));

    app.ports.votesOut.subscribe(msg => gunVotes.get(playerId).put(msg.data.card));
    app.ports.statesOut.subscribe(msg => gunState.put(msg.data));

    window.onbeforeunload = () => {
        console.log('going out once')
        gunPlayers.get(playerId).put(null);
        gunVotes.get(playerId).put(null);
        console.log('going out twice');
    };
});
