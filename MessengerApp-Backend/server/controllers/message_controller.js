const db = require('../database/db_connect').db;
const MessageModel = db.models.message;
const ConversationModel = db.models.conversations;
const updateLatestMessage = require('../helpers/message_helper/send_message_helper').updateLatestMessage;


class MessageController {

    //send a message
    static sendMessage = async (req, res) => {
        const conversation_id = req.params['convo_id'];
        const sender_id = req.body['sender_id'];
        const message_body = req.body['body'];
        const message_type = req.body['type'];


        try {
            const new_message = await MessageModel.create({
                body: message_body,
                type: message_type,
                sender_id: sender_id,
                conversation_id: conversation_id
            });

            //update latest convo
            const ulmResponse = await updateLatestMessage(conversation_id,message_body, message_type);
            if (ulmResponse != null) {return res.status(400).json({err: '' + ulmResponse})}

            return res.status(201).json(new_message);
        } catch (err) {
            return res.status(400).json({err: '' + err})
        }
    };


    //get all messages
    static getAllMessages = async (req, res) => {
        const conversation_id = req.params['convo_id'];

        try {
            const messages = await ConversationModel.findByPk(conversation_id,{
                attributes: [],
                include: [{
                    model: MessageModel,
                    attributes: ['id', 'body', 'type', 'conversation_id', 'sender_id', 'sent_date']
                }]
            })
            return res.status(200).json(messages['messages']);
        } catch (err) {
            return res.status(400).json({err: '' + err})
        }

    };

}



module.exports = {MessageController}