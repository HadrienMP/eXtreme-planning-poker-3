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
        console.debug('<=== message', JSON.stringify(msg));
        msgCbck(msg);
    })

    // -----------------------
    // Peer
    // -----------------------
    socket.on('peer', msg => {
        console.debug('<=== peer', JSON.stringify(msg));
        switch (msg.type) {
            case "joined":
                console.log('<=== joined:', msg.peer);
                joinedCbck(msg.peer);
                break;
            case "disconnecting":
                console.log('<=== disconnecting', JSON.stringify(msg));
                leftCbck(msg.peer);
                break;
            default:
                console.error('unknown peer event: ' + JSON.stringify(msg))
                break;
        }
    })
};

export const send = (room, data) => socket.emit('message', {room, data});