
const db = require('../database/db_connect').db;
const DataTypes = require('sequelize').DataTypes;


// const MMConvo = db.define('mmConvo', {
//     id: {
//         type: DataTypes.INTEGER,
//         primaryKey: true,
//         autoIncrement: true,
//         allowNull: false
//     },
//     latest_message: {
//         type: DataTypes.STRING,
//         allowNull: false
//     }
// })


// const User = db.models.users;
// MMConvo.belongsToMany(User, {through: 'convo_users', as: 'users'});
// User.belongsToMany(MMConvo, {through: 'convo_users', as: 'conversations'});

// // MMConvo.belongsToMany(User, {through: 'convo_users'});
// // User.belongsToMany(MMConvo, {through: 'convo_users'});

// module.exports = {MMConvo};