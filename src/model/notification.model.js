import mongoose from 'mongoose';

const Schema = mongoose.Schema;

class NotificationSchema extends Schema {
    constructor() {
        super({
            email: String,
            name: String,
            message: String,
            timestamp: Date
        })
    }
}

export default mongoose.model('Notification', new NotificationSchema());
