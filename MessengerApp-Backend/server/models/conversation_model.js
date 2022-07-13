const db = require('../database/db_connect').db;
const moment = require('moment');
const DataTypes = require('sequelize').DataTypes;
const User = db.models.users;

const Conversation = db.define('conversations', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false
    },
    latest_message: {
        type: DataTypes.STRING,
        allowNull: false
    }, 
    latest_message_type: {
        type: DataTypes.STRING,
        allowNull: false
    },
    updatedAt: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
        allowNull: false,
        get() {
            return moment(this.getDataValue('updatedAt')).format('YYYY-MM-DD HH:mm:ss');
        }
    }
})

Conversation.belongsToMany(User, {through: 'convo_users', as: 'users'});
User.belongsToMany(Conversation, {through: 'convo_users', as: 'conversations'});





module.exports = {Conversation}