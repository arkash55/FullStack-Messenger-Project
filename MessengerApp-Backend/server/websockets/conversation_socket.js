const server = require('../server-config/config').server;
const io = require('socket.io')(server, {path: '/ws/conversations'});

io.on('connection', socket => {
    console.log('connected to convo socket');
    const current_user_uid = socket.handshake.query.current_user_id;
    const recipient_uid = socket.handshake.query.recipient_user_id;
    const current_user_room = `user_conversation_room_${current_user_uid}`;
    const recipient_room = `user_conversation_room_${recipient_uid}`;


    //join room
    socket.join(current_user_room);



    //EVENTS

    // a new message was sent
    socket.on('new_conversation_latest_message', message_data => {
        io.to(current_user_room).to(recipient_room).emit('new_conversation_latest_message', message_data);
    });

    // a new conversation was created
    socket.on('new_conversation_created', conversation_data => {
        io.to(current_user_room).emit('new_conversation_created', conversation_data['current_user_data']);
        io.to(recipient_room).emit('new_conversation_created', conversation_data['recipient_data']);
    })

});