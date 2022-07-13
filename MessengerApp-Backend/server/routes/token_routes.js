const router = require('express').Router()
const JwtController = require('../controllers/jwt_controller').JWTController;


//token stuff
router.post('/new-access-token', JwtController.validateRefreshToken);




module.exports = router