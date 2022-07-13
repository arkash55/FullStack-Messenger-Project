const db = require('../../database/db_connect').db;
const JwtController = require('../../controllers/jwt_controller').JWTController;
const crypto = require('crypto-js');
const userModel = db.models.users;


const salt_and_hash_password = (password) => {
    const salt = crypto.lib.WordArray.random(32).toString();
    const salted_password = password + salt;
    const hashed_password = crypto.SHA256(salted_password).toString();
    return {
        p_salt: salt,
        p_hash: hashed_password
    }
};



const checkIfEmailTaken = async (email) => {
    const user = await userModel.findOne({
        where: {email: email}
    })
    if (user == null) {return false}
    return true
};


const checkIfUsernameTaken = async (username) => {
    const user = await userModel.findOne({
        where: {username: username}
    })
    if (user == null) {return false}
    return true
};






const createUser = async (req, res) => {
    const {p_salt, p_hash} = salt_and_hash_password(req.body['password']);
    const userModel = db.models.users; 

    try {
        const newUser = await userModel.create({
            email: req.body['email'],
            username: req.body['username'],
            first_name: req.body['first_name'],
            last_name: req.body['last_name'],
            profile_pic_key: req.body['profile_pic_key'],
            p_salt: p_salt,
            p_hash: p_hash
        });
        delete newUser.dataValues['p_salt'];
        delete newUser.dataValues['p_hash'];
        delete newUser.dataValues['is_verified'];
        delete newUser.dataValues['createdAt'];
        delete newUser.dataValues['updatedAt'];
        newUser.dataValues['access_token'] = await JwtController.createAccessToken(newUser.dataValues['id']);
        newUser.dataValues['refresh_token'] = await JwtController.createRefreshToken(newUser.dataValues['id']);
        return newUser.dataValues;
    } catch(err) {
        return res.status(400).json({err: `${err}`});
    };
};







module.exports = {
    createUser,
    checkIfEmailTaken,
    checkIfUsernameTaken
}