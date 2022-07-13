const db = require('../../database/db_connect').db;
const conversationModel = db.models.conversations;
const moment = require('moment');
const util = require('util');

const updateLatestMessage = async (convo_id, message_body, message_type) => {
    try {
        const conversation = await conversationModel.findByPk(convo_id);
        conversation.update({
            latest_message: message_body,
            latest_message_type: message_type,
        });
        await conversation.save()
    } catch (err) {
        return '' + err
    }
};




module.exports = {updateLatestMessage};