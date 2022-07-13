const redis = require('redis');
const redis_url = process.env.REDIS_URL || 'redis://127.0.0.1:6379';


const client = redis.createClient(redis_url);


client.connect();

client.on('connect', () => {
    console.log('Connected to redis database');
});


client.on('error', (err) => {
    throw `Redis Error: ${err}`;
});




module.exports = {client};