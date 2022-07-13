const db = require('../database/db_connect').db;
const Op = require('sequelize').Op;
const userModel = db.models.users;
const convoModel = db.models.conversations;
const {getOrSetCache, insertOrCreateCache} = require('../helpers/redis_helper');

class ConversationController {

    static createConversation = async (req, res) => {
        try {
            const latest_message = req.body['latest_message'];
            const latest_message_type = req.body['latest_message_type'];
            const newConvo = await convoModel.create({
                latest_message: latest_message,
                latest_message_type: latest_message_type
            });
            await newConvo.addUser(req.body['user_1']);
            await newConvo.addUser(req.body['user_2']);

            const final_convo = await convoModel.findByPk(newConvo['id'], {
                attributes: ['id', 'latest_message', 'latest_message_type', 'updatedAt'],
                include: [{
                    model: db.models.users,
                    as: 'users',
                    through: {attributes:[]},
                    where: {id: {[Op.ne]: req.uid}},
                    attributes: ['id', 'username', 'first_name', 'last_name', 'profile_pic_key']
                }]
            })
            await insertOrCreateCache(`chat/${req.uid}`,final_convo)
            return res.status(201).json(final_convo);
        } catch (err) {
            return res.status(400).json({err: '' + err})
        }
    }


    static getUserConversations = async (req, res) => {
        const uid = req.params['id'];
        try {
            const parsed_data = await getOrSetCache(`chat/${uid}`, async () => {
                const userConvos = await userModel.findByPk(uid, {
                    attributes: [],
                    include: [{
                        model: db.models.conversations,
                        as: 'conversations',
                        attributes: ['id', 'latest_message', 'latest_message_type', 'updatedAt'],
                        through: {attributes: []},
                        include: [{
                            model: userModel,
                            as: 'users',
                            where: {id: {[Op.ne]: uid}},
                            attributes: ['id', 'username', 'first_name', 'last_name', 'profile_pic_key'],
                            through: {attributes: []}
                        }] 
                    }]
                });
                return userConvos['conversations']
            })
            return res.status(200).json(parsed_data);
        } catch (err) {
            return res.status(400).json({err: String(err)});
        }
    };



    // static getUserConversations = async (req, res) => {
    //     const uid = req.params['id'];
    //     try {
    //         const userModel = db.models.users;
    //         const userConvos = await userModel.findByPk(uid, {
    //             attributes: [],
    //             include: [{
    //                 model: db.models.conversations,
    //                 as: 'conversations',
    //                 attributes: ['id', 'latest_message', 'latest_message_type', 'updatedAt'],
    //                 through: {attributes: []},
    //                 include: [{
    //                     model: userModel,
    //                     as: 'users',
    //                     where: {id: {[Op.ne]: uid}},
    //                     attributes: ['id', 'username', 'first_name', 'last_name', 'profile_pic_key'],
    //                     through: {attributes: []}
    //                 }] 
    //             }]
    //         });
    //         res.status(200).json(userConvos['conversations']);
    //     } catch (err) {
    //         res.status(400).json('' + err);
    //     }
    // };







}












module.exports = {ConversationController};