const Sequelize = require('sequelize');
const database = process.env.PDB_NAME;
const username = process.env.PDB_USERNAME;
const password = process.env.PDB_PASSWORD



const db = new Sequelize(database, username, password, {
  host: process.env.PDB_HOST,
  dialect: process.env.PDB_DIALECT,
  logging: false,
});



const test_connection = async () => {
  try {
      await db.authenticate();
      console.log('Connected to postgreSQL database.');
    } catch (error) {
      console.error('Unable to connect to the database:', error);
    }
}

test_connection();




module.exports = {db};