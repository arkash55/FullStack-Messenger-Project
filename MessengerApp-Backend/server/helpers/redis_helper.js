const redis_client = require('../database/redis_config').client;




const getOrSetCache = async (key, cb) => {
    const redisData = await redis_client.get(key);
    if (redisData != null) {return JSON.parse(redisData)};
    const fetchedData = await cb()
    await redis_client.setEx(key,300,JSON.stringify(fetchedData));
    return fetchedData
};

const insertOrCreateCache = async (key, data) => {
    const cached_data = await redis_client.get(key);
    if (cached_data == null) {return}
    const new_data = appendJSON(cached_data, data)
    await redis_client.setEx(key,300,new_data)
    return
}


const tokenInsertOrCreateCache = async (data) => {
    const key = 'blacklisted_tokens'
    const cached_data = await redis_client.get(key);
    if (cached_data == null) {
        await redis_client.set(key,JSON.stringify([data]))
        return
    } else {
        const new_data = appendJSON(cached_data, data)
        await redis_client.setEx(key,300,new_data)
        return
    }  
}

const appendJSON = (cached_data, obj) => {
    const data = JSON.parse(cached_data);
    data.push(obj)
    return JSON.stringify(data)
};




module.exports = {
    getOrSetCache,
    insertOrCreateCache,
    tokenInsertOrCreateCache,
}