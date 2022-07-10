import { io } from 'socket.io-client';

const noop = () => { };

let socket = null;
let msgCbck = noop;
let joinedCbck = noop;
let leftCbck = noop;
export let me = null;

export const onMessage = (cbck) => msgCbck = cbck;
export const onPeerJoined = (cbck) => joinedCbck = cbck;
export const onPeerLeft = (cbck) => leftCbck = cbck;
export const connect = (onConnection = noop) => {
    socket = io("https://toki-nanpa.onrender.com");
    socket.on('connect', () => {
        console.debug('connected', socket.id);
        me = socket.id;
        return onConnection(socket.id);
    });

    // -----------------------
    // Message
    // -----------------------
    socket.on('message', (msg) => {
        msgCbck(msg);
    })

    // -----------------------
    // Peer
    // -----------------------
    socket.on('peer', msg => {
        switch (msg.type) {
            case "joined":
                joinedCbck(msg.peer);
                break;
            case "disconnecting":
                leftCbck(msg);
                break;
            default:
                console.error('unknown peer event: ' + JSON.stringify(msg))
                break;
        }
    })
};

export const joinRoom = (room) => socket.emit('join', { data: room });
export const send = (room, data) => socket.emit('message', { room, data });