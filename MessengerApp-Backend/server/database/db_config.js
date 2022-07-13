const db = require('./db_connect').db;


//models
const User = require('../models/user_model').User;
const Conversation = require('../models/conversation_model').Conversation;
const Message = require('../models/message_model').Message;
const BlacklistedToken = require('../models/blacklisted_token_model').BlacklistedToken;


db.sync().then(() => {
    console.log('Successfully synced to database');
}).catch((err) => {
    throw err
});

