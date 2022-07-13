const router = require('express').Router();
const UserController = require('../controllers/user_controller').UserController;


//middeware
const jwt_auth = require('../middleware/jwt_auth').jwt_auth;


//crud stuff
router.post('/registration',UserController.registerUser);
router.post('/login', UserController.loginUser);
router.get('/verify-email', UserController.verifyEmail);
router.get('/get-users',jwt_auth,UserController.getAllUsers);
router.patch('/update-user-detail',jwt_auth,UserController.updateUserDetails);
router.post('/log-out',UserController.logOutUser);





module.exports = router;