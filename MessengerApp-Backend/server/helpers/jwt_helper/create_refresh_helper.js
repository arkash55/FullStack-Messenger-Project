const db = require("../../database/db_connect").db;
const blackListTokenModel = db.models.blacklisted_tokens;
const getOrSetCache = require('../redis_helper').getOrSetCache;
const redis_client = require('../../database/redis_config').client;



//NOTE - CAN REDO THIS BY ADDING A WHERE TOKEN=TOKEN
const checkForBlacklistedToken = async (uid, refresh_token) => {
  const data = await redis_client.get('blacklisted_tokens');
  if (data == null) {return false}
  const parsed_data = JSON.parse(data);

  for (let i = 0; i < parsed_data.length; i++) {
    if (parsed_data[i]["refresh_token"] == refresh_token) {
      return true;
    }
  }
  return false;
};

module.exports = { checkForBlacklistedToken };



