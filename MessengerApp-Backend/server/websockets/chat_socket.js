const server = require('../server-config/config').server;
const io = require('socket.io')(server, {path: "/ws/messaging"});


io.on('connection', (socket) => {
    console.log('a client has connected');
    const conversation_id = socket.handshake.query.conversation_id && String(socket.handshake.query.conversation_id);
    if (conversation_id == null) {throw 'No conversation_id provided'};

  
    //join room
    socket.join(conversation_id);



    //socket event responses
    socket.on('message', (data) => {
        console.log(data)
        io.to(conversation_id).emit('message', data);
    });



});


