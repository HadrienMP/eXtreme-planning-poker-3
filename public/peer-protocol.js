export const playerMsgType = 'Player';
export const voteplayerMsgType = 'Vote';
export const stateMsgType = 'State';
export const historyMsgType = 'History';
export const playerLeftMsgType = 'PlayerLeft';

export const join = (currentRoom, tokiNanpa, listeners = { onPlayer, onVote, onState, onPlayerLeft }) => {
    
    const history = [];
    const handleSingleMsg = handleSingleMessage(listeners, history);

    tokiNanpa.onPeerLeft(({ room, from:peer }) => handleSingleMsg({room, data: {type: playerLeftMsgType, id: peer}}));
    tokiNanpa.onPeerJoined(({ from: peer }) => {
        if (peer !== tokiNanpa.me) {
            tokiNanpa.sendDM(peer, { type: historyMsgType, history });
        }
    });
    tokiNanpa.onMessage(handleSingleMsg);
    tokiNanpa.onDM((msg) => {
        if (msg.data.type === historyMsgType && history !== []) {
            msg.data.history.forEach(handleSingleMsg);
        }
    });

    return ({
        sendPlayer: (player) => tokiNanpa.send(currentRoom, { type: playerMsgType, ...player }),
        sendVote: (vote) => tokiNanpa.send(currentRoom, { type: voteplayerMsgType, ...vote }),
        sendState: (state) => tokiNanpa.send(currentRoom, { type: stateMsgType, state }),
    });
};

const handleSingleMessage = (listeners, history) => (msg) => {
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
        case playerLeftMsgType:
            listeners.onPlayerLeft(data.id);
            break;            
        default:
            console.error('unknown message: ' + JSON.stringify(msg));
            break;
    }
}