import { io } from 'socket.io-client';
import { Elm } from "../src/Main.elm";


const app = Elm.Main.init();

const socket = io("https://toki-nanpa.onrender.com");

let playerId = null;
socket.on('connect', () => {
    playerId = socket.id;
    app.ports.playerIdPort.send(playerId);

})

app.ports.playerOut.subscribe(msg => {
    const room = msg.room;
    const history = []
    socket.on('message', (msg) => {
        console.debug('<=== message', JSON.stringify(msg));
        if (msg.data?.type === 'History' && history !== []) {
            console.log('<=== history', {history: msg.data.history});
            history.concat(msg.data.history);
            msg.data.history.forEach(it => {
                handleSingleMessage(it);
            });
        } else {
            handleSingleMessage(msg);
        }
    });

    const handleSingleMessage = (msg) => {
        try {
            const { room, peer, data } = msg;
            history.push(msg);
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

    socket.on('peer', msg => {
        switch (msg.type) {
            case "joined":
                console.log('<=== joined:', msg.peer);
                if (msg.peer !== socket.id) {
                    console.log(`===> History`);
                    socket.emit('message', { room, data: { type: 'History', history } })
                }
                break;
            case "disconnecting":
                console.log('disconnecting', JSON.stringify(msg));
                app.ports.playerLeft.send(msg.peer);
                break;
            default:
                console.error('unknown peer event: ' + JSON.stringify(msg))
                break;
        }
    })

    // --------------------------
    // Players
    // --------------------------
    const handlePlayerMsg = data => {
        const { id, nickname } = data;
        console.log(`<=== player: ${id}/${nickname}`)
        app.ports.playersIn.send({ id, nickname });
    }


    console.log(`===> player: ${playerId}/${msg.data.nickname}`)
    socket.emit('message', { room, data: { type: "Player", id: playerId, nickname: msg.data.nickname } });

    // --------------------------
    // Votes
    // --------------------------
    const handleVoteMsg = data => {
        const { id, card } = data;
        app.ports.votesIn.send({ player: id, card });
    }
    app.ports.votesOut.subscribe(msg => {
        socket.emit('message', { room, data: { type: "Vote", id: playerId, card: msg.data.card } });
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
        socket.emit('message', { room, data: { type: "State", state: msg.data } });
    });
});
