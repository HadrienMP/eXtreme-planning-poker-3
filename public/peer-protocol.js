export const playerMsgType = 'Player';
export const voteplayerMsgType = 'Vote';
export const stateMsgType = 'State';
export const historyMsgType = 'History';

export const join = (currentRoom, tokiNanpa, listeners = { onPlayer, onVote, onState, onPlayerLeft }) => {
    const history = [];

    tokiNanpa.joinRoom(currentRoom);

    tokiNanpa.onPeerLeft(({ room, peer }) => {
        return room === currentRoom ? listeners.onPlayerLeft(peer) : null;
    });
    tokiNanpa.onPeerJoined((peer) => peer !== tokiNanpa.me ? tokiNanpa.send(currentRoom, { type: historyMsgType, history }) : null);
    tokiNanpa.onMessage((msg) => {
        if (msg.data.type === historyMsgType && history !== []) {
            msg.data.history.forEach(handleSingleMessage);
        } else {
            handleSingleMessage(msg);
        }
    });

    const handleSingleMessage = (msg) => {
        history.push(msg);
        const { data } = msg;
        switch (data.type) {
            case playerMsgType:
                listeners.onPlayer(data);
                break;
            case voteplayerMsgType:
                listeners.onVote(data);
                break;
            case stateMsgType:
                listeners.onState(data);
                break;
            default:
                console.error('unknown message: ' + JSON.stringify(msg));
                break;
        }
    }

    return ({
        sendPlayer: (player) => tokiNanpa.send(currentRoom, { type: playerMsgType, ...player }),
        sendVote: (vote) => tokiNanpa.send(currentRoom, { type: voteplayerMsgType, ...vote }),
        sendState: (state) => tokiNanpa.send(currentRoom, { type: stateMsgType, state }),
    });
};