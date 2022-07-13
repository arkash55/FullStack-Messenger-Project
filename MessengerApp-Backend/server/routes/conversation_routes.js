const router = require('express').Router();
const ConversationController = require('../controllers/conversation_controller').ConversationController;
const jwt_auth = require('../middleware/jwt_auth').jwt_auth


router.get('/get-chats/:id',jwt_auth,ConversationController.getUserConversations);
router.post('/create-conversation',jwt_auth,ConversationController.createConversation);






module.exports = router;