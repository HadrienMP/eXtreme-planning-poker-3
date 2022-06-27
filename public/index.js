import { Elm } from "../src/Main.elm";
import { nanoid } from "nanoid";

const app = Elm.Main.init();
app.ports.playerIdPort.send(nanoid());