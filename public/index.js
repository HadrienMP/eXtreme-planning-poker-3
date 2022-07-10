import GUN from "gun/gun";
require("gun/lib/path");
import { nanoid } from "nanoid";
import { Elm } from "../src/Main.elm";


const app = Elm.Main.init();

const gun = new GUN("https://hmp-gundb-server.onrender.com/gun");

const playerId = nanoid(6)
app.ports.playerIdPort.send(playerId);
app.ports.playerOut.subscribe(msg => {
    const room = msg.room;

    // --------------------------
    // Players
    // --------------------------
    const gunPlayers = gun.path(`xpp3/${room}/players`);
    gunPlayers.map().on((nickname, id) => {
        console.log(`<=== player: ${id}/${nickname}`)
        if (nickname === null) app.ports.playerLeft.send(id);
        else app.ports.playersIn.send({ id, nickname });
    });

    console.log(`===> player: ${playerId}/${msg.data.nickname}`)
    gunPlayers.get(playerId).put(msg.data.nickname);

    // --------------------------
    // Votes
    // --------------------------
    const gunVotes = gun.path(`xpp3/${room}/votes`);
    gunVotes.map().on((card, player) => {
        // console.log(`<=== vote: ${player}/${card}`)
        return app.ports.votesIn.send({ player, card });
    });
    app.ports.votesOut.subscribe(msg => {
        // console.log(`===> vote: ${msg.data}`)
        return gunVotes.get(playerId).put(msg.data.card);
    });

    // --------------------------
    // State
    // --------------------------
    const gunRoom = gun.path(`xpp3/${room}`);
    gunRoom.on((roomObj, k) => {
        console.log(`<=== state: ${roomObj.state}`)
        return app.ports.statesIn.send(roomObj.state);
    });
    app.ports.statesOut.subscribe(msg => {
        console.log(`===> state: ${msg.data}`)
        return gunRoom.put({ state: msg.data });
    });


    // --------------------------
    // Leaving
    // --------------------------
    window.onbeforeunload = () => {
        gunPlayers.get(playerId).put(null);
        gunVotes.get(playerId).put(null);
    };
});
