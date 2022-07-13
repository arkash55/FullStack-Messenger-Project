const router = require('express').Router();
const MessagesController = require('../controllers/message_controller').MessageController
const jwt_auth = require('../middleware/jwt_auth').jwt_auth

router.post('/send-message/:convo_id',jwt_auth,MessagesController.sendMessage);
router.get('/get-chat-messages/:convo_id',jwt_auth, MessagesController.getAllMessages);


module.exports = router;