const jwt = require('jsonwebtoken');


const jwt_auth = async (req, res, next) => {
    const auth_header = req.headers['authorization'];
    const access_token = auth_header && auth_header.split(" ")[1];

    if (access_token == null) {return res.status(400).json({error:'Missing auth header'})};
    
    jwt.verify(access_token, process.env.ACCESS_TOKEN_SECRET_KEY, (err, payload) => {
        if (err) {return res.status(401).json(err)};
        //token is succesfully verified
        req.uid = payload['uid'];
        next();
    });
};



module.exports = {jwt_auth}