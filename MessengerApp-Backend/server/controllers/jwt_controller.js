const jwt = require('jsonwebtoken');
const db = require('../database/db_connect').db;
const blackListTokenModel = db.models.blacklisted_tokens;
const {checkForBlacklistedToken} = require('../helpers/jwt_helper/create_refresh_helper')


class JWTController {
    //method to create an access token
    static createAccessToken = (uid) => {
        return new Promise((resolve, reject) => {
            jwt.sign({uid: uid}, process.env.ACCESS_TOKEN_SECRET_KEY, {expiresIn: '15m'}, (err, token) => {
                if (err) reject(err);
                resolve(token);
            });
        })
    };




    //method to create refresh token
    static createRefreshToken = (uid) => {
        return new Promise((resolve, reject) => {
            jwt.sign({uid: uid}, process.env.REFRESH_TOKEN_SECRET_KEY, {expiresIn:'180d'}, (err, token) => {
                if (err) reject(err);
                resolve(token);
            });
        });
    };



    //validate refresh token and create new access_token
    static validateRefreshToken = async (req, res) => {
        const auth_header = req.headers['authorization'];
        const token = auth_header && auth_header.split(" ")[1];

        if (token == null) {return res.status(400).json({error: 'Missing refresh token'})};

        const uid = jwt.verify(token, process.env.REFRESH_TOKEN_SECRET_KEY, (err, payload) => {
            if (err) return res.status(401).json(err);
            return payload['uid'];
        });

        
        const isTokenBlacklisted = await checkForBlacklistedToken(uid, token);

        if (isTokenBlacklisted === true) {return res.status(403).json({message: 'Token has been blacklisted'})}

        const access_token = await this.createAccessToken(uid).catch((err) => {return res.status(500).json({err: '' + err})})
        return res.status(201).json({access_token: access_token});
    };



    //create email token
    static createEmailToken = async(uid) => {
        const secretKey = process.env.EMAIL_TOKEN_SECRET_KEY;
        return new Promise((resolve, reject) => {
            jwt.sign({id: uid}, secretKey, (err, token) => {
                if (err) reject(err);
                resolve(token);
            });
        })
    };


    //validate email token
    static validateEmailToken = (token) => {
        const secretKey = process.env.EMAIL_TOKEN_SECRET_KEY;
        return new Promise((resolve, reject) => {
            jwt.verify(token, secretKey, (err, payload) => {
                if (err) reject({success:false, error: err}) ;
                resolve({success: true, user_id: payload['id']}); 
            })
        })
    };


};



module.exports = {JWTController};