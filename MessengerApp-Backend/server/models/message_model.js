const sequelize = require('sequelize');
const db = require('../database/db_connect').db;
const DataTypes = require('sequelize').DataTypes;
const moment = require('moment');

const Message = db.define('message', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
        allowNull: false
    },
    body: {
        type: DataTypes.STRING(2000),
    },
    type: {
        type: DataTypes.STRING,
        allowNull: false
    },
    sent_date: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
        get() {
            return moment(this.getDataValue('sent_date')).format('YYYY-MM-DD HH:mm:ss');
        }
    } 

},{timestamps: false})


//Set up one to many relationship
const User = db.models.users;
const Conversation = db.models.conversations;
Conversation.hasMany(Message, {foreignKey: 'conversation_id'});
Message.belongsTo(Conversation, {foreignKey: 'conversation_id'});

User.hasMany(Message, {foreignKey: 'sender_id', onDelete: 'CASCADE'});
Message.belongsTo(User, {foreignKey: 'sender_id'});



module.exports = {Message}
