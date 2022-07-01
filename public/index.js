import { Elm } from "../src/Main.elm";
import { nanoid } from "nanoid";
import GUN from "gun/gun";

const padLeft = (size, text) => Array(size - text.length).join(" ") + text
const log = (name, msg) => console.log(`room: ${msg.room} | ${padLeft(7, name)}:`, msg.data)

const app = Elm.Main.init();

const gun = new GUN().get('xpp3');

app.ports.playerIdPort.send(nanoid(6));
app.ports.votesOut.subscribe(msg => {
    log("vote", msg);
    gun.get(msg.room).get('votes').get(msg.data.player).put(msg.data.card);
});
app.ports.playerOut.subscribe(msg => {
    log("player", msg);
    gun.get(msg.room).get('players').get(msg.data.id).put(msg.data.nickname);
});
app.ports.statesOut.subscribe(msg => {
    log("state", msg);
    gun.get(msg.room).get('state').put(msg.data);
});
