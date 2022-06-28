import { Elm } from "../src/Main.elm";
import { nanoid } from "nanoid";
import GUN from "gun/gun";

const log = name => toLog => console.log(name, toLog)
const room = () => window.location.pathname.match(/\/room\/(.*)/)[1]

const app = Elm.Main.init();

const gun = new GUN().get('xpp3');

app.ports.playerIdPort.send(nanoid(6));
app.ports.votes.subscribe(vote => {
    log("vote")(vote);
    log("room")(room());
    gun.get(room()).get('votes').get(vote.player).put(vote.card);
});
app.ports.player.subscribe(player => {
    log("player")(player);
    log("room")(room());
    gun.get(room()).get('players').get(player.id).put(player.nickname);
});
app.ports.states.subscribe(state => {
    log("state")(state);
    log("room")(room());
    gun.get(room()).get('state').put(state);
});