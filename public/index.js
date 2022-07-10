import { Elm } from "../src/Main.elm";
import * as tokiNanpa from './toki-nanpa-client';

const app = Elm.Main.init();

tokiNanpa.connect(app.ports.playerIdPort.send);

app.ports.playerOut.subscribe(playerOutMsg => {
    const room = playerOutMsg.room;
    const history = []

    tokiNanpa.onPeerJoined((peer) => {
        if (peer !== tokiNanpa.me) {
            console.log(`===> History`);
            tokiNanpa.send(room, { type: 'History', history })
        }
    });
    tokiNanpa.onPeerLeft(app.ports.playerLeft.send);

    tokiNanpa.onMessage((msg) => {
        if (msg.data.type === 'History' && history !== []) {
            console.log('<=== history', { history: msg.data.history });
            msg.data.history.forEach(handleSingleMessage);
        } else {
            handleSingleMessage(msg);
        }
    });

    const handleSingleMessage = (msg) => {
        try {
            history.push(msg);
            const { data } = msg;
            switch (data.type) {
                case "Player":
                    handlePlayerMsg(data);
                    break;
                case "Vote":
                    handleVoteMsg(data);
                    break;
                case "State":
                    handleStateMsg(data);
                    break;
                default:
                    console.error('unknown message: ' + JSON.stringify(msg));
                    break;
            }
        } catch (e) {
            console.error('dafuck: ' + JSON.stringify(msg));
        }
    }

    // --------------------------
    // Players
    // --------------------------
    const handlePlayerMsg = data => {
        const { id, nickname } = data;
        console.log(`<=== player: ${id}/${nickname}`)
        app.ports.playersIn.send({ id, nickname });
    }


    console.log(`===> player: ${tokiNanpa.me}/${playerOutMsg.data.nickname}`)
    tokiNanpa.send(room, { type: "Player", id: tokiNanpa.me, nickname: playerOutMsg.data.nickname });

    // --------------------------
    // Votes
    // --------------------------
    const handleVoteMsg = data => {
        const { id, card } = data;
        app.ports.votesIn.send({ player: id, card });
    }
    app.ports.votesOut.subscribe(msg => {
        tokiNanpa.send(room, { type: "Vote", id: tokiNanpa.me, card: msg.data.card });
    });

    // --------------------------
    // State
    // --------------------------
    const handleStateMsg = data => {
        const { state } = data;
        console.log(`<=== state: ${state}`)
        app.ports.statesIn.send(state);
    }
    app.ports.statesOut.subscribe(msg => {
        console.log(`===> state: ${msg.data}`)
        tokiNanpa.send(room, { type: "State", state: msg.data });
    });
});
