const db = require("../database/db_connect").db;
const JwtController = require("./jwt_controller").JWTController;
const NodeMailerController = require("./nodemailer_controller").NodeMailerController;
const {createUser, checkIfEmailTaken, checkIfUsernameTaken} = require("../helpers/user_helper/registration_helper");
const validate_password = require("../helpers/user_helper/login_helper").validate_password;
const userModel = db.models.users;
const blackListTokenModel = db.models.blacklisted_tokens;
const {getOrSetCache, insertOrCreateCache, tokenInsertOrCreateCache} = require('../helpers/redis_helper');


class UserController {

  static registerUser = async (req, res) => {
    if ((await checkIfEmailTaken(req.body["username"])) == true) {
      return res.status(422).json({ message: "Email Constraint Error" });
    }
    if ((await checkIfUsernameTaken(req.body["username"])) == true) {
      return res.status(422).json({ message: "Username Constraint Error" });
    }
    try {
      const newUser = await createUser(req, res);
      // await NodeMailerController.verifyEmail(
      //   newUser["id"],
      //   newUser["email"]
      // ).catch((err) => {
      //   res.status(400).json({ error: err });
      // });
      const cachedUserInfo = {
        'id': newUser.id,
        'username': newUser.username,
        'first_name': newUser.first_name,
        'last_name': newUser.last_name,
        'profile_pic_key': newUser.profile_pic_key
      }
      await insertOrCreateCache("users", cachedUserInfo);
      return res.status(201).json(newUser);
    } catch (err) {
      return res.status(400).json({err: String(err)});
    }
  };




  static loginUser = async (req, res) => {
    //check if user exists, if exists send back user data
    const email = req.body["email"];
    const password = req.body["password"];

    const userModel = db.models["users"];
    const user = await userModel
      .findOne({
        attributes: [ "id", "email", "username", "first_name", "last_name", "profile_pic_key", "is_verified", "p_salt", "p_hash", ],
        where: { email: email },
      })
      .catch((err) => {
        res.status(400).json({ error: `${err}` });
      });

    //check if user exists
    if (user === null)
      return res.status(404).json({ error: "User does not exist" });

    //validate password
    if (validate_password(password, user["p_hash"], user["p_salt"]) == false)
      return res.status(401).json({ error: "Incorrect password" });

    //check if user is verified
    if (user["is_verified"] == false)
      return res.status(403).json({ error: "User is not verified" });

    //Generate access and refresh token for user
    user.dataValues["access_token"] = await JwtController.createAccessToken(
      user["id"]
    ).catch((err) => {
      return res
        .status(400)
        .json({ error: `Error creating access token: {${err}` });
    });

    user.dataValues["refresh_token"] = await JwtController.createRefreshToken(
      user["id"]
    ).catch((err) => {
      return res
        .status(400)
        .json({ error: `Error creating refresh token: ${err}` });
    });

    delete user.dataValues["p_salt"];
    delete user.dataValues["p_hash"];
    return res.status(200).json(user);
  };




  static verifyEmail = async (req, res) => {
    const token = req.query["token"];
    const responseObj = await JwtController.validateEmailToken(token);
    if (responseObj["success"] === false) {
      return res.status(401).json(responseObj["error"]);
    }
    //change user verfied status
    try {
      const userModel = db.models["users"];
      const user = await userModel.findOne({
        where: { id: responseObj["user_id"] },
        attributes: ["id", "is_verified"],
      });
      if (user["is_verified"] === true) {
        return res.status(200).json({ message: "User is already verified" });
      }
      user["is_verified"] = true;
      await user.save();
      return res.status(200).json({ message: "User email has been verified" });
    } catch (err) {
      return res.status(400).send(err);
    }
  };



  static getAllUsers = async(req, res) => {
    try {
        const users = await getOrSetCache('users', async () => {
          const usersData = await userModel.findAll({
            attributes: ['id', 'username', 'first_name', 'last_name', 'profile_pic_key']
          })
          return usersData
      })
        return res.status(200).json(users);
    } catch (err) {
        return res.status(400).json({err: String(err)})
    }
 };




  static updateUserDetails = async (req, res) => {
    try {
      const user = await userModel.findByPk(req.body["id"], {
        attributes: ["id", "username", "first_name", "last_name"],
      });
      user.set({
        username: req.body["username"],
        first_name: req.body["first_name"],
        last_name: req.body["last_name"],
        profile_pic_key: req.body["profile_pic_key"],
      });
      user.save();
      return res.status(200).json(user);
    } catch (err) {
      res.status(400).json({ err: "" + err });
    }
  };

  

  static logOutUser = async (req, res) => {
    const authHeader = req.headers["authorization"];
    const refresh_token = authHeader && authHeader.split(" ")[1];
    const uid = req.body["uid"];
    try {
      const blacklisted_token = await blackListTokenModel.create({
        uid: uid,
        refresh_token: refresh_token
      });
      await tokenInsertOrCreateCache(blacklisted_token);
      return res.status(201).json({message: 'Successfully blacklisted token'});
    } catch (err) {
      return res.status(400).json({ err: String(err) });
    }
  };

}

module.exports = { UserController };
