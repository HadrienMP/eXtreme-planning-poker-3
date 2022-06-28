import { Elm } from "../src/Main.elm";
import { nanoid } from "nanoid";

const log = name => toLog => console.log(name, toLog)

const app = Elm.Main.init();
app.ports.playerIdPort.send(nanoid(6));
app.ports.votes.subscribe(log("vote"));
app.ports.player.subscribe(log("player"));
app.ports.states.subscribe(log("state"));