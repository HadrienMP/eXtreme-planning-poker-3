import { Elm } from "../src/Main.elm";
import { nanoid } from "nanoid";
import GUN from "gun/gun";

const log = name => toLog => console.log(name, toLog)
const parseRoom = () => window.location.pathname.match(/\/room\/(.*)/)[1]

const app = Elm.Main.init();

const gun = new GUN().get('xpp3');

app.ports.playerIdPort.send(nanoid(6));
app.ports.votesOut.subscribe(({room, vote}) => {
    console.log({room,vote});
    gun.get(room).get('votes').get(vote.player).put(vote.card);
});
app.ports.playerOut.subscribe(player => {
    log("player")(player);
    log("room")(parseRoom());
    gun.get(parseRoom()).get('players').get(player.id).put(player.nickname);
});
app.ports.statesOut.subscribe(state => {
    log("state")(state);
    log("room")(parseRoom());
    gun.get(parseRoom()).get('state').put(state);
});