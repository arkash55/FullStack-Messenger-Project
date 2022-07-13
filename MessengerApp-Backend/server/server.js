require('dotenv').config();
const morgan = require('morgan');
const {app, server} = require('./server-config/config');
const express = require('express');
const configure_db = require('./database/db_config');
const configure_redis = require('./database/redis_config');
const user_router = require('./routes/user_routes');
const conversation_router = require('./routes/conversation_routes');
const message_router = require('./routes/message_routes');
const token_router = require('./routes/token_routes')


const port = process.env.PORT || 3001;


//listen to server
server.listen(port, () => {
    console.log(`Listening to server at port ${port}`);
});


//middleware
app.use(express.json());
app.use(morgan('dev'));


//routing
app.use('/user', user_router);
app.use('/token', token_router)
app.use('/conversation', conversation_router);
app.use('/message', message_router);


//websockets
const chat_socket = require('./websockets/chat_socket');
const conversation_socket = require('./websockets/conversation_socket');


