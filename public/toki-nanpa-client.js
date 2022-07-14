import { io } from 'socket.io-client';

const noop = () => { };

let socket = null;
let msgCbck = noop;
let dmCbck = noop;
let leftCbck = noop;
let joinedCbck = noop;
export let me = null;

export const onMessage = (cbck) => msgCbck = cbck;
export const onDM = (cbck) => dmCbck = cbck;
export const onPeerLeft = (cbck) => leftCbck = cbck;
export const onPeerJoined = (cbck) => joinedCbck = cbck;

export const connect = ({onConnect, onDisconnect}) => {
    socket = io("https://toki-nanpa.onrender.com");
    socket.on('connect', () => {
        console.debug('connected', socket.id);
        me = socket.id;
        return onConnect(socket.id);
    });
    socket.on('disconnect', onDisconnect);

    socket.on('message', (msg) => {
        console.log('   IN ',{ ...msg });
        switch (msg.type) {
            case "message":
                msgCbck(msg);
                break;
            case "joined":
                joinedCbck(msg);
                break;
            case "left":
                leftCbck(msg);
                break;
            default:
                console.error('unknown peer event: ' + JSON.stringify(msg))
                break;
        }
    })

    socket.on('direct-message', (msg) => {
        console.log('DM  IN ',{ ...msg });
        dmCbck(msg);
    })
};

export const send = (room, data) => {
    console.log('   OUT',{ room, data });
    return socket.emit('message', { room, data });
};

export const sendDM = (peer, data) => {
    console.log('DM OUT',{ to: peer, data });
    return socket.emit('direct-message', { to: peer, data });
};