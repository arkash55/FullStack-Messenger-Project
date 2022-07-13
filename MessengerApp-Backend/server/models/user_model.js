const db = require('../database/db_connect').db;
const DataTypes = require('sequelize').DataTypes;

const User = db.define('users', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    email: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,
        validate: {
            isEmail: true,
            notEmpty: true
        }
    },
    username: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,
        validate: {
            notEmpty: true
        }
    },
    first_name: {
        type: DataTypes.STRING,
        allowNull: false,
        validate: {
            notEmpty: true
        }
    },
    last_name: {
        type: DataTypes.STRING,
        allowNull: false,
        validate: {
            notEmpty: true
        }
    },
    profile_pic_key: {
        type: DataTypes.STRING,
    },
    is_verified: {
        type: DataTypes.BOOLEAN,
        defaultValue: true ,
        validate: {
            notEmpty: true
        }
    },
    p_hash: {
        type: DataTypes.STRING,
        allowNull: false,
        validate: {
            len: 32,
            notEmpty: true
        }
    },
    p_salt: {
        type: DataTypes.STRING,
        allowNull: false,
        validate: {
            len: [32,64],
            notEmpty: true
        }
    }
});




module.exports = {User};
