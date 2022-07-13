const db = require('../database/db_connect').db;
const DataTypes = require('sequelize').DataTypes;

const BlacklistedToken = db.define('blacklisted_tokens',{
    uid: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    refresh_token: {
        primaryKey: true,
        type: DataTypes.STRING,
        allowNull: false
    }
},{timestamps: false});


module.exports = {BlacklistedToken};