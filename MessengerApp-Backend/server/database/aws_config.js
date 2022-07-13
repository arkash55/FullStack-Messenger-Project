const S3 = require('aws-sdk/clients/s3');

const bucket_name = process.env.AWS_BUCKET_NAME;
const region = process.env.AWS_BUCKET_REGION;
const access_key_id = process.env.AWS_ACCESS_KEY;
const secret_access_key = process.env.AWS_SECRET_ACCESS_KEY;



//connect to s3 bucket
const s3_bucket = new S3({
    region,
    access_key_id,
    secret_access_key
});



module.exports = {s3_bucket};